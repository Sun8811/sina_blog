//
//  ConstDefine.h
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#ifndef MicrosoftBlog_ConstDefine_h
#define MicrosoftBlog_ConstDefine_h

#define kAppKey                 @"3286270689"
#define kAppSecret              @"dc5173f111521ca9000fc7282fa647ef"
#define kAppRedirectURI         @"https://api.weibo.com/oauth2/default.html"

#define NSUD                    [NSUserDefaults standardUserDefaults]
#define SUNNSDC                 [NSNotificationCenter defaultCenter]
#define appDelegate             ((SunAppDelegate*)[UIApplication sharedApplication].delegate)
#define SunSafeRelease(_pointer)   {[_pointer release],_pointer =nil;}

#define kEverLaunched           @"everLaunched"
#define kFirstLaunched          @"firstLaunched"

#define kSinaWeiboAuthData      @"authData"
#define kAuthAccessTokenKey     @"AccessTokenKey"
#define kAuthUserIDKey          @"UserIDKey"
#define kAuthExpirationDateKey  @"ExpirationDateKey"
#define kAuthRefreshToken       @"refreshToken"

#define kSunNotificationNameLogin   @"notificationLogin"
#define kSunNotificationNameLogoff   @"notificationLogoff"


static NSString * const kStatusPicUrls = @"pic_urls";
static NSString * const kStatusThumbnailPic = @"thumbnail_pic";
static NSString * const kStatusRetweetStatus = @"retweeted_status";
static NSString * const kStatusText = @"text";

static NSString *const kSunBlogDataBaseName =@"sun_Blog_client";

#endif
