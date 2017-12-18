#version 300 es
precision mediump float;

in vec4 certexColor;
out vec4 color;
void main()
{
    color = certexColor;
}
