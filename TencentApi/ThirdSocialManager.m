//
//  ThirdSocialManager.m
//  TencentApi
//
//  Created by Geniune on 2021/1/13.
//  Copyright © 2021 Geniune. All rights reserved.
//

#import "ThirdSocialManager.h"

#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define Tencent_APP_ID                   @"YOUR_APP_ID"
#define Tencent_UNIVERSAL_LINK   @"YOUR_UNIVERSAL_LINK"

#define Wechat_APP_ID                   @"YOUR_APP_ID"
#define Wechat_UNIVERSAL_LINK   @"YOUR_UNIVERSAL_LINK"

@interface ThirdSocialManager ()<TencentSessionDelegate, WXApiDelegate, QQApiInterfaceDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation ThirdSocialManager

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

+ (ThirdSocialManager *)sharedInstance{
    
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        
        return [[self alloc] init];
    });
}

- (instancetype)init{
    
    self = [super init];
    
    if(self){
        
    }
    
    return self;
}

- (void)setupSDK{
    
    //初始化Tencent OpenSDK
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:Tencent_APP_ID andUniversalLink:Tencent_UNIVERSAL_LINK andDelegate:self];
    
//    [QQApiInterface startLogWithBlock:^(NSString *log) {
//        NSLog(@"%@", log);
//    }];
    
    //初始化Wechat OpenSDK
    [WXApi registerApp:Wechat_APP_ID universalLink:Wechat_UNIVERSAL_LINK];
    
//    [WXApi startLogByLevel:WXLogLevelNormal logBlock:^(NSString * _Nonnull log) {
//        NSLog(@"%@", log);
//    }];
    
    //在发布版本中关闭log
    [QQApiInterface stopLog];
    [WXApi stopLog];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    
    if(url){
        NSLog(@"%@", url.scheme);
        if([url.scheme isEqualToString:Wechat_APP_ID]){
            
            return [WXApi handleOpenURL:url delegate:self];
        }
        
        if([url.scheme isEqualToString:[NSString stringWithFormat:@"tencent%@", Tencent_APP_ID]]){
            
            [QQApiInterface handleOpenURL:url delegate:self];
           return [TencentOAuth HandleOpenURL:url];
        }
    }
    
    return NO;
}

- (BOOL)handleUniversalLink:(NSUserActivity *)userActivity{
    
    NSURL *url = userActivity.webpageURL;
    
    if(url){
        NSLog(@"%@", url.scheme);
        if([TencentOAuth CanHandleUniversalLink:url]){
            [QQApiInterface handleOpenUniversallink:url delegate:self];
            return [TencentOAuth HandleUniversalLink:url];
        }else{
            return [WXApi handleOpenUniversalLink:userActivity delegate:self];
        }
    }
        
    return NO;
}

- (BOOL)isQQInstall{
    
    BOOL installed = [QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi];
    
    if(!installed){
        NSLog(@"当前设备未安装QQ应用或版本过低");
    }

    return installed;
}

- (void)QQAuth{

    if([self isQQInstall]){
        
        NSArray* permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];//移动端获取用户信息
        _tencentOAuth.authShareType = AuthShareType_QQ;
        _tencentOAuth.authMode = kAuthModeServerSideCode; //授权方式使用Server Side Code
        [_tencentOAuth authorize:permissions];
    }
}

- (void)QQShareWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)shareUrl scene:(int)scene{
    
    //用于分享图片内容的对象
    if([self isQQInstall]){
        
        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:shareUrl] title:title description:description previewImageData:UIImageJPEGRepresentation(image, 1.0f)];
        
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];

        switch (scene) {
            case 0:
            {
                [QQApiInterface sendReq:req];
            }
                break;
            case 1:
            {
                [QQApiInterface SendReqToQZone:req];
            }
                break;
                
            default:
            break;
        }
    }
}

- (BOOL)isWXInstall{
    
    BOOL installed = [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
    
    if(!installed){
        NSLog(@"当前设备未安装微信应用或版本过低");
    }
    
    return installed;
}

- (void)WXAuth{

    if([self isWXInstall]){//判断用户是否已安装微信App
        
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.state = @"wx_oauth_authorization_state";//用于保持请求和回调的状态，授权请求或原样带回
        req.scope = @"snsapi_userinfo";//授权作用域：获取用户个人信息
        
        [WXApi sendReq:req completion:^(BOOL success) {
            
            NSLog(@"唤起微信:%@", success ? @"成功" : @"失败");
        }];
    }
}

//分享图片
- (void)WXShareWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)shareUrl scene:(int)scene{
    
    if([self isWXInstall]){
        
        SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
        sendReq.bText = NO;//不使用文本信息
        sendReq.scene = scene;//0 = 好友列表 1 = 朋友圈 2 = 收藏
        
        //创建分享内容对象
        WXMediaMessage *urlMessage = [WXMediaMessage message];
        urlMessage.title = title;//标题
        urlMessage.description = description;//描述
        [urlMessage setThumbImage:image];//设置图片
        
        //创建多媒体对象
        WXWebpageObject *webObj = [WXWebpageObject object];
        webObj.webpageUrl = shareUrl;//链接
        
        //完成发送对象实例
        urlMessage.mediaObject = webObj;
        sendReq.message = urlMessage;
        
        //发送分享信息
        [WXApi sendReq:sendReq completion:^(BOOL success) {
            
            NSLog(@"唤起微信:%@", success ? @"成功" : @"失败");
        }];
    }
}

#pragma mark - TencentLoginDelegate第三方应用实现登录的回调协议
// 登录成功后的回调
- (void)tencentDidLogin{
    
    NSString *code = [_tencentOAuth getServerSideCode];
    [self showAlert:@"QQ Authorization" message:code];
}

// 登录失败后的回调
- (void)tencentDidNotLogin:(BOOL)cancelled{
    
    NSLog(@"QQ登录失败");
}

// 登录时网络有问题的回调
- (void)tencentDidNotNetWork{
    
    NSLog(@"QQ登录时网络有问题");
}

#pragma mark - WXApiDelegate
- (void)onReq:(QQBaseReq *)req {
    
}

//注意：WXApiDelegate、QQApiInterfaceDelegate都会走这个回调
- (void)onResp:(id)resp{

    if([resp isKindOfClass:[SendAuthResp class]]){
        
        SendAuthResp *req = (SendAuthResp *)resp;
        if([req.state isEqualToString:@"wx_oauth_authorization_state"]){//微信授权成功

            NSString *code = req.code;
            [self showAlert:@"WX Authorization" message:code];
        }
    }else if([resp isKindOfClass:[SendMessageToWXResp class]]){
     
        SendMessageToWXResp *req = (SendMessageToWXResp *)resp;
        
        if(req.errCode == WXSuccess){
            //原先的cancel和success都已统一为success事件，因此开发者将无法获知用户是否分享完成
            NSLog(@"微信分享成功");
        }
    }else if([resp isKindOfClass:[SendMessageToQQResp class]]){
        
        SendMessageToQQResp *req = (SendMessageToQQResp *)resp;
        
        if ([req.result isEqualToString:@"0"]) {
            NSLog(@"QQ分享成功");
        }
    }
}

//处理QQ在线状态的回调
- (void)isOnlineResponse:(NSDictionary *)response{
    
    
}

- (void)showAlert:(NSString *)title message:(NSString *)message{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Cancel Action");
        }];
    [alertController addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
