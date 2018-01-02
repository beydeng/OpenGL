//
//  BeydengOpenGLView.h
//  LearnOpenGLESWithGPUImage
//
//  Created by Beydeng on 17/10/10.
//  Copyright © 2017年 Beydeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface BeydengOpenGLView : UIView


@property (nonatomic , assign) BOOL isFullYUVRange;

- (void)setupGL;
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
