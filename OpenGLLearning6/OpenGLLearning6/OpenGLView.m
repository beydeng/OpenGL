//
//  OpenGLView.m
//  OpenGLLearning002
//
//  Created by DengPan on 2017/12/15.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import "OpenGLView.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <QuartzCore/QuartzCore.h>

@interface OpenGLView()
{
    EAGLContext *_context;
    CAEAGLLayer *_layer;
    GLuint programHandleContent;
}

@end

@implementation OpenGLView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(void)setLayer{
    
    _layer = (CAEAGLLayer *)self.layer;
    _layer.opaque = YES;
    
}

-(void)setupContext{
    
    _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        NSLog(@"初始化_context失败");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        
        NSLog(@"获取_context失败");
        exit(1);
    }
    
}

-(void)setBuffer
{
    //创建渲染缓存区
    GLuint colorRenderBuffer;
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, colorRenderBuffer);
    
}

//Element Buffer Object
#pragma -mark 索引缓冲对象EBO
-(GLuint)setupEBO
{
    
    GLfloat vertices[] = {
        0.5f, 0.5f, 0.0f,   // 右上角
        0.5f, -0.5f, 0.0f,  // 右下角
        -0.5f, -0.5f, 0.0f, // 左下角
    };
    
    GLuint indices[] = { // 注意索引从0开始!
        0, 1, 3, // 第一个三角形
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
    [self setLayer];
    [self setupContext];
    [self setBuffer];
    
    /*
     我们会稍微改动一下之前的那个两个着色器，让顶点着色器为片段着色器决定颜色。
     */
    
    [self compileShaderVertex:@"VertexColor" fragment:@"FragmentShader"];
    
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);

    glBindVertexArray([self setupEBO]);

    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO
    
}

#pragma -mark uniform的使用
-(void)setupTriangleUseUniform
{
    [self setLayer];
    [self setupContext];
    [self setBuffer];
    
    //因为这个着色器中uniform为空，需要添加数据。我， 首先找到这个着时期中unitorm属性的索引，让我们得到uniform的索引位置值后，我们就可以更新它的值。
    
    GLuint vertexShader = [self compileShader:@"VertexColor" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"NewFragmentShader" withType:GL_FRAGMENT_SHADER];

    programHandleContent = glCreateProgram();
    glAttachShader(programHandleContent, vertexShader);
    glAttachShader(programHandleContent, fragmentShader);
    glLinkProgram(programHandleContent);
    
    GLint linkSuccess;
    glGetProgramiv(programHandleContent, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        
        GLchar messages[256];
        glGetProgramInfoLog(programHandleContent, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"messageString==--==%@", messageString);
        exit(1);
        
    }
    
    glUseProgram(programHandleContent);
    
    //询uniform地址不要求你之前使用过着色器程序，但是更新一个unform之前你必须先使用程序（调用glUseProgram)，因为它是在当前激活的着色器程序中设置unform的。
    
//    glDeleteShader(programHandle);
    
//    [self display]; //如果单次改变这个值
    
    [self initTime]; //如果想按照刷新率 动态改变这个值的话
    
}
//添加循环改变
-(void)initTime
{
    CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(display)];
    [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void)display
{
    NSDate *date = [NSDate date];
    
    NSTimeInterval datenow = [date timeIntervalSince1970];
    
    GLfloat greenValue = (sin(datenow) / 2) + 0.5;
    
    GLint vertexColorLocation = glGetUniformLocation(programHandleContent, "ourColor");
    
    glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);
    
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);
    
    glBindVertexArray([self setupEBO]);
    
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, 0);
    [_context presentRenderbuffer:GL_RENDERBUFFER];

    glBindVertexArray(0); //解绑VAO
    
}

#pragma -mark 更多的属性

//我们打算把颜色数据加进顶点数据中。我们将把颜色数据添加为3个float值至vertices数组。我们将把三角形的三个角分别指定为红色、绿色和蓝色
-(void)moreAttribute
{
    
    [self setLayer];
    [self setupContext];
    [self setBuffer];
    
    [self compileShaderVertex:@"moreAttributeVertexColor" fragment:@"moreAttributeFragmentShader"];
    
    GLfloat vertices[] = {
        // 位置              // 颜色
        0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // 左下
        0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // 顶部
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
    
    // 位置属性
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    // 颜色属性
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)(3* sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);
    
    glBindVertexArray(VAO);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        [self setupTriangleUseEBO];
        
//        [self setupTriangleUseUniform];
        
        [self moreAttribute];
        
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
