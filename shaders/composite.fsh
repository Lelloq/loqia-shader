#version 120

#include "common.inc"

varying vec2 texcoord;

//Non-normalized sun position
uniform vec3 sunPosition;

uniform sampler2D colortex0;//Colour
uniform sampler2D colortex1;//Normal
uniform sampler2D colortex2;//Lightmap
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;//Everything
uniform sampler2D shadowtex1;//Opaque blocks
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

const float sunPathRotation = -40.0;
const int shadowMapResolution = 2048;
const int noiseTextureResolution = 64;

const float ambient = 0.025;

//Lightmap calculations
float AdjustTorch(in float torch)
{
	const float k = 2.0;
	const float p = 5.06;
	return k * pow(torch, p);
}

float AdjustSky(in float sky)
{
	float sky_2 = sky * sky;
	return sky_2 * sky_2;
}

vec2 AdjustLightmap(in vec2 lightmap)
{
	vec2 lm;
	lm.x = AdjustTorch(lightmap.x);
	lm.y = AdjustSky(lightmap.y);
	return lm;
}

vec3 GetLightmapColour(in vec2 lightmap)
{
	lightmap = AdjustLightmap(lightmap);

	const vec3 tColour = vec3(1.0, 0.25, 0.08);
	const vec3 sColour = vec3(0.05, 0.15, 0.3);

	vec3 tLighting = lightmap.x * tColour;
	vec3 sLighting = lightmap.y * sColour;

	vec3 lLighting = tLighting + sLighting;
	return lLighting;
}

//Shadow calculations
#define SHADOW_SAMPLES 2
const int ShadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int TotalSamples = ShadowSamplesPerSize * ShadowSamplesPerSize;

float Visibility(in sampler2D shadowMap, in vec3 sampleCoords)
{
	return step(sampleCoords.z - 0.001, texture2D(shadowMap, sampleCoords.xy).r);
}

vec3 TransparentShadow(in vec3 sampleCoords)
{
	float sVis0 = Visibility(shadowtex0, sampleCoords);
	float sVis1 = Visibility(shadowtex1, sampleCoords);
	vec4 sColor0 = texture2D(shadowcolor0, sampleCoords.xy);
	vec3 finalColor = sColor0.rgb * (1.0 - sColor0.a);
	return mix(finalColor * sVis1, vec3(1.0), sVis0);
}

vec3 GetShadow(float depth)
{
	vec3 clipSpace = vec3(texcoord, depth) * 2.0 - 1.0;
	vec4 viewW = gbufferProjectionInverse * vec4(clipSpace,1.0);
	vec3 view = viewW.xyz /viewW.w;

	vec4 world = gbufferModelViewInverse * vec4(view,1.0);
	vec4 shadowSpace = shadowProjection * shadowModelView * world;
	shadowSpace.xy = DistortPosition(shadowSpace.xy);

	vec3 sampleCoords = shadowSpace.xyz * 0.5 + 0.5;

	float randomAngle = texture2D(noisetex, texcoord * 20.0).r * 100.0;
	float cosTheta = cos(randomAngle);
	float sinTheta = sin(randomAngle);
	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowMapResolution;

	vec3 acc = vec3(0.0);
	for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++)
	{	
		for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++)
		{
			vec2 offset = rotation * vec2(x,y);
			vec3 curSampleCoord = vec3(sampleCoords.xy + offset, sampleCoords.z);
			acc += TransparentShadow(curSampleCoord);
		}
	}
	acc /= TotalSamples;
	return acc;
}

void main() {
	vec3 color = pow(texture2D(colortex0, texcoord).rgb, vec3(2.2));
	float depth = texture2D(depthtex0, texcoord).r;
	if(depth == 1.0)
	{
		gl_FragData[0] = vec4(color, 1.0);
		return;
	}

	vec3 normal = normalize(texture2D(colortex1,texcoord).rgb * 2.0 - 1.0);
	vec2 lm = texture2D(colortex2, texcoord).rg;
	vec3 lmColour = GetLightmapColour(lm);

	float NdotL = max(dot(normal, normalize(sunPosition)),0.0);

	vec3 diffuse = color * (lmColour + NdotL * GetShadow(depth) + ambient);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(diffuse, 1.0); //gcolor
}