//
//  ViewController.m
//  OpenGLLearning001
//
//  Created by DengPan on 2017/12/14.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    OpenGLView *openGl = [[OpenGLView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:openGl];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
