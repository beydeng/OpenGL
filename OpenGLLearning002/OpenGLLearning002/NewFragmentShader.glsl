#version 300 core
precision mediump float;

out vec4 color;

uniform vec4 ourColor;

void main()
{
    color = ourColor;
}
