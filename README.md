# TencentOpenApi

如何配置Universal Links，请看：https://www.jianshu.com/p/10ce6aa70e61

Tencent开放平台配置：https://www.jianshu.com/p/ed8e649810d5


update at 2020-05-29

首先需要去QQ开放平台申请移动应用，保证当前移动应用为审核通过状态

接下来再按下面步骤修改对应Xcode工程/服务器配置：
1. 修改工程中Bundle Identifier
2. 将AppDelegate.m中的宏定义``APPID``、``UNIVERSALLINK``（APPID和UNIVERSALLINK，对应在QQ开放平台中申请的APP ID和Universal Link）
3. 在URL Types中，将identifier``tencentopenapi``对应的URL Schemes修改为``tencent+APPID``
4. 修改Associated Domains为applinks:开头，后面加上你配置.well-known/apple-app-site-association文件所在服务器host，例如``applinks:www.google.com``
5. 服务器.well-known/apple-app-site-association文件对应的json，path添加一个字符串：``/qq_conn/appid``（appid是在QQ开放平台中申请的APP ID）
6. 保证真机测试，要求搭载系统iOS 12+，手机QQ版本8.1.3+

注意：使用Universal Links跳转需要前往苹果开发者官网配置Associated Doamins，若之前未打开届时会导致与其Bundle Identifier相关的所有描述文件全部失效，必须重新配置描述文件并安装到本机后方可调试
