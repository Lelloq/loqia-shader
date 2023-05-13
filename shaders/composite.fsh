#version 120

varying vec2 TexCoords;

uniform vec3 sunPosition;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

const float sunPathRotation = -40.0;
const float Ambient = 0.1;

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

void main() {
	//Account for gamma correction
	vec3 albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(2.2));

	vec2 lightmap = texture2D(colortex2, TexCoords).rg;
	vec3 lightMapColour = GetLightMapColour(lightmap);

	vec3 Normal = normalize(texture2D(colortex1,TexCoords).rgb * 2.0 - 1.0);
	//Angle between normal and sun direction
	float NdotL = max(dot(Normal, normalize(sunPosition)), 0.0);
	//Lighting calc
	vec3 Diffuse = albedo * (NdotL + Ambient + lightMapColour);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(Diffuse, 1.0); //gcolor
}