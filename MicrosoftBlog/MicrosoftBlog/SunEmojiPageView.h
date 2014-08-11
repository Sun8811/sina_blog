//
//  SunEmojiPageView.h
//  MicrosoftBlog
//
//  Created by qingyun on 14-8-2.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SunEmojiPageViewDelegate;


@interface SunEmojiPageView : UIView
//布局界面表情 page 是传入的那一页,size是每个表情的宽高
-(void)loadEmojiItem:(int)page size:(CGSize)size;
//根据表情数返回页数
+(NSUInteger)pagesForAllEmoji:(int)countPerPage;

@property(nonatomic,assign) id <SunEmojiPageViewDelegate>delegate;

@end

@protocol SunEmojiPageViewDelegate <NSObject>
-(void)emojiItemSelected:(SunEmojiPageView *)view  item:(UIButton *)sender;

@end

