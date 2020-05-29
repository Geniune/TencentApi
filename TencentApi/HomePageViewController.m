//
//  HomePageViewController.m
//  WXTest
//
//  Created by Apple on 2020/5/18.
//  Copyright © 2020 Geniune. All rights reserved.
//

#import "HomePageViewController.h"
#import "AppDelegate.h"

@interface HomePageViewController ()

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 150, 38)];
    [btn1 setTitle:@"分享给QQ好友" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 150, 38)];
    [btn2 setTitle:@"授权登录" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(authAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

- (void)shareAction:(id)sender{
    
     [[AppDelegate shareAppDelegate] sendQQShareReq];
}

- (void)authAction:(id)sender{
        
    [[AppDelegate shareAppDelegate] sendQQAuthReq];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
