//
//  SunHomeViewController.h
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunStatusesTableViewCell.h"
#import "SunTableViewController.h"
@interface SunHomeViewController : SunTableViewController <SinaWeiboRequestDelegate,SunStatusesTableViewCell>

@end
