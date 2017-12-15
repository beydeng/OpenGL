//
//  OpenGLView.m
//  OpenGLLearning001
//
//  Created by DengPan on 2017/12/14.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import "OpenGLView.h"


@implementation OpenGLView


+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(void)setupLayer
{
    _layer = (CAEAGLLayer *)self.layer;
    _layer.opaque = YES;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                          kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat,
                          nil];
    [_layer setDrawableProperties:dict];

}

-(void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    _context = [[EAGLContext alloc]initWithAPI:api];
    if (!_context) {
        
        NSLog(@"实力话OpenGLES 3.0 context失败");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        
        NSLog(@"获取当前OpenGL context失败");
        exit(1);
        
    }
    
}

-(void)setupBuffer
{
    //创建渲染缓存区
    GLuint colorRenderBuffer;
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
    
    //创建帧缓存区
    /*
     除了可以用OpenGL ES 3.0在屏幕上的窗口渲染之外，还可以渲染称作pbuffer（像素缓存区）的不可见屏幕外表面。和窗口一样pbuffer可以利用OpenGL ES3.0的任何硬件加速。Pbuffer最常用于生成纹理贴图。如果你想要做的书渲染到一个纹理，那么使用帧缓存区对象代替Pbuffer跟搞笑。
     */

    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, colorRenderBuffer);
    
}

//编译着色器的封装方法

-(GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType
{
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    //  调用glCreateShader来创建一个代表shader的OpenGL对象。这时你必须告诉OpenGL，你想创建fragmaent shader还是certex shader。
    //    首先，创建一个着色器对象，返回值是这个对象的唯一ID
    
    //使用着色器对象的第一步是创建着色器
    //调用glCreateShader将根据传入的type参数创建一个新的顶点或者片段着色器。返回值是指向新着色器对象的句柄
    GLuint shaderHandle = glCreateShader(shaderType);
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    
    //  调用glShaderSource，让OpenGL获取到这个shader的源代码。
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    //  调用glCompileShader在运行时编译shader
    glCompileShader(shaderHandle);
    
    //    glGetShaderiv 和 glGetShaderInfoLog  会把error信息输出到屏幕。
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"messageError%@", messageString);
        exit(1);
        
    }
    
    //当完成着色器对象时，使用glDeleteShader进行删除。注意，如果一个着色器连接到一个程序对象，那么调用glDeleteShader不回立刻删除着色器，而是将着色器标记为删除，在着色器不再链接到任何程序对象的时，他的内存将被释放。
    //    glDeleteShader(shaderHandle);
    
    return shaderHandle;
    
}

//创建和链接程序
//上一步时如何创建着色器对象，下一步是创建一个程序对象
//程序对象是一个容器对象，可以将着色器与之连接，并链接一个最终的可执行程序。
-(void)compileShaderVertex:(NSString *)vertex fragment:(NSString *)fragment{
    
    GLuint vertexShader = [self compileShader:vertex withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:fragment withType:GL_FRAGMENT_SHADER];
    
    //    调用了glCreateProgram glAttachShader glLinkProgram连接vertext和fragment shader成一个完整的program
    //    我们需要三步来使用着色器程序对象，现在已经很熟悉了。创建、附加、链接。
    GLuint programHandle = glCreateProgram();//它简单的返回一个指向新程序对象的句柄。
    glAttachShader(programHandle, vertexShader);//一旦创建了程序对象，下一步就是将着色器与之连接。每个程序对象必须连接一个顶点着色器和一个片段着色器。注意着色器可以在任何时候连接--在连接到程序之前不一定需要编译，甚至可以没有源代码。唯一的要求是，每个程序对象必须有且只有一个顶点着色器和片段着色器与之连接。除了连接着色器之外，你还可以用glDetachShader断开着色器的连接。
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);//链接着色器。连接操作负责生成最终的可执行程序。连接程序将检查各种对象的数量，确保成功连接。
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"messageString==--==%@", messageString);
        exit(1);
        
    }
    
    //  调用glUseProgram让OpenGL真正执行你的program
    glUseProgram(programHandle);
    glDeleteShader(programHandle);
    
}

-(void)setupVbo
{
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    };
    GLuint VBO;
    glGenBuffers(1, &VBO); //访问OpenGL，让它分配给一个独一无二的ID
    //OpenGl有很多缓存对象类型，顶点缓存对象的缓存类型是GL_ARRAY_BUFFER
    //调用glBindBuffer把新创建的缓存绑定到GL_ARRAY_BUFFER目标上
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    //从此之后，我们使用的任何缓存调用都会用来配置当前绑定的缓冲。然后我们调用glBufferData函数，它会把之前定义的顶点数据复制到缓冲的内存中
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    //第一个参数指定目标缓冲的类型：我们前面已经讲顶点数据绑定到了GL_ARRAY_BUFFER目标上
    //第二个参数指定传输数据的大小
    //第三个参数时我们希望发送的实际数据
    //第四个参数指定显卡如何如何管理给定的数据
    /*
     他有三种形式：GL_STATIC_DRAW :数据不会或几乎不会改变
     GL_DYNAMIC_DRAW:数据会被改变很多
     GL_STREAM_DRAW:数据每次绘制时都会改变
     */
    
    
}


-(void)render{
    
    glClearColor(0, 1, 1, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);
    
    //使用glVertexAttribPointer函数告诉OpenGL该如何解析顶点数据（应用到逐个顶点属性上）

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), 0);
    /*
     第一个参数 指定我们要配置的顶点属性，我们在顶点在色器中 使用了layout(location = 0)定义了position顶点属性的位置，所以这个地方我们给的值时0
     第二个参数 指定顶点属性的大小。顶点属性属性时一个vec3，它由3个值组成，所以大小是3
     第三个参数指定数据的类型
     第四个参数 我们是否希望数据被标准化。如果设置为GL_TRUE，所有数据都会被映射到0（有符号型signed数据是-1）到1之间。我们设置为GL_FALSE
     第5个参数是步长。由于下个组位置数据在3个GLfloat之后，我们把步长设置为3 * sizeof(GLfloat)。要注意的是由于我们知道这个数组是紧密排列的（在两个顶点属性之间没有空隙）我们也可以设置为0来让OpenGL决定具体步长是多少（只有当数值是紧密排列时才可用）。一旦我们有更多的顶点属性，我们就必须更小心地定义每个顶点属性之间的间隔，我们在后面会看到更多的例子
     最后一个参数的类型是GLvoid*，所以需要我们进行这个奇怪的强制类型转换。它表示位置数据在缓冲中起始位置的偏移量(Offset)。由于位置数据在数组的开头，所以这里是0。我们会在后面详细解释这个参数。
     */
    
    glEnableVertexAttribArray(0);//启用顶点属性，默认是禁止的。
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    /*
     glDrawArrays函数第一个参数是我们打算绘制的OpenGL图元的类型。由于我们在一开始时说过，我们希望绘制的是一个三角形，这里传递GL_TRIANGLES给它。第二个参数指定了顶点数组的起始索引，我们这里填0。最后一个参数指定我们打算绘制多少个顶点，这里是3（我们只从我们的数据中渲染一个三角形，它只有3个顶点长）
    */
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];

}


#pragma -mark 第一个三角形
-(void)setupTriangle
{
    [self setupLayer];
    [self setupContext];
    [self setupBuffer];
    [self setupVbo];
    [self compileShaderVertex:@"VerterShader" fragment:@"FragmentShader"];
    [self render];
}

-(GLuint)setVAO{
    
    /*
     要想使用VAO，要做的只是使用glBindVertexArray绑定VAO。从绑定之后起，我们应该绑定和配置对应的VBO和属性指针，之后解绑VAO供之后使用。当我们打算绘制一个物体的时候，我们只要在绘制物体前简单地把VAO绑定到希望使用的设定上就行了。
     */
    
    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    
    //绑定VAO
    glBindVertexArray(VAO);
    
    //把顶点数组复制到缓冲中供OpenGL使用
    
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    };
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(0);
    
    //解绑VAO
    glBindVertexArray(0);
    /*
    通常情况下当我们配置好OpenGL对象以后要解绑它们，这样我们才不会在其它地方错误地配置它们。
    */
    return VAO;
}

//使用VAO绘制三角形

-(void)setupTriangleUseVAO
{
    [self setupLayer];
    [self setupContext];
    [self setupBuffer];
    [self compileShaderVertex:@"VerterShader" fragment:@"FragmentShader"];
    
    glClearColor(0, 1, 1, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);

    glBindVertexArray([self setVAO]);
    glDrawArrays(GL_TRIANGLES, 0, 3);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑

}

//Element Buffer Object
#pragma -mark 索引缓冲对象EBO
-(GLuint)setupEBO
{
    
    GLfloat vertices[] = {
        0.5f, 0.5f, 0.0f,   // 右上角
        0.5f, -0.5f, 0.0f,  // 右下角
        -0.5f, -0.5f, 0.0f, // 左下角
        -0.5f, 0.5f, 0.0f   // 左上角
    };
    
    GLuint indices[] = { // 注意索引从0开始!
        0, 1, 3, // 第一个三角形
        1, 2, 3  // 第二个三角形
    };
    
    
    // 1. 绑定顶点数组对象
    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);
    // 2. 把我们的顶点数组复制到一个顶点缓冲中，供OpenGL使用
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    // 3. 复制我们的索引数组到一个索引缓冲中，供OpenGL使用
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // 4. 设定顶点属性指针
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    
    // 5. 解绑VAO（不是EBO！）
    glBindVertexArray(0);
    
    return VAO;
    
}

#pragma -mark 使用EBO绘制矩形
-(void)setupTriangleUseEBO
{
    [self setupLayer];
    [self setupContext];
    [self setupBuffer];
    [self compileShaderVertex:@"VerterShader" fragment:@"FragmentShader"];
    
    glClearColor(0, 1, 1, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);
    
    glBindVertexArray([self setupEBO]);
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupTriangleUseEBO];
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
