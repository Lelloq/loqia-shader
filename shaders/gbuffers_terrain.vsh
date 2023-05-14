#version 120

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 glcolor;

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.st;
	
	lmcoord = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
	lmcoord = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);
	
	normal = gl_NormalMatrix * gl_Normal;
	glcolor = gl_Color;
}