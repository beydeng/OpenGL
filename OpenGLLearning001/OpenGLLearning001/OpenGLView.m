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


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
        
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
