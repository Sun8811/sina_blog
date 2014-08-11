//
//  SunViewControllerManager.h
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, sunControllerType)
{
    sunLoginViewController,
    sunUserGuideViewController,
    sunMainViewController
};
@interface SunViewControllerManager : NSObject
+(void)presentViewControllerWithType:(sunControllerType)controllerType;
@end
