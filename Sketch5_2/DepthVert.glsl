#version 410

uniform float farplane;

uniform mat4 transform;
in vec4 position;

out float depth;

void main() {
    gl_Position = transform * position;
    depth = gl_Position.z / farplane ;
}