//
//  SunStatusesTableViewCell.h
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-28.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SunStatusesTableViewCell;

@protocol SunStatusesTableViewCell <NSObject>

@required
-(void)statusesTableViewCell:(SunStatusesTableViewCell *)cell StatusesImageViewDidSelected:(UIGestureRecognizer *)gesture;
-(void)statusesTableViewCell:(SunStatusesTableViewCell *)cell avatarImageViewDidSelected:(UIGestureRecognizer *)gesture;
-(void)statusesTableViewCell:(SunStatusesTableViewCell *)cell retweetStatusesImageViewDidSelected:(UIGestureRecognizer *)gesture;

@end

@interface SunStatusesTableViewCell : UITableViewCell

@property(nonatomic,retain) NSDictionary *cellData;
//显示微博单元格头部信息，主要有发送向博的博主的头像 名字 发布微博的时间以及发布微博的来源
@property(nonatomic,retain) UIImageView *avatarImageView;
@property(nonatomic,retain) UILabel *labeName;
@property(nonatomic,retain) UILabel *labelCreatTime;
@property(nonatomic,retain) UILabel *labelSource;

//微博正文
@property(nonatomic,retain) UILabel *labelStatuses;
//原创微博图片背景视图
@property(nonatomic,retain) UIView *stImageViewBg;
//转发微博正文
@property(nonatomic,retain) UILabel *labelRetweetStatuses;
//转发微博图片背景视图
@property(nonatomic,retain) UIView *retweetImageViewBg;

@property(nonatomic,assign) id <SunStatusesTableViewCell> delegate;
@end
