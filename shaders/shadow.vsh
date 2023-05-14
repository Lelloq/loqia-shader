#version 120

#include "common.inc"

varying vec2 TexCoords;
varying vec4 Colour;

void main()
{
    gl_Position = ftransform();
    gl_Position.xy = DistortPosition(gl_Position.xy);
    TexCoords = gl_MultiTexCoord0.st;
    Colour = gl_Color;
}