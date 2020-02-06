#version 410

uniform vec3 cameraPosition;

in vec4 vertPosition;
in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertLightDir;

void main()
{

    float intensity = max(0.0, dot(vertLightDir, vertNormal));

    vec4 color = vec4(1.0);
    if (intensity > 0.95)
    {
        color = vec4(0.5, 0.5, 0.5, 1.0);
    }
    else if (intensity > 0.5)
    {
        color = vec4(0.3, 0.3, 0.3, 1.0);
    }
    else if (intensity > 0.25)
    {
        color = vec4(0.2, 0.2, 0.2, 1.0);
    }
    else
    {
        color = vec4(0.1, 0.1, 0.1, 1.0);
    }

    gl_FragColor = color * vertColor;
}