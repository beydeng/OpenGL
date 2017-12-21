//
//  OpenGLView.m
//  OpenGLLearning004
//
//  Created by DengPan on 2017/12/21.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import "OpenGLView.h"
#import <GLKit/GLKit.h>
#import "Shader.h"


@interface OpenGLView()
{
    EAGLContext *_context;
    CAEAGLLayer *_layer;
    GLuint programHandleContent;
    Shader *shader;
    GLuint VAO;
    int i;
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
    
    //分配深度缓冲区
    GLint width,height;
    GLuint depthBuffer;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    glGenRenderbuffers(1, &depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);

}


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
    NSString* verShaderPath = [[NSBundle mainBundle] pathForResource:@"Vertex"
                                                              ofType:@"vs"];
    NSString* fragShaderPath = [[NSBundle mainBundle] pathForResource:@"Fragment"
                                                               ofType:@"frag"];
    
    
    [shader shaderVertexPath:verShaderPath fragmentPath:fragShaderPath];
    
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
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glBindTexture(GL_TEXTURE_2D, [self loadTheImage:@"2-22"]);
    
#pragma -mark 创建矩阵
    
    //1 首先创建一个模型矩阵
    //这个模型矩阵包含了平移、缩放与旋转，我们将会运用它来将对象的顶点转换到全局世界空间。让我们平移一下我们的平面，通过将其绕着x轴旋转使它看起来像放在地上一样
    //通过将顶点坐标乘以这个模型矩阵我们将该顶点坐标转换到世界坐标。我们的平面看起来就是在地板上的因此可以代表真实世界的平面。
    GLKMatrix4 model = GLKMatrix4Identity;
    model = GLKMatrix4Rotate(model, DEGREES_TO_RADIANS(-55), 1.0, 0, 0);
    
    //2 创建一个观察矩阵
    // 我们将矩阵向我们要进行移动场景的反向移动
    
    GLKMatrix4 view = GLKMatrix4Identity;
    view = GLKMatrix4Translate(view, 0.0, 0.0, -3.0);
    
    //3 家下来创建一个投影矩阵
    //我们想要在我们的场景中使用透视投影
    
    GLKMatrix4 projection = GLKMatrix4Identity;
    projection = GLKMatrix4MakePerspective(DEGREES_TO_RADIANS(45), self.frame.size.width/self.frame.size.height, 0.1f, 100.0f);
    
    //接下来我们将它们传入着色器
    //注意着色器中是从右向左进行乘法运算
    
    GLuint modelLoc = glGetUniformLocation(shader.programHandle,"model");
    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, model.m);
    
    GLuint modelView = glGetUniformLocation(shader.programHandle,"view");
    glUniformMatrix4fv(modelView, 1, GL_FALSE, view.m);
    
    GLuint modelpro = glGetUniformLocation(shader.programHandle,"projection");
    glUniformMatrix4fv(modelpro, 1, GL_FALSE, projection.m);
    
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO
    
}

#pragma -mark 下面我们画一个立方体

-(void)creatABox{
    
    [self setLayer];
    [self setupContext];
    [self setBuffer];
    
    shader = [[Shader alloc]init];
    NSString* verShaderPath = [[NSBundle mainBundle] pathForResource:@"Vertex"
                                                              ofType:@"vs"];
    NSString* fragShaderPath = [[NSBundle mainBundle] pathForResource:@"Fragment"
                                                               ofType:@"frag"];
    
    
    [shader shaderVertexPath:verShaderPath fragmentPath:fragShaderPath];
    
    [shader use];

    float vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    
    // 1. 绑定顶点数组对象
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);
    
    // 2. 把我们的顶点数组复制到一个顶点缓冲中，供OpenGL使用
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 位置属性
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);

    //纹理属性
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)(3* sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [self loadTheImage:@"2-22"]);
    glUniform1i(glGetUniformLocation(shader.programHandle, "ourTexTure"), 0);
    glActiveTexture(GL_TEXTURE1);
    
    //这里是开启深度测试，这在其他地方也行是好使的，但是在IOS直接使用并不能出现，所以在这里，我们用另一种方法。
    //glEnable(GL_DEPTH_TEST);
    
    glClearColor(0, 1, 1, 1);
    glEnable(GL_DEPTH_TEST);
    
    [self initTime];
    
    //[self display];
    
}

//添加循环改变
-(void)initTime
{
    
    CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(display)];
    [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void)display
{
    i++;
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLKMatrix4 model = GLKMatrix4Identity;
    model = GLKMatrix4Rotate(model,i*DEGREES_TO_RADIANS(1), 0.5, 1.0, 0);
    
    //2 创建一个观察矩阵
    // 我们将矩阵向我们要进行移动场景的反向移动
    
    GLKMatrix4 view = GLKMatrix4Identity;
    view = GLKMatrix4Translate(view, 0.0, 0.0, -6.0);
    
    //3 家下来创建一个投影矩阵
    //我们想要在我们的场景中使用透视投影
    
    GLKMatrix4 projection = GLKMatrix4Identity;
    projection = GLKMatrix4MakePerspective(DEGREES_TO_RADIANS(45), self.frame.size.width/self.frame.size.height, 0.1f, 100.0f);
    
    //接下来我们将它们传入着色器
    //注意着色器中是从右向左进行乘法运算
    
    GLuint modelLoc = glGetUniformLocation(shader.programHandle,"model");
    
    
    //glUniformMatrix4fv(modelLoc, 1, GL_FALSE, model.m);
    
    GLuint modelView = glGetUniformLocation(shader.programHandle,"view");
    glUniformMatrix4fv(modelView, 1, GL_FALSE, view.m);
    
    GLuint modelpro = glGetUniformLocation(shader.programHandle,"projection");
    glUniformMatrix4fv(modelpro, 1, GL_FALSE, projection.m);
    
    glBindVertexArray(VAO);

    //创建一个box
    /*
    glDrawArrays(GL_TRIANGLES, 0, 36);
    */
    
    //创建10个box
    [self createMoreBox:modelLoc];

    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO
    
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    i++;
    
    [self display];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    i++;
    
    [self display];
    
}

#pragma -mark 创建更多箱子

-(void)createMoreBox:(GLuint )modelLoc{
    
    //让我们为每个立方体定义一个转换向量来指定它在世界空间的位置。我们将要在数组中定义10个立方体位置向量
    
    
    GLKVector3 vube[]={
        
        GLKVector3Make( 0.0f,  0.0f,  0.0f),
        GLKVector3Make( 2.0f,  5.0f, -15.0f),
        GLKVector3Make(-1.5f, -2.2f, -2.5f),
        GLKVector3Make(-3.8f, -2.0f, -12.3f),
        GLKVector3Make( 2.4f, -0.4f, -3.5f),
        GLKVector3Make(-1.7f,  3.0f, -7.5f),
        GLKVector3Make( 1.3f, -2.0f, -2.5f),
        GLKVector3Make( 1.5f,  2.0f, -2.5f),
        GLKVector3Make( 1.5f,  0.2f, -1.5f),
        GLKVector3Make(-1.3f,  1.0f, -1.5f)
        
    };
    
    //在循环中，我们调用glDrawArrays10次，在我们开始渲染之前每次传入一个不同的模型矩阵到顶点着色器中。
    
    for (GLuint i=0; i<10; i++) {
        
        GLKMatrix4 model = GLKMatrix4Identity;
        GLKVector3 vec = vube[i];
        
        model = GLKMatrix4Translate(model, vec.x, vec.y, vec.z);
        
        GLfloat angle = 20.0f*i;
        
        model = GLKMatrix4Rotate(model, DEGREES_TO_RADIANS(angle), 1.0f, 0.3f, 0.5f);
        
        glUniformMatrix4fv(modelLoc, 1, GL_FALSE,model.m);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
    }
    
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //[self createTexure];
        i = 1;
        [self creatABox];
        
    }
    return self;
}



@end
