//
//  SunEmojiPageView.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-8-2.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunEmojiPageView.h"
#import "Emoji.h"

@interface SunEmojiPageView ()
@property(nonatomic,retain)NSArray *allEmojis;

@end

@implementation SunEmojiPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _allEmojis =[Emoji allEmoji];
    }
    return self;
}
-(void)loadEmojiItem:(int)page size:(CGSize)size
{
    for (int i = 0 ; i < 4; i++) {
        for (int y = 0; y < 9; y++) {
            UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn setFrame:CGRectMake(y * size.width, i*size.height, size.width, size.height)];
            if (i ==3 && y ==8) {
                [btn setImage:[UIImage imageNamed:@"emojiDelete"] forState:UIControlStateNormal];
                btn.tag =10000;
            }else{
                [btn.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                [btn setTitle:[_allEmojis objectAtIndex:i*9 +y +(page *35)] forState:UIControlStateNormal];
                //每个表情的下标就是他的tag
                btn.tag =i * 9 + y +(page *35);
                
            }
            [btn addTarget:self action:@selector(emojiSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
    }
}
-(void)emojiSelected:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(emojiItemSelected:item:)]) {
        [self.delegate emojiItemSelected:self item:sender];
    }
}
+(NSUInteger)pagesForAllEmoji:(int)countPerPage
{
    NSArray *emojis =[Emoji allEmoji];
    return emojis.count / countPerPage;

}
@end
