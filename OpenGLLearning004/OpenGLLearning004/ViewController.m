//
//  ViewController.m
//  OpenGLLearning004
//
//  Created by DengPan on 2017/12/20.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    GLKMatrix4MakePerspective(<#float fovyRadians#>, <#float aspect#>, <#float nearZ#>, <#float farZ#>)
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
