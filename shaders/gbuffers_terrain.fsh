#version 120

uniform sampler2D texture;

varying vec2 LightmapCoords;
varying vec2 TexCoords;
varying vec3 Normal;
varying vec4 Color;

void main() {
	vec4 albedo = texture2D(texture, TexCoords) * Color;

/* DRAWBUFFERS:012 */
	gl_FragData[0] = albedo; //gcolor
	gl_FragData[1] = vec4(Normal * 0.5 + 0.5, 1.0);
	gl_FragData[2] = vec4(LightmapCoords, 0.0, 1.0);
}