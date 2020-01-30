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
    float maxIntensity = 0.0;

    float S = 1.0 - (1.0 / float(radius) * s_modifier);
    float D = 1.0 / radius * d_modifier;

    vec2 brightestPixel = vec2(0, 0);
    for (int cx = x - radius; cx < x + radius; ++cx)
    {
        for (int cy = y - radius; cy < y + radius; ++cy)
        {

            // TODO: Check if pixel is in bounds of texture and in bounds of circle
            // use distance(vec2, vec2) for the latter
            vec2 p = vec2(cx, cy);
            if (distance(centerPixel.xy, p) < radius)
            {
                totalPixels += 1;
                float b = dot(p.rgb, vec3(0.3, 0.59, 0.11));
                if (b > maxIntensity)
                {
                    maxIntensity = b;
                    brightestPixel = p;
                }
                else
                {
                    darkerPixels += 1;
                }
            }
            // TODO: Get pixel in the circle from texture and compute its brightness

            // TODO: Track how many pixels we've seen, how many are darker
            // and what the maximum seen intensity is
        }
    }

    // TODO: If this pixel is a valley paint it black opaque, otherwise leave it out (vec4(0.0))
    if ((maxIntensity - centerBrightness) > D && (D / S) < S)
    {
        color = vec4(1.0, 1.0, 1.0, 1.0);
    }
    else
    {
        color = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
