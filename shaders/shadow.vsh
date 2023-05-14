#version 120

#include "common.inc"

varying vec2 texcoord;
varying vec4 glcolor;

void main()
{
	gl_Position = ftransform();
	gl_Position.xy = DistortPosition(gl_Position.xy);
	texcoord = gl_MultiTexCoord0.st;
	glcolor = gl_Color;
}
