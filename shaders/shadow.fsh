#version 120

varying vec2 TexCoords;
varying vec4 Colour;

uniform sampler2D texture;

void main()
{
    gl_FragData[0] = texture2D(texture, TexCoords) * Colour;
}