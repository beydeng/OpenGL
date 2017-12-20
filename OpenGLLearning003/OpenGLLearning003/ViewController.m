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
    
//    [self initTheVIew];

}

-(void)initTheVIew
{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 100, 100, 100)];
    view.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:view];
    
    CATransform3D trans = CATransform3DIdentity;
    trans = CATransform3DRotate(trans, M_PI_4, 0, 0, -1);
    trans = CATransform3DScale(trans, 0.5, 0.5, 0.5);
        
    [view.layer setTransform:trans];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
