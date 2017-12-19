#version 300 core
precision mediump float;

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 color;
layout (location = 2) in vec2 textCoord;

out vec3 ourColor;
out vec2 myTexCoord;

void main()
{
    gl_Position = vec4(position,1.0);
    ourColor = color;
    myTexCoord = textCoord;
}
