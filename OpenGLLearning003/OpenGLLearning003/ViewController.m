//
//  ViewController.m
//  OpenGLLearning003
//
//  Created by DengPan on 2017/12/18.
//  Copyright © 2017年 www.Beydeng.com. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    OpenGLView *open = [[OpenGLView alloc]initWithFrame:self.view.frame];
    
    [self.view addSubview:open];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
