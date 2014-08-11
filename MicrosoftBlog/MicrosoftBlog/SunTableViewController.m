//
//  SunTableViewController.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-8-1.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunTableViewController.h"
#import "NSString+FrameHeight.h"
@interface SunTableViewController ()

@end

@implementation SunTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 35.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

static const CGFloat fontSize = 14.0f;
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    NSDictionary *dicStatuesInfo = nil;
    if (self.userTimeLine == nil) {
        dicStatuesInfo = self.listStatuses[section];
      
    }else
    {
        dicStatuesInfo = self.userTimeLine;
    }
      NSLog(@"123333333333%@",self.listStatuses[0]);
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35.0f)];
    footView.backgroundColor = [UIColor whiteColor];
    
    //转发微博按纽
    UIButton *retweetBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 2.5, 90, 30)];
    [retweetBtn setImage:[UIImage imageNamed:@"timeline_icon_retweet_os7"] forState:UIControlStateNormal];
    NSString *retweetButtonTitles = [NSString stringWithFormat:@"%@",[dicStatuesInfo objectForKey:@"reposts_count"]];
    [retweetBtn setTitle:retweetButtonTitles forState:UIControlStateNormal];
    [retweetBtn setTitle:retweetButtonTitles forState:UIControlStateHighlighted];
    [retweetBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
    [retweetBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 20)];
    [retweetBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [retweetBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [retweetBtn addTarget:self action:@selector(onRetweetButton:) forControlEvents:UIControlEventTouchUpInside];
    retweetBtn.tag = section;
    [footView addSubview:retweetBtn];
    
    //评论微博按纽
    UIButton *commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(retweetBtn.frame)+10, 2.5, 90, 30)];
    [commentBtn setImage:[UIImage imageNamed:@"timeline_icon_comment_os7"] forState:UIControlStateNormal];
    NSString *commentButtonTitle =[NSString stringWithFormat:@"%@",[dicStatuesInfo objectForKey:@"comments_count"]];
    [commentBtn setTitle: commentButtonTitle forState:UIControlStateNormal];
    [commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
    [commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 20)];
    commentBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    commentBtn.titleLabel.textColor = [UIColor darkGrayColor];
    [footView addSubview:commentBtn];
    
    // 赞微博按纽
    UIButton *attitudesBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(commentBtn.frame) + 10,2.5,90,30)];
    attitudesBtn.tag = section;
    [attitudesBtn setImage:[UIImage imageNamed:@"timeline_icon_unlike_os7"] forState:UIControlStateNormal];
    [attitudesBtn setImage:[UIImage imageNamed:@"timeline_icon_unlike"] forState:UIControlStateSelected];
    [attitudesBtn setImage:[UIImage imageNamed:@"timeline_icon_unlike"] forState:UIControlStateHighlighted];
    NSString *attitudesButtonTitle =[NSString stringWithFormat:@"%@",[dicStatuesInfo  objectForKey:@"attitudes_count"]];
    [attitudesBtn setTitle: attitudesButtonTitle forState:UIControlStateNormal];
    [attitudesBtn setTitle:attitudesButtonTitle forState:UIControlStateHighlighted];
    
    [attitudesBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [attitudesBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [attitudesBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [attitudesBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
    [attitudesBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    
    attitudesBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    attitudesBtn.titleLabel.textColor = [UIColor darkGrayColor];
    [attitudesBtn addTarget:self action:@selector(onAttitudeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:attitudesBtn];
    
    SunSafeRelease(retweetBtn);
    SunSafeRelease(commentBtn);
    SunSafeRelease(attitudesBtn);
    
    return footView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    用户头部信息的高度
    CGFloat height4Header = 40.0f;
    //    原创微博文本内容所占的高度
    CGFloat statusTextHeight = 0.0f;
    //    如果有转发微博，则被转发的微博附带图片所占的高度，如果是一条原创微博，则是原创微博附带图片的高度
    CGFloat statusImageViewHeight = 0.0f;
    //    如果有转发微博的话， 转发微博文本内容所占的高度
    CGFloat retweetStatusTextHeight = 0.0f;
    
    //    当前indexpath对应的单条微博数据
    //    NSDictionary *dicStatusInfo = self.userTimeLine;
    NSDictionary *dicStatusInfo = nil;
    if (self.userTimeLine == nil) {
        dicStatusInfo = self.listStatuses[indexPath.section];
    }else
    {
        dicStatusInfo = self.userTimeLine;
    }
    NSString *content = [dicStatusInfo objectForKey:kStatusText];
    statusTextHeight = [content frameHeightWithFontSize:14.0f forViewWidth:310.0f];
    
    NSDictionary *retweetStatus = [dicStatusInfo objectForKey:kStatusRetweetStatus];
    //    如果是一条原创微博，那么直接计算附带图片的高度
    if (nil == retweetStatus)
    {
        NSArray *picUrls = [dicStatusInfo objectForKey:kStatusPicUrls];
        if (picUrls.count == 1)
        {
            //            原创微博附带了一张图片，只需要计算这张图处的高度即可
            NSDictionary *pic = picUrls[0];
            NSString *strUrl = [pic objectForKey:kStatusThumbnailPic];
            //            以同步的方式将图片从服务器下载到本地，在这里， 因为需要立即知道图片的大小， 所以必须是同步
            //            目的仅仅想要获取图片的大小，但是我们的做法是将整张图片全部下载了，所以效率很低
            /*
             NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
             UIImage *image = [UIImage imageWithData:imageData];
             statusImageViewHeight += image.size.height;
             */
            if ([strUrl  hasSuffix:@"jpg"])
            {
                CGSize imgSize = [self downloadJpgImage:strUrl];
                statusImageViewHeight += imgSize.height;
            }
            if ([strUrl hasSuffix:@"gif"])
            {
                CGSize imgSize = [self downloadGifImage:strUrl];
                statusImageViewHeight += imgSize.height;

            }
//            }else{
//            CGSize imgSize = [self downloadJpgImage:strUrl];
//            statusImageViewHeight += imgSize.height;
//            }
            
        }else if (picUrls.count > 1)
        {
            int picLineCount = ceilf(picUrls.count / 3.0);
            statusImageViewHeight += (80 * picLineCount);
        }
        
    }else
    {
        NSString *retContent = [retweetStatus objectForKey:kStatusText];
        retweetStatusTextHeight = [retContent frameHeightWithFontSize:14.0f forViewWidth:310.0];
        NSArray *picUrls = [retweetStatus objectForKey:kStatusPicUrls];
        if (picUrls.count == 1) {
            //原创微博附带了一张图片，只需要计算这张图处的高度即可
            NSDictionary *pic = picUrls[0];
            NSString *strUrl = [pic objectForKey:kStatusThumbnailPic];
            /*
             NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
             UIImage *image = [UIImage imageWithData:imageData];
             statusImageViewHeight += image.size.height;
             */
            if ([strUrl  hasSuffix:@"jpg"])
            {
                statusImageViewHeight += [self downloadJpgImage:strUrl].height;
            }
            if ([strUrl hasSuffix:@"gif"])
            {
                CGSize imgSize = [self downloadGifImage:strUrl];
                statusImageViewHeight += imgSize.height;
                
            }

            
            
            
        }else if (picUrls.count > 1)
        {
            int picLineCount = ceilf(picUrls.count / 3.0);
            statusImageViewHeight += (80 * picLineCount);
        }
        
    }
    
    return (height4Header + statusTextHeight + statusImageViewHeight + retweetStatusTextHeight + 20);
}


- (CGSize)downloadGifImage:(NSString *)strUrl
{
   
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strUrl]];
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
   // NSData *data= [[NSURLConnection connectionWithRequest:request delegate:self] start];
     NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    return [self gifImageSizeWithHeaderData:data];
   
}
- (CGSize)gifImageSizeWithHeaderData:(NSData *)data
{
    if (data.length >4) {
        data =[data subdataWithRange:NSMakeRange(6, 4)];
    }
    short w1 = 0, w2 = 0;
    [data getBytes:&w1 range:NSMakeRange(0, 1)]; [data getBytes:&w2 range:NSMakeRange(1, 1)];
    short w = w1 + (w2 << 8);
    short h1 = 0, h2 = 0;
    [data getBytes:&h1 range:NSMakeRange(2, 1)]; [data getBytes:&h2 range:NSMakeRange(3, 1)];
    short h = h1 + (h2 << 8);
    return CGSizeMake(w, h);
}

- (CGSize)downloadJpgImage:(NSString*)strUrl
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strUrl]];
    //    Range是Http协议的头部信息，在这里表示，向服务器请求数据， 要求服务给返回多大字节的数据
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    return [self jpgImageSizeWithHeaderData:data];
}

//根据JPG格式的图片信息，从前210个字节，可以获取到这张图片的宽和高
- (CGSize)jpgImageSizeWithHeaderData:(NSData *)data
{
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}



@end
