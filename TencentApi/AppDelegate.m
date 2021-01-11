//
//  AppDelegate.m
//  TencentApi
//
//  Created by Apple on 2020/5/26.
//  Copyright © 2020 Geniune. All rights reserved.
//

#import "AppDelegate.h"
#import "HomePageViewController.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//腾讯开发平台http://open.qq.com/
//TODO:注意修改APPID和UNIVERSALLINK
#define APP_ID                   @"101923149"
#define UNIVERSAL_LINK   @"https://www.hongyantu.com/qq_conn/101923149"

@interface AppDelegate ()<TencentLoginDelegate, TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation AppDelegate

+ (AppDelegate* )shareAppDelegate{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:APP_ID andUniversalLink:UNIVERSAL_LINK andDelegate:self];
    if(_tencentOAuth){
        NSLog(@"Tencent openSDK初始化成功");
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    HomePageViewController *VC = [[HomePageViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options{
    
    if([TencentOAuth CanHandleOpenURL:url]){
               
       return [TencentOAuth HandleOpenURL:url];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    
    if([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
     
        NSURL *url = userActivity.webpageURL;
        if(url && [TencentOAuth CanHandleUniversalLink:url]) {
            
            return [TencentOAuth HandleUniversalLink:url];
        }
    }
    
    return YES;
}

#pragma mark - 发起登录授权
- (void)sendQQAuthReq{

    if([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]){
        
        NSArray* permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];//移动端获取用户信息
        _tencentOAuth.authShareType = AuthShareType_QQ;//进行第三方在授权登录/分享时，选择 QQ（若要选择TIM，则替换为：AuthShareType_TIM）
        _tencentOAuth.authMode = kAuthModeServerSideCode; //授权方式使用Server Side Code
        [_tencentOAuth authorize:permissions];
    }else{

        NSLog(@"当前设备未安装QQ应用或版本过低");
    }
}

#pragma mark - TencentLoginDelegate
// 登录成功后的回调
- (void)tencentDidLogin{
    
    NSLog(@"授权登录成功");
    
    //注意，区分两种授权模式：
    
    //1.Server Side Code Mode:
    NSString *code = [_tencentOAuth getServerSideCode];
    NSLog(@"Authorization Code：%@", code);
    
    //2.Client Side Token Mode:
    NSString *token = [_tencentOAuth accessToken];
    NSLog(@"Access Token：%@", token);
}

// 登录失败后的回调
- (void)tencentDidNotLogin:(BOOL)cancelled{
    
    NSLog(@"QQ登录失败");
}

// 登录时网络有问题的回调
- (void)tencentDidNotNetWork{
    
    NSLog(@"QQ登录时网络有问题");
}

@end
