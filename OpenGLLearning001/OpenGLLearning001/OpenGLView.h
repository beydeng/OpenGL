//
//  OpenGLView.h
//  OpenGLLearning001
//
//  Created by DengPan on 2017/12/14.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/ES3/gl.h>


@interface OpenGLView : UIView
{
    EAGLContext *_context;
    CAEAGLLayer *_layer;
}


@end
