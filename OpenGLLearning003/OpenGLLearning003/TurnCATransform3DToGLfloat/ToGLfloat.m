//
//  ToGLfloat.m
//  OpenGLLearning003
//
//  Created by DengPan on 2017/12/19.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import "ToGLfloat.h"


@implementation ToGLfloat


+(GLfloat *)toValueCATransform3D:(CATransform3D)trans
{
    
    static GLfloat myValue[4*4];
    
    GLfloat transValue[] = {trans.m11,trans.m21,trans.m31,trans.m41,
         trans.m12,trans.m22,trans.m32,trans.m42,
         trans.m13,trans.m23,trans.m33,trans.m43,
         trans.m14,trans.m24,trans.m34,trans.m44
    };
    
    for (int i=0; i<15; i++) {
        
        myValue[i] = transValue[i];

    }
        
    return myValue;
    
}

GLfloat * inArray(CATransform3D *trans)
{
    
    static GLfloat myValue[4*4];

    GLfloat transValue[] = {trans->m11,trans->m21,trans->m31,trans->m41,
        trans->m12,trans->m22,trans->m32,trans->m42,
        trans->m13,trans->m23,trans->m33,trans->m43,
        trans->m14,trans->m24,trans->m34,trans->m44
    };

    for (int i=0; i<15; i++) {
        
        myValue[i] = transValue[i];
        
    }
    
    return myValue;
    
}


@end
