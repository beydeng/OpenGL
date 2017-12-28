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


@interface OpenGLView()
{
    EAGLContext *_context;
    CAEAGLLayer *_layer;
    GLuint programHandleContent;
    int i;
    Shader *shader;
    GLuint VAO;
    GLKVector3 cameraPos,cameraFront,cameraUp;
    
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
    glBindTexture(GL_TEXTURE_2D, [shader loadTheImage:@"logo2"]);
    glUniform1i(glGetUniformLocation(shader.programHandle, "ourTexTure"), 0);
    glActiveTexture(GL_TEXTURE1);
    
    //这里是开启深度测试，这在其他地方也行是好使的，但是在IOS直接使用并不能出现，所以在这里，我们用另一种方法。
    //glEnable(GL_DEPTH_TEST);
    
    glClearColor(0, 1, 1, 1);
    glEnable(GL_DEPTH_TEST);
    
#pragma -mark 自动旋转放开并注销下面的self display

    //[self initTime];
    
#pragma -mark 启动自动移动
    [self display];
    
}

//添加循环改变
-(void)initTime
{
    
//    CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(display)];
//    [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(display) userInfo:nil repeats:YES];
    
}

-(void)display
{
    i++;
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLKMatrix4 model = GLKMatrix4Identity;
    model = GLKMatrix4Rotate(model,i*DEGREES_TO_RADIANS(1), 0.5, 1.0, 0);
    
#pragma -mark 自动旋转
    //2 创建一个LookAt矩阵
    //x和z表示一个在一个圆圈上的一点，我们会使用它作为摄像机的位置。通过重复计算x和y坐标，遍历所有圆圈上的点，这样摄像机就会绕着场景旋转了。我们预先定义这个圆圈的半径，使用glfwGetTime函数不断增加它的值，在每次渲染迭代创建一个新的观察矩阵
    /*
    GLfloat radius = 10.0f;
    
    GLfloat camX = sin(i) * radius;
    GLfloat camZ = cos(i) * radius;
    
    GLKMatrix4 view = GLKMatrix4Identity;
    view = GLKMatrix4MakeLookAt(camX, 0, camZ, 0, 0, 0, 0, 1, 0);
    */
    
#pragma -mark 手动操作
    
    //3 家下来创建一个投影矩阵
    //我们想要在我们的场景中使用透视投影
    
    GLKVector3 v = GLKVector3Add(cameraPos, cameraFront);
    
    GLKMatrix4 view = GLKMatrix4Identity;
    view = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z, v.x, v.y, v.z, cameraUp.x, cameraUp.y, cameraUp.z);
        
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

-(void)init4Button
{
    
    NSArray *arr = @[@"w",@"a",@"s",@"d"];
    
    for (int i=0; i<4; i++) {
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50*i+5*i, 50, 50, 30)];
        
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnDown:)];
        longPress.minimumPressDuration = 0.1;
        [btn addGestureRecognizer:longPress];
        
        btn.backgroundColor = [UIColor yellowColor];
        
        [self addSubview:btn];
    }
    
}

-(void)btnDown:(UILongPressGestureRecognizer *)sender
{
    
    //目前我们的移动速度是个常量。看起来不错，但是实际情况下根据处理器的能力不同，有的人在同一段时间内会比其他人绘制更多帧。也就是调用了更多次do_movement函数。每个人的运动速度就都不同了。当你要发布的你应用的时候，你必须确保在所有硬件上移动速度都一样。
    //图形和游戏应用 通常会有一个跟踪变量deltaTime，它储存渲染上一帧所用的时间
    //图形和游戏应用通常有回跟踪一个deltaTime变量，它储存渲染上一帧所用的时间。我们把所有速度都去乘以deltaTime值。当我们的deltaTime变大时意味着上一帧渲染花了更多时间，所以这一帧使用这个更大的deltaTime的值乘以速度，会获得更高的速度，这样就与上一帧平衡了。使用这种方法时，无论你的机器快还是慢，摄像机的速度都会保持一致，这样每个用户的体验就都一样了。
    //在shader中 我们用宏定义来获取没一帧所用的时间
    
    TICK;
    
    //GLfloat cameraSpeed = 0.05f;
    
    GLfloat cameraSpeed = 5.0f*TOCK*10000;
    
    UIButton *btn = (UIButton *)sender.view;
    
    if ([btn.titleLabel.text isEqualToString:@"w"]) {
        
//        cameraPos += cameraSpeed * cameraFront;
        GLKVector3 v = GLKVector3MultiplyScalar(cameraFront, cameraSpeed); //cameraSpeed * cameraFront
        
        cameraPos = GLKVector3Add(cameraPos, v);
        
    }
    else if ([btn.titleLabel.text isEqualToString:@"s"]) {
        
    //cameraPos -= cameraSpeed * cameraFront;
        
        GLKVector3 v = GLKVector3SubtractScalar(cameraFront,cameraSpeed);
        cameraPos = GLKVector3Subtract(cameraPos,v);
        
    }
    else if ([btn.titleLabel.text isEqualToString:@"a"]) {
        
        //glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed
        
        GLKVector3 v = GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp)), cameraSpeed);
        
        cameraPos = GLKVector3Subtract(cameraPos,v);
        
    }
    else if ([btn.titleLabel.text isEqualToString:@"d"]) {
        
        //cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed
        
        GLKVector3 v = GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp)), cameraSpeed);
        cameraPos = GLKVector3Add(cameraPos, v);

    }
    
        
    [self creatABox];

    
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        cameraPos = GLKVector3Make(0.0f, 0.0f, 3.0f);
        cameraFront = GLKVector3Make(0.0f, 0.0f, -1.0f);
        cameraUp = GLKVector3Make(0.0f, 1.0f, 0.0f);
        
        [self creatABox];
        
        [self init4Button];
        
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
