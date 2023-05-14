#version 120

varying vec2 texcoord;

uniform sampler2D colortex0;

void main()
{
	vec3 color = pow(texture2D(colortex0, texcoord).rgb, vec3(1.0 / 2.2));
	gl_FragColor = vec4(color,1.0);
}