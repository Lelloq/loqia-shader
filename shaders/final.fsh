#version 120

varying vec2 TexCoords;

uniform sampler2D colortex0;

void main()
{
	vec3 col = pow(texture2D(colortex0, TexCoords).rgb, vec3(1.0 / 2.2));

	gl_FragColor = vec4(col, 1.0);
}