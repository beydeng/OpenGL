# GLSL
Learning OpenGL On the MAC 
 
     着色器是使用的一种叫GLSL的类C语言写成的。
     着色器的开头总要声明版本号，接着是输入和输出变量，统一变量uniform和main函数。每个着色器的入口点都是main函数，在这个函数中我们处理所以的输入变量，并将结果输出到输出变量。
     
     当我们谈论顶点着色器的时候，每个输入变量也叫顶点属性。
     
 数据类型

    和其他编程语言一样，GLSL有数据类型可以来指定变量的种类。GLSL中包含C等其它语言大部分的默认基础数据类型：int、float、double、uint和bool。GLSL也有两种容器类型，它们会在这个教程中使用很多，分别是向量(Vector)和矩阵(Matrix）。

向量

    类型    含义
    vecn    包含n个float分量的默认向量
    bvecn    包含n个bool分量的向量
    ivecn    包含n个int分量的向量
    uvecn    包含n个unsigned int分量的向量
    dvecn    包含n个double分量的向量

        大多数时候我们使用vecn，因为float足够满足大多数要求了。

输入与输出

    虽然着色器是各自独立的小程序，但是他们都是一个整体的一部分，所以我们希望每个着色器都有输入和输出，这样才能进行数据交流和传递。
    GLSL定义了in和out关键字专门来实现这个目的。但在顶点着色器和片段着色器中有点不同。
    顶点着色器应该接受的是一种特殊形式的输入，否则就会效率低下。
    顶点着色器的输入特殊在，它直接从顶点数据中直接接收输入。我们使用locaton这个一元数据指定输入变量。顶点着色器需要为它的输入提供一个额外的layout标识，这样才能链接到顶点数据。
    另一个例外就是片段着色器，它需要一个vec4颜色输出变量，因为片段在色器需要生成一个最终输出的颜色。
    代码中setupTriangleUseEBO方法中，展示的是着色器如何工作的，我们稍微改动一下之前教程里的那个着色器，让顶点着色器为片段着色器决定颜色。
    
Uniform

    Uniform是从CPU中的应用向GPU中的着色器发送数据的方式，但Uniform和顶点属性不同。
    uniform是全局性的，uniform变量必须在每个着色器程序中的对象都是独一无二的，可以被任意着色器访问。同时，unitform中的数据会一直保存，直到被重制或更新。
    如果你声明了一个uniform却在GLSL代码中没有用过，那么编译器会静默移除这个变量，导致最后编译出的版本中并不会包含它，这kennel导致几个非常麻烦的错误。
    见：NewFragmentShader.glsl
    详细使用方法，参见setupTriangleUseUniform方法。
    
如果我们需要更多属性呢？

    我们打算把颜色数据加进顶点数据中。我们将把颜色数据添加为3个float值至vertices数组。我们将把三角形的三个角分别指定为红色、绿色和蓝色
    参考-（void）moreAttribute方法。
    
我们使用着色器时，需要经过大量的操作，所以，我们把编译，连接进行封装，做成一个类，方便使用。

    详见 shader类。