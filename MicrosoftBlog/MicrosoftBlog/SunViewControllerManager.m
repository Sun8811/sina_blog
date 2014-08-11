//
//  SunViewControllerManager.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunViewControllerManager.h"
#import "SunMainViewController.h"
#import "SunUserGuideViewController.h"
#import "SunLoginViewController.h"

@implementation SunViewControllerManager
+(void)presentViewControllerWithType:(sunControllerType)controllerType
{
    UIViewController *viewController =[[self shareInstance]controllerWithType:controllerType];
    UIWindow *mainWindow =appDelegate.window;
    mainWindow.rootViewController =viewController;
    SunSafeRelease(viewController);
    
}
//创建单例是为了每次都要alloc一块内存，这样的话就申请这一块内存就行了
+(instancetype)shareInstance
{
    static SunViewControllerManager *viewControllerManager =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewControllerManager =[[SunViewControllerManager alloc]init];
    }) ;
    return viewControllerManager;
}
-(UIViewController*)controllerWithType:(sunControllerType)type
{
    UIViewController *viewController =nil;
    switch (type) {
        case sunUserGuideViewController:
            viewController =[[SunUserGuideViewController alloc]init];
            break;
        case sunLoginViewController:
            viewController =[[SunLoginViewController alloc]init];
            break;
        case sunMainViewController:
            viewController =[[SunMainViewController alloc]init];
            break;
            
        default:
            break;
    }
    return viewController;
}
@end
