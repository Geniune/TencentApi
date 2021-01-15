//
//  HomePageViewController.m
//  WXTest
//
//  Created by Apple on 2020/5/18.
//  Copyright © 2020 Geniune. All rights reserved.
//

#import "HomePageViewController.h"
#import "ThirdSocialManager.h"

@interface HomePageViewController ()

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"第三方授权登录";
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 150, 150, 38)];
    [btn1 setTitle:@"微信" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(wxAuthAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 150, 38)];
    [btn2 setTitle:@"QQ" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(qqAuthAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

- (void)wxAuthAction:(id)sender{
    
    [SOCIALMANAGER WXAuth];
}

- (void)qqAuthAction:(id)sender{
        
    [SOCIALMANAGER QQAuth];
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
