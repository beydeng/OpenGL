# Textures
Learning OpenGL On the MAC 

纹理

    为了能够把纹理映射到三角形上，我们需要指定三角形的每个顶点各自对应的纹理的哪个部分。这样每个顶点就会关联着一个纹理坐标，用来表明该从纹理图像的哪个部分采样。之后在图形的其他片段上进行片段插值。
    
    纹理坐标在x和y上，范围为0到1之间。使用纹理坐标获取纹理颜色叫做采样。纹理坐标起始于左下角（0，0），终止与右上角（1，1）。

纹理环绕方式

    纹理坐标的范围通常是从(0, 0)到(1, 1)，那如果我们把纹理坐标设置在范围之外会发生什么？OpenGL默认的行为是重复这个纹理图像（我们基本上忽略浮点纹理坐标的整数部分），但OpenGL提供了更多的选择：
    
    GL_REPEAT  对纹理的默认行为。重复纹理图像
    GL_MIRRORED_REPEAT 和GL_REPEAT一样，但每次重复图片是镜像放置的
    GL_CLAMP_TO_EDGE 纹理坐标会被约束在0到1之间，超出的部分会重复纹理坐           标的边缘，产生一种边缘被拉伸的效果。
    GL_CLAMP_TO_BORDER 超出的坐标为用户指定的边缘颜色。

    每个选项都可以使用glTexParameter*函数对单独的一个坐标轴设置（s、t（如果是使用3D纹理那么还有一个r）它们和x、y、z是等价的）
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);

    第一个参数指定了纹理目标；我们使用的是2D纹理，因此纹理目标是GL_TEXTURE_2D。第二个参数需要我们指定设置的选项与应用的纹理轴。我们打算配置的是WRAP选项，并且指定S和T轴。最后一个参数需要我们传递一个环绕方式，在这个例子中OpenGL会给当前激活的纹理设定纹理环绕方式为GL_MIRRORED_REPEAT。
    
纹理过滤

    纹理坐标不依赖于分辨率。所以OpenGL需要知道怎样将纹理像素(Texture Pixel，也叫Texel)映射到纹理坐标。当你有一个很大的物体但是纹理的分辨率很低的时候这就变得很重要了。你可能已经猜到了，OpenGL也有对于纹理过滤(Texture Filtering)的选项。纹理过滤有很多个选项，但是现在我们只讨论最重要的两种：GL_NEAREST和GL_LINEAR。
    
    Texture Pixel也叫Texel，你可以想象你打开一张.jpg格式图片，不断放大你会发现它是由无数像素点组成的，这个点就是纹理像素；注意不要和纹理坐标搞混，纹理坐标是你给模型顶点设置的那个数组，OpenGL以这个顶点的纹理坐标数据去查找纹理图像上的像素，然后进行采样提取纹理像素的颜色。

    GL_NEAREST（也叫邻近过滤，Nearest Neighbor Filtering）是OpenGL默认的纹理过滤方式。当设置为GL_NEAREST的时候，OpenGL会选择中心点最接近纹理坐标的那个像素。纹理像素的中心距离纹理坐标最近，所以它会被选择为样本颜色
    
    GL_LINEAR（也叫线性过滤，(Bi)linear Filtering）它会基于纹理坐标附近的纹理像素，计算出一个插值，近似出这些纹理像素之间的颜色。一个纹理像素的中心距离纹理坐标越近，那么这个纹理像素的颜色对最终的样本颜色的贡献越大。
    
    进行放大(Magnify)和缩小(Minify)操作的时候可以设置纹理过滤的选项，比如你可以在纹理被缩小的时候使用邻近过滤，被放大时使用线性过滤。我们需要使用glTexParameter*函数为放大和缩小指定过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
多级渐远纹理

     多级渐远纹理背后的理念很简单：距观察者的距离超过一定的阈值，OpenGL会使用不同的多级渐远纹理，即最适合物体的距离的那个。由于距离远，解析度不高也不会被用户注意到。同时，多级渐远纹理另一加分之处是它的性能非常好。
     手工为每个纹理图像创建一系列多级渐远纹理很麻烦，幸好OpenGL有一个glGenerateMipmaps函数，在创建完一个纹理后调用它OpenGL就会承担接下来的所有工作了
     
     GL_NEAREST_MIPMAP_NEAREST    使用最邻近的多级渐远纹理来匹配像素大小，并使用邻近插值进行纹理采样
     GL_LINEAR_MIPMAP_NEAREST    使用最邻近的多级渐远纹理级别，并使用线性插值进行采样
     GL_NEAREST_MIPMAP_LINEAR    在两个最匹配像素大小的多级渐远纹理之间进行线性插值，使用邻近插值进行采样
     GL_LINEAR_MIPMAP_LINEAR    在两个邻近的多级渐远纹理之间使用线性插值，并使用线性插值进行采样
     
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

应用纹理

    片段着色器也应该能访问纹理对象，但是我们怎样能把纹理对象传给片段着色器呢？GLSL有一个供纹理对象使用的内建数据类型，叫做采样器(Sampler)，它以纹理类型作为后缀，比如sampler1D、sampler3D，或在我们的例子中的sampler2D。我们可以简单声明一个uniform sampler2D把一个纹理添加到片段着色器中，稍后我们会把纹理赋值给这个uniform。

    #version 300 core
    precision mediump float;
    in vec3 ourColor;
    in vec2 TexCoord;
    out vec4 color;
    uniform sampler2D ourTexture;
    void main()
        {
            color = texture(ourTexture, TexCoord);
        }

    我们使用GLSL内建的texture函数来采样纹理的颜色，它第一个参数是纹理采样器，第二个参数是对应的纹理坐标。texture函数会使用之前设置的纹理参数对相应的颜色值进行采样。这个片段着色器的输出就是纹理的（插值）纹理坐标上的(过滤后的)颜色。
 
 一
 
     调用-(void)createTexure方法，就可以看见我们的效果了。

二

    一个纹理的位置值通常称为一个纹理单元(Texture Unit)。一个纹理的默认纹理单元是0，它是默认的激活纹理单元，所以前面部分我们没有分配一个位置值，所以也就没有使用glUniform给uniform赋值。

    纹理单元的主要目的是让我们在着色器中可以使用多个纹理，通过把纹理单元赋值给采样器，我们就可以一次绑定多个纹理，只要我们首先激活对应的纹理单元，。
    我们可以使用glActiveTexture激活纹理单元，传入我们需要使用的纹理单元
    
        glActiveTexture(GL_TEXTURE0); //在绑定纹理之前先激活纹理单元
        glBindTexture(GL_TEXTURE_2D, texture);
        
        激活纹理单元之后，接下来的glBindTexture函数调用会绑定这个纹理到当前激活的纹理单元，纹理单元GL_TEXTURE0默认总是被激活，所以我们在前面的例子里当我们使用glBindTexture的时候，无需激活任何纹理单元。
Important
        
    OpenGL至少保证有16个纹理单元供你使用，也就是说你可以激活从GL_TEXTURE0到GL_TEXTRUE15。它们都是按顺序定义的，所以我们也可以通过GL_TEXTURE0 + 8的方式获得GL_TEXTURE8，这在当我们需要循环一些纹理单元的时候会很有用。

    我们需要通过片段着色器来接收另一个采样器。
    
