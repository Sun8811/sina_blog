//
//  SunAppDelegate.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunAppDelegate.h"
#import "SunSinaWeiboDelegate.h"
@implementation SunAppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //判断是否是第一次的登陆
    if (![NSUD boolForKey:kEverLaunched]) {
        [NSUD setBool:YES forKey:kEverLaunched];
        [NSUD setBool:YES forKey:kFirstLaunched];
    }else
    {
        [NSUD setBool:NO forKey:kFirstLaunched];
    }
    [NSUD synchronize];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SunSinaWeiboDelegate *sinaWeiboDelegate =[[SunSinaWeiboDelegate alloc]init];
    _sinaBlog =[[SinaWeibo alloc]initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:sinaWeiboDelegate];
    
    //从沙盒里面取数据
    NSDictionary *sinaInfo =[NSUD objectForKey:kSinaWeiboAuthData];
    if ([sinaInfo objectForKey:kAuthAccessTokenKey]&&[sinaInfo objectForKey:kAuthUserIDKey]&&[sinaInfo objectForKey:kAuthExpirationDateKey]
        ) {
        _sinaBlog.accessToken =[sinaInfo objectForKey:kAuthAccessTokenKey];
        _sinaBlog.userID =[sinaInfo objectForKey:kAuthUserIDKey];
        _sinaBlog.expirationDate =[sinaInfo objectForKey:kAuthExpirationDateKey];
    }
    if ([NSUD boolForKey:kFirstLaunched]) {
        [SunViewControllerManager presentViewControllerWithType:sunUserGuideViewController];
    }else{
        if ([_sinaBlog isLoggedIn]) {
            [SunViewControllerManager presentViewControllerWithType:sunMainViewController];
        }else{
            [SunViewControllerManager presentViewControllerWithType:sunLoginViewController];
        }
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
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
