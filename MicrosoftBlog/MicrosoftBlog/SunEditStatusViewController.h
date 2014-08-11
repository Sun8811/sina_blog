//
//  SunEditStatusViewController.h
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SunEditStatusViewController : UIViewController<UITextViewDelegate,UIActionSheetDelegate>
@property(nonatomic,retain)NSDictionary *dicStatus;

@end
