//
//  Shader.h
//  OpenGLLearning002
//
//  Created by DengPan on 2017/12/18.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface Shader : NSObject

@property (nonatomic,assign) GLuint programHandle;


-(void)shaderVertexPath:(NSString *)vertexPath fragmentPath:(NSString *)fragmentPath;

-(void)use;

-(GLuint)loadTheImage:(NSString *)imageName;


@end
