//
//  ToGLfloat.h
//  OpenGLLearning003
//
//  Created by DengPan on 2017/12/19.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <QuartzCore/QuartzCore.h>

@interface ToGLfloat : NSObject


+(GLfloat *)toValueCATransform3D:(CATransform3D)trans;

GLfloat * inArray(CATransform3D *trans);


@end
