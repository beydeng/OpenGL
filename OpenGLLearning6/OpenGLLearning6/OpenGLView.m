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
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>
#import "Shader.h"

#define lightPos GLKVector3Make(1.2, 1.0, 2.0)

@interface OpenGLView()
{
    EAGLContext *_context;
    CAEAGLLayer *_layer;
    GLuint programHandleContent;
    int i;
    Shader *shader;
    GLuint VAO,VBO;
    
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

#pragma -mark 创建光照场景
//我们将通过模拟真实世界中广泛存在的光照和颜色现象来创建有趣的视觉效果
//首先我们需要一个物体来投光(Cast the light)，我们将无耻地使用前面教程中的立方体箱子。我们还需要一个物体来代表光源，它代表光源在这个3D空间中的确切位置
-(void)createTheSunScene
{
    //创建一个没有纹理的箱子
    
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
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f

    };

    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);
    
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 位置属性
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);

    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glClearColor(0, 1, 1, 1);
    glEnable(GL_DEPTH_TEST);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLKMatrix4 view = GLKMatrix4Identity;
    view = GLKMatrix4Translate(view, 0.0, 0.0, -10.0);

    GLKMatrix4 model = GLKMatrix4Identity;
    model = GLKMatrix4Rotate(model, DEGREES_TO_RADIANS(-55), 1.0, 0, 0);

    GLKMatrix4 projection = GLKMatrix4Identity;
    projection = GLKMatrix4MakePerspective(DEGREES_TO_RADIANS(45), self.frame.size.width/self.frame.size.height, 0.1f, 100.0f);

    GLuint modelLoc = glGetUniformLocation(shader.programHandle,"model");
    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, model.m);
    
    GLuint modelView = glGetUniformLocation(shader.programHandle,"view");
    glUniformMatrix4fv(modelView, 1, GL_FALSE, view.m);
    
    GLuint modelpro = glGetUniformLocation(shader.programHandle,"projection");
    glUniformMatrix4fv(modelpro, 1, GL_FALSE, projection.m);
    
    GLint objectColorLoc = glGetUniformLocation(shader.programHandle, "objectColor");
    GLint lightColorLoc  = glGetUniformLocation(shader.programHandle, "lightColor");
    glUniform3f(objectColorLoc, 1.0f, 0.5f, 0.31f);// 我们所熟悉的珊瑚红
    glUniform3f(lightColorLoc,  1.0f, 1.0f, 1.0f);
    
    GLint lightPosLoc = glGetUniformLocation(shader.programHandle, "lightPos");
    glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z);
    
    
    glBindVertexArray(VAO);

    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    [self createTheLightVAO];
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0); //解绑VAO
    
}

//因为我们还要创建一个表示灯(光源)的立方体，所以我们还要为这个灯创建一个特殊的VAO。当然我们也可以让这个灯和其他物体使用同一个VAO然后对他的model(模型)矩阵做一些变换，然而接下来的教程中我们会频繁地对顶点数据做一些改变并且需要改变属性对应指针设置，我们并不想因此影响到灯(我们只在乎灯的位置)，因此我们有必要为灯创建一个新的VAO。
-(void)createTheLightVAO
{
    
    GLuint lightVAO;
    glGenVertexArrays(1, &lightVAO);
    glBindVertexArray(lightVAO);
    // 只需要绑定VBO不用再次设置VBO的数据，因为容器(物体)的VBO数据中已经包含了正确的立方体顶点数据
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    // 设置灯立方体的顶点属性指针(仅设置灯的顶点数据)
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    glBindVertexArray(0);
    
    //下面我们只需要修改片段着色器就可以
    //这个片段着色器接受两个分别表示物体颜色和光源颜色的uniform变量
    
    Shader *lightShader = [[Shader alloc]init];
    
    NSString* verShaderPath = [[NSBundle mainBundle] pathForResource:@"LightVertex"
                                                              ofType:@"vs"];
    NSString* fragShaderPath = [[NSBundle mainBundle] pathForResource:@"LightFragment"
                                                               ofType:@"frag"];

    [lightShader shaderVertexPath:verShaderPath fragmentPath:fragShaderPath];
    
    [lightShader use];
    
    GLKMatrix4 view = GLKMatrix4Identity;
    view = GLKMatrix4Translate(view, 0.0, 0.0, -10.0);
    
    GLKMatrix4 model = GLKMatrix4Identity;
    model = GLKMatrix4Rotate(model, DEGREES_TO_RADIANS(-55), 1.0, 0, 0);
    model = GLKMatrix4Translate(model, lightPos.x, lightPos.y, lightPos.z);
    model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2);
    
    GLKMatrix4 projection = GLKMatrix4Identity;
    projection = GLKMatrix4MakePerspective(DEGREES_TO_RADIANS(45), self.frame.size.width/self.frame.size.height, 0.1f, 100.0f);
    
    GLuint modelLoc = glGetUniformLocation(lightShader.programHandle,"model");
    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, model.m);
    
    GLuint modelView = glGetUniformLocation(lightShader.programHandle,"view");
    glUniformMatrix4fv(modelView, 1, GL_FALSE, view.m);
    
    GLuint modelpro = glGetUniformLocation(lightShader.programHandle,"projection");
    glUniformMatrix4fv(modelpro, 1, GL_FALSE, projection.m);
    
    glBindVertexArray(lightVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0);
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createTheSunScene];
        
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
