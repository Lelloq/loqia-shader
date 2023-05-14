#version 120

uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

/* DRAWBUFFERS:012 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
	gl_FragData[2] = vec4(lmcoord, 0.0, 1.0);
}