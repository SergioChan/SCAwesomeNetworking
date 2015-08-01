//
//  ViewController.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ViewController.h"
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()
@property (strong, nonatomic) ANOperation *test_operation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth - 60.0f)/2.0f, (ScreenHeight - 60.0f)/2.0f, 60.0f, 60.0f)];
    [btn setTitle:@"Push" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    btn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:btn];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)btnPressed:(id)sender
{
    [[ANManager sharedInstance] testRequestCompletion:^{
        NSLog(@"completed!");
    } success:^(id object, ...) {
        NSLog(@"success!%@",object);
    } failure:^(NSError *error) {
        NSLog(@"error!");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
