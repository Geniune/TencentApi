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
#define APPID                   @""
#define UNIVERSALLINK   @""

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
    
    if([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]){
    
        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:@"https://www.baidu.com/"] title:@"分享标题" description:@"分享内容" previewImageURL:[NSURL URLWithString:@"http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/pic/124708/cn_zh/1578366524866/framework.png"]];
       
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        
        QQApiSendResultCode code = [QQApiInterface sendReq:req];//分享给QQ好友
//        QQApiSendResultCode code = [QQApiInterface SendReqToQZone:req];//分享到QQ空间
       
        //参考QQApiInterfaceObject.h文件中QQApiSendResultCode枚举类型
        if(code == EQQAPISENDSUCESS){
            NSLog(@"分享成功");
        }
    }else{
        
        NSLog(@"当前设备未安装QQ应用或版本过低");
    }
}

#pragma mark - 发起登录授权
- (void)sendQQAuthReq{
    
    if([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]){
        
        NSArray* permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
        [_tencentOAuth authorize:permissions];

    }else{
        
        NSLog(@"当前设备未安装QQ应用或版本过低");
    }
}

#pragma mark - TencentLoginDelegate
// 登录成功后的回调
- (void)tencentDidLogin{
    
    NSLog(@"授权登录成功");
    
    //TODO:开发者可以选择下面任意一种方式来获取UnionID、OpenID、用户基本信息
    
    //方法一、用AccessToken调用OpenAPI（通常由后端服务器完成）
    NSString *accessToken = [_tencentOAuth accessToken];//注意：AccessToken是会过期的
    NSDate *expirationDate = [_tencentOAuth expirationDate];//Access_Token过期时间
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    
    NSLog(@"AccessToken：%@", accessToken);
    NSLog(@"ExpirationDate：%@", [dateFormatter stringFromDate:expirationDate]);
    
    //获取UnionID和OpenID，GET请求：https://graph.qq.com/oauth2.0/me?access_token=[Access_Token]&unionid=1
    //获取用户基本信息，GET请求：https://graph.qq.com/user/get_user_info?access_token=[Access_Token]&oauth_consumer_key=[Client_ID]&openid=[Open_ID]
    
    
    //方法二、直接在App前端获取
    
    //获取OpenID
    NSLog(@"OpenID：%@", [_tencentOAuth getUserOpenID]);

    //获取UnionID，会走-didGetUnionID回调函数
    if([_tencentOAuth RequestUnionId]){
        NSLog(@"UnionID获取成功");
    }

    //获取用户基本信息，会走getUserInfoResponse:回调函数
    if([_tencentOAuth getUserInfo]){
        NSLog(@"用户基本信息获取成功");
    }
}

// 登录失败后的回调
- (void)tencentDidNotLogin:(BOOL)cancelled{
    
    NSLog(@"QQ登录失败");
}

// 登录时网络有问题的回调
- (void)tencentDidNotNetWork{
    
    NSLog(@"QQ登录时网络有问题");
}

//获取UnionID回调
- (void)didGetUnionID{

    NSLog(@"UnionID：%@", _tencentOAuth.unionid);
}

//获取用户基本信息回调
- (void)getUserInfoResponse:(APIResponse *)response{
    
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
