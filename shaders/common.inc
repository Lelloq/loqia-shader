vec2 DistortPosition(in vec2 position)
{
    float centreDistance = length(position);
    float distortionFactor = mix(1.0, centreDistance, 0.9);
    return position / distortionFactor;
}