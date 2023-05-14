vec2 DistortPosition(in vec2 pos)
{
	float centre = length(pos);
	float distortion = mix(1.0, centre, 0.9);
	return pos / distortion;
}