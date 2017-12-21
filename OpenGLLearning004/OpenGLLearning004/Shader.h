//
//  Shader.h
//  OpenGLLearning002
//
//  Created by DengPan on 2017/12/18.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface Shader : NSObject

@property (nonatomic,assign) GLuint programHandle;


-(void)shaderVertexPath:(NSString *)vertexPath fragmentPath:(NSString *)fragmentPath;

-(void)use;

@end
