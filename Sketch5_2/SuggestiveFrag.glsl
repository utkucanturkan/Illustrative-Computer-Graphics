#version 410

uniform sampler2D texture; // undocumented way processing gives you the input image
uniform int radius;
uniform float d_modifier;
uniform float s_modifier;

in vec4 gl_FragCoord;

out vec4 color;

void main()
{
    int x = int(gl_FragCoord.x);
    int y = int(gl_FragCoord.y);

    vec2 size = textureSize(texture, 0);

    // Loading a pixel from the texture and computing its brightness.
    vec4 centerPixel = texelFetch(texture, ivec2(gl_FragCoord.xy), 0);
    float centerBrightness = dot(centerPixel.rgb, vec3(0.3, 0.59, 0.11));

    int totalPixels = 0;
    int darkerPixels = 0;
    float maxIntensity = centerBrightness;

    float S = 1.0 - (1.0 / float(radius) * s_modifier);
    float D = 1.0 / radius * d_modifier;

    vec4 brightestPixel = vec4(0.0);
    for (int cx = x - radius; cx < x + radius; ++cx)
    {
        for (int cy = y - radius; cy < y + radius; ++cy)
        {
            
            // TODO: Check if pixel is in bounds of texture and in bounds of circle
            // use distance(vec2, vec2) for the latter

            // TODO: Get pixel in the circle from texture and compute its brightness

            // TODO: Track how many pixels we've seen, how many are darker
            // and what the maximum seen intensity is
            if (cx < 0 || cy < 0 || cx > size.x || cy > size.y) {
                //outside of texture bounds
                continue;
            }

            if (distance(ivec2(cx, cy), ivec2(cx, cy)) > radius) {
                //outside of circle
                continue;
            }
            ++totalPixels;

            vec4 otherPixel = texelFetch(texture, ivec2(cx, cy), 0);
            float otherBrightness = dot(otherPixel.rgb, vec3(0.3, 0.59, 0.11));

            if (otherBrightness < centerBrightness) {
                ++darkerPixels;
            }
            if (otherBrightness > maxIntensity) {
                maxIntensity = otherBrightness;
            }
        }
    }

    // TODO: If this pixel is a valley paint it black opaque, otherwise leave it out (vec4(0.0))
    // (D / S) < S
    if ((maxIntensity - centerBrightness) > D && (darkerPixels / float(totalPixels)) < S)
    {
        color = vec4(0.0, 0.0, 0.0, 1.0); // Valley
    }
    else
    {
        color = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
