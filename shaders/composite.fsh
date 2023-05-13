#version 120

varying vec2 TexCoords;

uniform vec3 sunPosition;

uniform sampler2D colortex0;//Colour
uniform sampler2D colortex1;//Normals
uniform sampler2D colortex2;//Lightmap

uniform sampler2D depthtex0;//Depth map
uniform sampler2D shadowtex0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

const float sunPathRotation = -40.0;
const float Ambient = 0.1;
const int shadowResolution = 1024;

//Lightmap functions
float AdjustLightmapTorch(in float torch)
{
	const float k = 2.0;
	const float p = 5.06;
	return k * pow(torch, p);
}

float AdjustLightmapSky(in float sky)
{
	float sky_2 = sky * sky;
	return sky_2 * sky_2;
}

vec2 AdjustLightmap(in vec2 lightmap)
{
	vec2 NewLightmap;
	NewLightmap.x = AdjustLightmapTorch(lightmap.x);
	NewLightmap.y = AdjustLightmapSky(lightmap.y);
	return NewLightmap;
}

vec3 GetLightMapColour(in vec2 lightmap)
{
	lightmap = AdjustLightmap(lightmap);

	const vec3 torchColour = vec3(1.0, 0.25, 0.08);
	const vec3 skyColour = vec3(0.05, 0.15, 0.3);

	vec3 torchLighting = lightmap.x * torchColour;
	vec3 skyLighting = lightmap.y * skyColour;

	return torchLighting + skyLighting;
}

//Shadowmap functions
float GetShadow(float depth)
{
	vec3 clipSpace = vec3(TexCoords, depth) * 2.0 - 1.0;
	vec4 viewW = gbufferProjectionInverse * vec4(clipSpace, 1.0);
	vec3 view = viewW.xyz / viewW.w;

	vec4 world = gbufferModelViewInverse * vec4(view, 1.0);
	vec4 shadowSpace = shadowProjection * shadowModelView * world;

	vec3 shadowCoords = shadowSpace.xyz * 0.5 + 0.5;

	return step(shadowCoords.z - 0.001, texture2D(shadowtex0, shadowCoords.xy).r);
}

void main() {
	//Account for gamma correction
	vec3 albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(2.2));
	float depth = texture2D(depthtex0, TexCoords).r;
	if(depth == 1.0)
	{
		gl_FragData[0] = vec4(albedo, 1.0f);
		return;
	}

	vec2 lightmap = texture2D(colortex2, TexCoords).rg;
	vec3 lightMapColour = GetLightMapColour(lightmap);

	vec3 Normal = normalize(texture2D(colortex1,TexCoords).rgb * 2.0 - 1.0);
	//Angle between normal and sun direction
	float NdotL = max(dot(Normal, normalize(sunPosition)), 0.0);
	//Lighting calc
	vec3 Diffuse = albedo * (NdotL * GetShadow(depth) + Ambient + lightMapColour);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(Diffuse, 1.0); //gcolor
}