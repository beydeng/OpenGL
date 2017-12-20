//
//  OpenGLView.m
//  OpenGLLearning003
//
//  Created by DengPan on 2017/12/18.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//


#import "OpenGLView.h"
#import "Shader.h"
#import "ToGLfloat.h"
#import <GLKit/GLKit.h>

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
//我们为三角形指定了3个纹理坐标点。我们希望三角形的左下角对应纹理的左下角，因此我们把三角形左下角顶点的纹理坐标设置为(0, 0)；三角形的上顶点对应于图片的上中位置所以我们把它的纹理坐标设置为(0.5, 1.0)；同理右下方的顶点设置为(1, 0)。我们只要给顶点着色器传递这三个纹理坐标就行了，接下来它们会被传片段着色器中，它会为每个片段进行纹理坐标的插值。
/*
 纹理坐标看起来就像这样：
 
 GLfloat texCoords[] = {
 0.0f, 0.0f, // 左下角
 1.0f, 0.0f, // 右下角
 0.5f, 1.0f // 上中
 };
 
 */

//片段着色器也应该能访问纹理对象，但是我们怎样能把纹理对象传给片段着色器呢？GLSL有一个供纹理对象使用的内建数据类型，叫做采样器(Sampler)，它以纹理类型作为后缀，比如sampler1D、sampler3D，或在我们的例子中的sampler2D。我们可以简单声明一个uniform sampler2D把一个纹理添加到片段着色器中，稍后我们会把纹理赋值给这个uniform。


-(GLuint)loadTheImage:(NSString *)imageName{
    
    //可以使用SOIL.lib库，这里我们使用CGImage
    
    CGImageRef textureImage = [UIImage imageNamed:imageName].CGImage;
    if (textureImage == nil) {
        NSLog(@"Failed to load texture image");
    }
    
    CGFloat texWidth = CGImageGetWidth(textureImage);
    CGFloat texHeight = CGImageGetHeight(textureImage);
    
    GLubyte *textureData = (GLubyte *) calloc(texWidth * texHeight * 4, sizeof(GLubyte));
    
    CGContextRef textureContext = CGBitmapContextCreate(textureData,
                                                        texWidth, texHeight,
                                                        8, texWidth * 4,
                                                        CGImageGetColorSpace(textureImage),
                                                        kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
    CGContextRelease(textureContext);
    
    //生成纹理
    
    GLuint texture;
    glGenBuffers(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    //下面使用glTexImage2D生成纹理
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    /*
     第一个参数指定了纹理目标(Target)。设置为GL_TEXTURE_2D意味着会生成与当前绑定的纹理对象在同一个目标上的纹理（任何绑定到GL_TEXTURE_1D和GL_TEXTURE_3D的纹理不会受到影响）。
     第二个参数为纹理指定多级渐远纹理的级别，如果你希望单独手动设置每个多级渐远纹理的级别的话。这里我们填0，也就是基本级别。
     第三个参数告诉OpenGL我们希望把纹理储存为何种格式。我们的图像只有RGB值，因此我们也把纹理储存为RGB值。
     第四个和第五个参数设置最终的纹理的宽度和高度。我们之前加载图像的时候储存了它们，所以我们使用对应的变量。
     下个参数应该总是被设为0（历史遗留问题）。
     第七第八个参数定义了源图的格式和数据类型。我们使用RGB值加载这个图像，并把它们储存为char(byte)数组，我们将会传入对应值。
     最后一个参数是真正的图像数据。
     */
    
    //当调用glTexImage2D时，当前绑定的纹理对象就会被附加上纹理图像。然而，目前只有基本级别(Base-level)的纹理图像被加载了，如果要使用多级渐远纹理，我们必须手动设置所有不同的图像（不断递增第二个参数）。或者，直接在生成纹理之后调用glGenerateMipmap。这会为当前绑定的纹理自动生成所有需要的多级渐远纹理。
    
    glGenerateMipmap(GL_TEXTURE_2D);
    
    //解绑纹理对象是一个很好的习惯
    glBindTexture(GL_TEXTURE_2D, 0);
    free(textureData);
    
    return texture;
    
}

-(void)createTexure
{
    
    [self setLayer];
    [self setupContext];
    [self setBuffer];
    
    Shader *shader = [[Shader alloc]init];
    NSString* verShaderPath = [[NSBundle mainBundle] pathForResource:@"Vershader"
                                                              ofType:@"vs"];
    NSString* fragShaderPath = [[NSBundle mainBundle] pathForResource:@"Fragment"
                                                               ofType:@"frag"];
    
    
    [shader shaderVertexPath:verShaderPath fragmentPath:fragShaderPath];
    
    [shader use];
    
    //下面我们使用纹理
    
    GLfloat vertices[] = {
        //     ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
    };
    GLuint indices[] = {
        0, 1, 3,
        1, 2, 3
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
    
    
    // 位置属性
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    // 颜色属性
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(3* sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    //纹理属性
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(2* sizeof(GLfloat)));
    glEnableVertexAttribArray(2);
    
    
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);
    
    glBindTexture(GL_TEXTURE_2D, [self loadTheImage:@"wall"]);
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO
}

#pragma -mark 纹理单元

//GLSL内建的mix函数需要接受两个值作为参数，并对它们根据第三个参数进行线性插值。。如果第三个值是0.0，它会返回第一个输入；如果是1.0，会返回第二个输入值。0.2会返回80%的第一个输入颜色和20%的第二个输入颜色，即返回两个纹理的混合色。

-(void)comDoubleText{
    
    //上面我们已经载入了第一个纹理
    //下面我们用同样的方法载入第二张纹理
    
    [self setLayer];
    [self setupContext];
    [self setBuffer];
    
    Shader *shader = [[Shader alloc]init];
    NSString* verShaderPath = [[NSBundle mainBundle] pathForResource:@"Vershader"
                                                              ofType:@"vs"];
    NSString* fragShaderPath = [[NSBundle mainBundle] pathForResource:@"Fragment2"
                                                               ofType:@"frag"];
    
    
    [shader shaderVertexPath:verShaderPath fragmentPath:fragShaderPath];
    
    [shader use];
    
    //下面我们使用纹理
    
    GLfloat vertices[] = {
        //     ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
    };
    GLuint indices[] = {
        0, 1, 3,
        1, 2, 3
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
    
    // 位置属性
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    // 颜色属性
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(3* sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    //纹理属性
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(6* sizeof(GLfloat)));
    glEnableVertexAttribArray(2);
    
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);
    
    //为了使用第二个纹理（以及第一个），我们必须改变一点渲染流程，先绑定两个纹理到对应的纹理单元，然后定义哪个uniform采样器对应哪个纹理单元：
    GLuint texture1 = [self loadTheImage:@"awesomeface"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,texture1);
    GLuint hh = glGetUniformLocation(shader.programHandle, "myTexTure");
    glUniform1i(hh, 0);
    
    GLuint texture2 = [self loadTheImage:@"awesomeface"];
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,texture2);
    glUniform1i(glGetUniformLocation(shader.programHandle, "myTexTure1"), 1);
    
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO
    
}

#pragma -mark 矩阵的使用
-(void)useJuz{
    
    
    [self setLayer];
    [self setupContext];
    [self setBuffer];
    
    Shader *shader = [[Shader alloc]init];
    NSString* verShaderPath = [[NSBundle mainBundle] pathForResource:@"VershaderJuzheng"
                                                              ofType:@"vs"];
    NSString* fragShaderPath = [[NSBundle mainBundle] pathForResource:@"Fragment2"
                                                               ofType:@"frag"];
    
    
    [shader shaderVertexPath:verShaderPath fragmentPath:fragShaderPath];
    
    [shader use];
    
    //下面我们使用纹理
    
    GLfloat vertices[] = {
        //     ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
    };
    GLuint indices[] = {
        0, 1, 3,
        1, 2, 3
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
    
    // 位置属性
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    // 颜色属性
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(3* sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    //纹理属性
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(6* sizeof(GLfloat)));
    glEnableVertexAttribArray(2);
    
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 200, 200, 200);
    
    GLuint texture1 = [self loadTheImage:@"awesomeface"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,texture1);
    GLuint hh = glGetUniformLocation(shader.programHandle, "myTexTure");
    glUniform1i(hh, 0);
    
//    GLuint texture2 = [self loadTheImage:@"wall"];
//    glActiveTexture(GL_TEXTURE1);
//    glBindTexture(GL_TEXTURE_2D,texture2);
//    glUniform1i(glGetUniformLocation(shader.programHandle, "myTexTure1"), 1);
    
    //矩阵的使用
    GLuint transFormLoc = glGetUniformLocation(shader.programHandle, "transform");
    
    //下面我们把一个第一个方法的生成的箱子逆时针旋转90度。然后缩放0.5倍，使它变成原来的一半大。
    //构建一个变换矩阵
    //为了构建一个一个矩阵，引入GLKit
    
    GLKMatrix4 position = GLKMatrix4Identity;
    //位移矩阵
    position = GLKMatrix4Translate(position, 0.5, -0.5, 0.0f);
    //旋转矩阵
    position = GLKMatrix4RotateZ(position, M_PI_2);
    //缩放矩阵
    position = GLKMatrix4Scale(position, 0.5, 0.5, 0.5);
    
    glUniformMatrix4fv(transFormLoc, 1, GL_FALSE, position.m);
    
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        [self comDoubleText];
        
        [self useJuz];
        
    }
    return self;
}


@end

