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
//TODO:注意修改
#define APPID                   @"1101001001"
#define UNIVERSALLINK   @"https://www.google.com/qq_conn/1101001001"

@interface AppDelegate ()<QQApiInterfaceDelegate, TencentLoginDelegate, TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation AppDelegate

+ (AppDelegate* )shareAppDelegate{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:APPID andUniversalLink:UNIVERSALLINK andDelegate:self];
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

- (BOOL)qqAppInstalled{

    return [QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi];
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [self tencentHandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    return [self tencentHandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    
    return [self tencentHandleOpenUniversalLink:userActivity];
}

#pragma mark - 处理由手Q唤起的普通跳转请求
- (BOOL)tencentHandleOpenURL:(NSURL *)url{
    
    if([url.host isEqualToString:@"response_from_qq"]){
        
        return [QQApiInterface handleOpenURL:url delegate:self];
    }else if([url.host isEqualToString:@"qzapp"]){
    
        if([TencentOAuth CanHandleOpenURL:url]){
            return [TencentOAuth HandleOpenURL:url];
        }else{
            
            return NO;
        }
    }else{
        
        return NO;
    }
}

#pragma mark - 处理由手Q唤起的universallink跳转请求
- (BOOL)tencentHandleOpenUniversalLink:(NSUserActivity *)userActivity{
    
    if([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]){
           
       NSURL *url = userActivity.webpageURL;
       
       if(url && [TencentOAuth CanHandleOpenURL:url]){
           NSLog(@"%@", url.description);
#if BUILD_QQAPIDEMO
           //兼容[QQApiInterface handleOpenURL:delegate:]的接口回调能力
           [QQApiInterface handleOpenUniversallink:url delegate:(id<QQApiInterfaceDelegate>)[QQApiShareEntry class]];
#endif
            return [QQApiInterface handleOpenUniversallink:url delegate:self];
       }else{
           return YES;
           }
   }else{
       
       return YES;
   }
}

#pragma mark - 发起QQ分享
- (void)sendQQShareReq{
    
   QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:@"https://www.baidu.com/"] title:@"分享标题" description:@"分享内容" previewImageURL:[NSURL URLWithString:@"http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/pic/124708/cn_zh/1578366524866/framework.png"]];
   
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
   QQApiSendResultCode code = [QQApiInterface sendReq:req];//分享给QQ好友
//    QQApiSendResultCode code = [QQApiInterface SendReqToQZone:req];//分享到QQ空间
   
    //参考QQApiInterfaceObject.h文件中，QQApiSendResultCode枚举类型
    if(code == EQQAPISENDSUCESS){
        
        NSLog(@"分享成功");
    }else if(code == EQQAPIQQNOTINSTALLED){
        NSLog(@"当前设备未安装QQ应用或版本过低");
    }
}

#pragma mark - 发起登录授权
- (void)sendQQAuthReq{
    
    if([self qqAppInstalled]){
        
        NSArray* permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
        [_tencentOAuth authorize:permissions inSafari:NO];
    }else{
        
        NSLog(@"当前设备未安装QQ应用或版本过低");
    }
}

#pragma mark - TencentSessionDelegate
// 登录成功后的回调
- (void)tencentDidLogin{
    
    NSLog(@"QQ登录成功");
    [_tencentOAuth getUserInfo];//获取当前用户基本信息，调用这个方法会走- (void)getUserInfoResponse:(APIResponse *)response回调
    
    NSString *code = [_tencentOAuth getServerSideCode];//获取code
    NSLog(@"授权登录Code:%@", code);
}

// 登录失败后的回调
- (void)tencentDidNotLogin:(BOOL)cancelled{
    
    NSLog(@"QQ登录失败");
}

// 登录时网络有问题的回调
- (void)tencentDidNotNetWork{
    
    NSLog(@"QQ登录时网络有问题");
}

- (void)getUserInfoResponse:(APIResponse *)response{
    
    //获取用户基本信息
//    response.jsonResponse;//NSDictionary格式
//    response.message;//JSON String格式
    NSLog(@"%@", response.jsonResponse);
}

#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req {
    
}

//注意：微信和QQ回调方法用的是同一个，这里注意判断resp类型来区别分享来源
- (void)onResp:(id)resp{
    
    if([resp isKindOfClass:[QQBaseResp class]]){
        
        QQBaseResp *response = (QQBaseResp *)resp;
        
        if ([response.result isEqualToString:@"0"]) {
            //QQ分享成功回调
            NSLog(@"QQ分享成功回调");
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response{
    
    NSLog(@"%@", response);
}

@end
