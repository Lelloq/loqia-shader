#version 120

varying vec2 texcoord;
varying vec4 glcolor;

uniform sampler2D texture;

void main()
{
	/*DRAWBUFFERS:0*/
	gl_FragData[0] = texture2D(texture, texcoord) * glcolor;
}