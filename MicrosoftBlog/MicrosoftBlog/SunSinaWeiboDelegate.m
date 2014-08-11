//
//  SunSinaWeiboDelegate.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunSinaWeiboDelegate.h"

@implementation SunSinaWeiboDelegate
- (void)storeAuthData:(SinaWeibo *)sinaweibo
{
    //保存到plist文件
    NSDictionary *authData =@{kAuthAccessTokenKey: sinaweibo.accessToken,
                              kAuthUserIDKey:sinaweibo.userID,
                              kAuthExpirationDateKey:sinaweibo.expirationDate
                              };
    [NSUD setObject:authData forKey:kSinaWeiboAuthData];
    [NSUD synchronize];
   
}

-(void)removeAuthData:(SinaWeibo *)sinaweibo
{
    [NSUD removeObjectForKey:kSinaWeiboAuthData];
    [NSUD synchronize];
}

-(void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"%s",__func__);
    [self storeAuthData:sinaweibo];
    [SUNNSDC postNotificationName:kSunNotificationNameLogin object:nil];
    
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    [self removeAuthData:sinaweibo];
    [SUNNSDC postNotificationName:kSunNotificationNameLogoff object:nil];
    
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"%s",__func__);
    NSLog(@"%@",error);
}
@end
