//
//  PCLAppDelegate.m
//  PCLady
//
//  Created by  Michael on 10/13/13.
//  Copyright (c) 2013 Michael. All rights reserved.
//

#import "PCLAppDelegate.h"
#import "Constants.h"
#import "PCLMainController.h"
#import <RennSDK/RennSDK.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import <Pinterest/Pinterest.h>
#import <ShareSDK/ShareSDK.h>
#import "WBApi.h"
#import "WXApi.h"
#import "WeiboSDK.h"

@implementation PCLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    if (onIOS7) {
        self.window.tintColor = [UIColor whiteColor];
    }

    /**
     注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
     此方法必须在启动时调用，否则会限制SDK的使用。
     **/
    [ShareSDK registerApp:@"dba1537dea9"];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"3297248239"];
    
    //如果使用服务中配置的app信息，请把初始化代码改为下面的初始化方法。
//    [ShareSDK registerApp:@"dba1537dea9" useAppTrusteeship:YES];

    [self initializePlat];
    
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    PCLMainController *mainController = [[PCLMainController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)initializePlat
{
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:@"3297248239"
                               appSecret:@"6953cda4792a3f23ba967c629b82cae9"
                             redirectUri:@"http://www.sharesdk.cn"];
//    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
//                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                             redirectUri:@"http://www.sharesdk.cn"];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wx72e4ba90dbd5e94a" wechatCls:[WXApi class]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
