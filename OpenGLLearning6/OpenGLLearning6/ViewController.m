//
//  ViewController.m
//  OpenGLLearning6
//
//  Created by DengPan on 2017/12/28.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    OpenGLView *view = [[OpenGLView alloc]initWithFrame:self.view.frame];
    
    [self.view addSubview:view];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
