#version 300 core

precision mediump float;

layout (location = 0) in vec3 position;

out vec4 certexColor;

void main()
{
    gl_Position =  vec4(position,1.0);
    certexColor = vec4(0.5,0.0,0.0,0.89);
}

