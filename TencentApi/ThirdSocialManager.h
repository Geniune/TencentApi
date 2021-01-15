//
//  ThirdSocialManager.h
//  TencentApi
//
//  Created by Geniune on 2021/1/13.
//  Copyright © 2021 Geniune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define SOCIALMANAGER [ThirdSocialManager sharedInstance]

@interface ThirdSocialManager : NSObject

+ (ThirdSocialManager *)sharedInstance;

- (void)setupSDK;

- (BOOL)handleOpenURL:(NSURL *)url;
- (BOOL)handleUniversalLink:(NSUserActivity *)userActivity;

- (BOOL)isWXInstall;
- (void)WXAuth;
- (void)WXShareWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)shareUrl scene:(int)scene;    //scene 0:QQ好友 1:QQ空间

- (BOOL)isQQInstall;
- (void)QQAuth;
- (void)QQShareWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)shareUrl scene:(int)scene;    //scene 0:微信好友 1:朋友圈

@end


