//
//  SunStatusesTableViewCell.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-28.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunStatusesTableViewCell.h"
#import "XMLDictionary.h"
#import "NSString+FrameHeight.h"
#import "UIImageView+WebCache.h"

@implementation SunStatusesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        const CGFloat fontSize = 14.0f;
        UIFont *customFont = [UIFont systemFontOfSize:fontSize];
        
        _avatarImageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 35, 35)];
        [self.contentView addSubview:_avatarImageView];
        
        _avatarImageView.userInteractionEnabled =YES;
        UITapGestureRecognizer *tapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarImageViewTapped:)];
        [_avatarImageView addGestureRecognizer:tapGestureRecongnizer];

        
        _labeName =[[UILabel alloc]initWithFrame:CGRectZero];
        _labeName.font =customFont;
        [self.contentView addSubview:_labeName];
        
        _labelCreatTime =[[UILabel alloc]initWithFrame:CGRectZero];
        _labelCreatTime.font =customFont;
        [self.contentView addSubview:_labelCreatTime];
        
        _labelSource = [[UILabel alloc]initWithFrame:CGRectZero];
        _labelSource.font =customFont;
        [self.contentView addSubview:_labelSource];
        
        _labelStatuses = [[UILabel alloc]initWithFrame:CGRectZero];
        _labelStatuses.font =customFont;
        _labelStatuses.numberOfLines =0;
        [self.contentView addSubview:_labelStatuses];
        
        
        _stImageViewBg = [[UIView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_stImageViewBg];
        
        _labelRetweetStatuses =[[UILabel alloc]initWithFrame:CGRectZero];
        _labelRetweetStatuses.font =customFont;
        _labelRetweetStatuses.backgroundColor =[UIColor lightGrayColor];
        _labelRetweetStatuses.numberOfLines =0;
        [self.contentView addSubview:_labelRetweetStatuses];
        
        _retweetImageViewBg =[[UIView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_retweetImageViewBg];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self storeFrame];
    //celldata 来源于listStatus【indexpath.section】
    NSDictionary *statusesInfo =self.cellData;
    NSDictionary *statusesUserInfo =[statusesInfo objectForKey:@"user"];
     NSUInteger widthSpace = 5;
    
    NSString *stringUrl =[statusesUserInfo objectForKey:@"profile_image_url"];
    NSData *imageData =[NSData dataWithContentsOfURL:[NSURL URLWithString:stringUrl]];
    UIImage *image =[UIImage imageWithData:imageData];
    _avatarImageView.image =image;
    
    
    
    //将字符串类型的日期转换成NSDate类型，，这样就可以参预计算
    self.labeName.text = [statusesUserInfo objectForKey:@"screen_name"];
    self.labeName.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + widthSpace, 2, 100, 20);

    NSString *strDate = [statusesInfo objectForKey:@"created_at"];
    //将字符串类型的日期转换成NSDate类型，，这样就可以参预计算
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    NSDate *dateFromString = [dateFormatter dateFromString:strDate];
    //计算时间与微博创建时间间隔，单位：秒
    NSTimeInterval interval = [dateFromString timeIntervalSinceNow];
    self.labelCreatTime.text = [NSString stringWithFormat:@"%d分钟之前",abs((int)interval/60)];
    self.labelCreatTime.frame = CGRectMake( CGRectGetMaxX(self.avatarImageView.frame)+widthSpace,  CGRectGetMaxY(self.labeName.frame)+2, 100, 20);
    
    self.labelSource.frame = CGRectMake(CGRectGetMaxX(self.labelCreatTime.frame)+widthSpace, self.labelCreatTime.frame.origin.y, 200, 20);
    
    NSDictionary *dicSoucreInfo = [NSDictionary  dictionaryWithXMLString:[statusesInfo objectForKey:@"source"]];
    self.labelSource.text = [dicSoucreInfo objectForKey:XMLDictionaryTextKey];
    
    self.labelStatuses.text =[statusesInfo objectForKey:@"text"];
    self.labelStatuses.font =[UIFont systemFontOfSize:14.0f];
    CGRect newFrame = CGRectMake(5, CGRectGetMaxY(self.labelSource.frame)+5, 310,[self.labelStatuses.text frameHeightWithFontSize:14.0f forViewWidth:310.0] );
    // newFrame.size.height = [contentText.text frameHeightWithFontSize:14.0f forViewWidth:310.0];
    self.labelStatuses.numberOfLines =0;
    self.labelStatuses.frame = newFrame;
    
    for (UIView *retView in [self.stImageViewBg subviews]) {
        [retView removeFromSuperview];
    }
    
    for (UIView *stView in [self.retweetImageViewBg subviews]) {
        [stView removeFromSuperview];
    }
    
    NSUInteger statusImageWidth = 70;
    NSUInteger statusImageHeight = 70;
    //    尝试取出转发微博数据，如果取出的nil表示，这仅仅是一条原创的微博，如果不空，说明这是一条转发微博
    NSDictionary *retweetStatusInfo = [statusesInfo objectForKey:kStatusRetweetStatus];
    if (nil == retweetStatusInfo ) {
        // 因为是一条原创微博， 所以接下来直接显示附带的图片， 如果有的话。
        NSArray *statusPicUrls = [statusesInfo objectForKey:kStatusPicUrls];
        if (statusPicUrls.count == 1) {
            //如果原阶微博附带的只有一张图片 ， 则按原始大小显示就可以了。
            //将表示图片的字符串URL从数据集里取出
            NSString *strPicUrls = [statusPicUrls[0] objectForKey:kStatusThumbnailPic];
            NSURL *dataUrl = [NSURL URLWithString:strPicUrls];
            NSData *dataImage = [NSData dataWithContentsOfURL:dataUrl];
            UIImage *image = [UIImage imageWithData:dataImage];
            UIImageView *stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, image.size.width, image.size.height)];
            
            stImgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onStatuseImageViewTapped:)];
            [stImgView addGestureRecognizer:tapGesture];
            SunSafeRelease(tapGesture);
            
            stImgView.image = image;
            [self.stImageViewBg addSubview:stImgView];
            self.stImageViewBg.frame = CGRectMake(widthSpace, CGRectGetMaxY(self.labelStatuses.frame), image.size.width, image.size.height);
            SunSafeRelease(stImgView);
        }else  //statusPicUrls.count != 1
        {
            self.stImageViewBg.frame = CGRectMake(0, CGRectGetMaxY(self.labelStatuses.frame), 310, 80 * ceilf(statusPicUrls.count /3.0f));
            for (int i = 0 ; i < statusPicUrls.count; i++) {
                UIImageView *stImgView = nil;
                if (statusPicUrls.count == 4) {
                    stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5+statusImageWidth*(i%2), statusImageHeight*ceil(i/2), statusImageWidth, statusImageHeight)];
                }else
                {
                    stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5+statusImageWidth*(i%3), statusImageHeight*ceil(i/3), statusImageWidth, statusImageHeight)];
                }
                
                stImgView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onStatuseImageViewTapped:)];
                [stImgView addGestureRecognizer:tapGesture];
                SunSafeRelease(tapGesture);
                
                NSString *strPicUrls = [statusPicUrls[i] objectForKey:kStatusThumbnailPic];
                [stImgView setImageWithURL:[NSURL URLWithString:strPicUrls]];
                [self.stImageViewBg addSubview:stImgView];
            }
        }
    }else //有转发微博内容 (retweetSTatusInfo != nil)
    {
        NSString *retStatusText = [retweetStatusInfo objectForKey:kStatusText];
        self.labelRetweetStatuses.text = retStatusText;
        //根据转发微博的正文内容，计算转发微博label所点的高度
        CGFloat height4RetStatusText = [retStatusText frameHeightWithFontSize:14.0f forViewWidth:310.0f];
        CGRect newFrame = CGRectMake(5, CGRectGetMaxY(self.labelStatuses.frame), 310.0f, height4RetStatusText);
        //        根据计算得到的新的fram更新转发微博内容的label的frame
        self.labelRetweetStatuses.frame = newFrame;
        
        NSArray *retStatusPicUrls = [retweetStatusInfo objectForKey:kStatusPicUrls];
        if (retStatusPicUrls.count == 1) {
            NSString *strPicUrls = [retStatusPicUrls[0] objectForKey:kStatusThumbnailPic];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strPicUrls]]];
            
            UIImageView *stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, image.size.width, image.size.height)];
            [stImgView setImage:image];
            
            stImgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetweetStatuseImageViewTapped:)];
            [stImgView addGestureRecognizer:tapGesture];
            SunSafeRelease(tapGesture);
            
            [self.retweetImageViewBg addSubview:stImgView];
            self.retweetImageViewBg.frame = CGRectMake(5, CGRectGetMaxY(self.labelRetweetStatuses.frame), image.size.width, image.size.height);
            SunSafeRelease(stImgView);
            
        }else if (retStatusPicUrls.count > 1)
        {
            self.retweetImageViewBg.frame = CGRectMake(0, CGRectGetMaxY(self.labelRetweetStatuses.frame), 310, 80 * ceilf(retStatusPicUrls.count /3.0f));
            for (int i = 0 ; i < retStatusPicUrls.count; i++) {
                UIImageView *stImgView = nil;
                if (retStatusPicUrls.count == 4) {
                    stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5+statusImageWidth*(i%2), statusImageHeight*ceil(i/2), statusImageWidth, statusImageHeight)];
                }else
                {
                    stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5+statusImageWidth*(i%3), statusImageHeight*ceil(i/3), statusImageWidth, statusImageHeight)];
                }
                
                stImgView.userInteractionEnabled =YES;
                UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onRetweetStatuseImageViewTapped:)];
                [stImgView addGestureRecognizer:tapGesture];
                SunSafeRelease(tapGesture);
                
                NSString *strPicUrls = [retStatusPicUrls[i] objectForKey:kStatusThumbnailPic];
                [stImgView setImageWithURL:[NSURL URLWithString:strPicUrls]];
                [self.retweetImageViewBg addSubview:stImgView];
                SunSafeRelease(stImgView);
            }
            
        }
    }
    

/*
//#if 0
//    if (retweetStatusesInfo == nil){
//        NSArray *statusPicUrls =[statusesInfo objectForKey:@"pic_urls"];
//        //        UIView *statusesImageviewBg =[cell.contentView viewWithTag:1005];
//        
//        if (statusPicUrls.count ==1) {
//            //            如果原阶微博附带的只有一张图片 ， 则按原始大小显示就可以了。
//            //            将表示图片的字符串URL从数据集里取出
//            
//            NSString *strPicUrls =[statusPicUrls[0] objectForKey:@"thumbnail_pic"];
//            //根据url取出图片
//            NSData *dataImage =[NSData dataWithContentsOfURL:[NSURL URLWithString:strPicUrls]];
//            UIImage *image =[UIImage imageWithData:dataImage];
//            
//            UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, image.size.width, image.size.height)];
//            imageView.image =image;
//            
//            imageView.userInteractionEnabled =YES;
//            
//            UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onStatuseImageViewTapped:)];
//            [imageView addGestureRecognizer:tapGesture];
//            
//            [self.stImageViewBg addSubview:imageView];
//            self.stImageViewBg.frame =CGRectMake(10, CGRectGetMaxY(self.labelStatuses.frame), image.size.width, image.size.height);
//            
//            SunSafeRelease(imageView);
//            
//        }else{
//            self.stImageViewBg.frame =CGRectMake(5, CGRectGetMaxY(self.labelStatuses.frame), 310, 80*ceil(statusPicUrls.count/3));
//            for (int i = 0; i<statusPicUrls.count; i++) {
//                UIImageView *imageView =nil;
//                if (statusPicUrls.count ==4 ) {
//                    imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5+statusesImageWidth*(i%2), statuseseImageHeight*(i/2), statusesImageWidth, statuseseImageHeight)];
//                }else{
//                    imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5+statusesImageWidth*(i%3), statuseseImageHeight *(i/3), statusesImageWidth, statuseseImageHeight)];
//                }
//                
//                imageView.userInteractionEnabled =YES;
//                UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onStatuseImageViewTapped:)];
//                [imageView addGestureRecognizer:tapGesture];
//                
//                NSString *strPicUrls =[statusPicUrls[i] objectForKey:@"thumbnail_pic"];
//                [imageView setImageWithURL:[NSURL URLWithString:strPicUrls]];
//                [self.stImageViewBg addSubview:imageView];
//                SunSafeRelease(imageView);
//                
//            }
//            
//        }
//    }else{
//        
//        NSString *statusText = [retweetStatusesInfo objectForKey:@"text"];
//        self.labelRetweetStatuses.text = statusText;
//        self.labelRetweetStatuses.backgroundColor =[UIColor lightGrayColor];
//        CGRect newFrame = CGRectMake(5, CGRectGetMaxY(self.labelStatuses.frame)+5, 310, [statusText frameHeightWithFontSize:14.0 forViewWidth:310.0f]);
//        self.labelRetweetStatuses.frame = newFrame;
//        
//        // 转发微博正文附带图片
//        NSArray *retStatusPicUrls = [retweetStatusesInfo objectForKey:@"pic_urls"];
//        if (retStatusPicUrls.count == 1) {
//            NSString *retStrPicUrls =[retStatusPicUrls[0] objectForKey:@"thumbnail_pic"];
//            //根据url取出图片
//            NSData *dataImage =[NSData dataWithContentsOfURL:[NSURL URLWithString:retStrPicUrls]];
//            UIImage *image =[UIImage imageWithData:dataImage];
//            
//            UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, image.size.width, image.size.height)];
//            
//            imageView.userInteractionEnabled = YES;
//            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetweetStatuseImageViewTapped:)];
//            [imageView addGestureRecognizer:tapGesture];
//
//            
//            imageView.image =image;
//            [self.retweetImageViewBg addSubview:imageView];
//            self.retweetImageViewBg.frame =CGRectMake(10, CGRectGetMaxY(self.labelRetweetStatuses.frame), image.size.width, image.size.height);
//        }else if (retStatusPicUrls.count > 1){
//            self.retweetImageViewBg.frame =CGRectMake(5, CGRectGetMaxY(self.labelRetweetStatuses.frame), 310, 80*ceil(retStatusPicUrls.count/3.0f));
//            for (int i = 0; i<retStatusPicUrls.count; i++) {
//                UIImageView *imageView =nil;
//                if (retStatusPicUrls.count ==4 ) {
//                    imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5+statusesImageWidth*(i%2), statuseseImageHeight*(i/2), statusesImageWidth, statuseseImageHeight)];
//                }else{
//                    imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5+statusesImageWidth*(i%3), statuseseImageHeight *(i/3), statusesImageWidth, statuseseImageHeight)];
//                }
//                NSString *strPicUrls =[retStatusPicUrls[i] objectForKey:@"thumbnail_pic"];
//                [imageView setImageWithURL:[NSURL URLWithString:strPicUrls]];
//                [self.retweetImageViewBg addSubview:imageView];
//            }
//        }
//    }
//#endif
//
 */
}
-(void)storeFrame
{
   // self.labelStatuses.frame =CGRectZero;
    self.labelRetweetStatuses.frame =CGRectZero;
    self.stImageViewBg.frame =CGRectZero;
    self.retweetImageViewBg.frame =CGRectZero;
}
#pragma mark --------------------tapImageViewAction----------------

- (void)onAvatarImageViewTapped:(UIGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(statusesTableViewCell:retweetStatusesImageViewDidSelected:)]) {
        [self.delegate statusesTableViewCell:self avatarImageViewDidSelected:gesture];
    }
}
-(void)onStatuseImageViewTapped:(UIGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(statusesTableViewCell:StatusesImageViewDidSelected:)]) {
        [self.delegate statusesTableViewCell:self StatusesImageViewDidSelected:gesture];
    }
}
-(void)onRetweetStatuseImageViewTapped:(UIGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(statusesTableViewCell:retweetStatusesImageViewDidSelected:)]) {
        [self.delegate statusesTableViewCell:self StatusesImageViewDidSelected:gesture];
    
}

}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
