//
//  SunHomeViewController.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunHomeViewController.h"

#import "SunEditStatusViewController.h"
#import "QYPlaySound.h"
#import "TSActionSheet.h"
#import "NSString+FrameHeight.h"
#import "XMLDictionary.h"
#import "UIImageView+WebCache.h"
#import "SunStatusesTableViewCell.h"
#import "SVProgressHUD.h"
#import "SunAboutMeViewController.h"
#import "MJRefresh.h"
#import <sqlite3.h>

@interface SunHomeViewController ()<SinaWeiboRequestDelegate>
//@property(nonatomic,retain)NSArray *listStatuses;
@property(nonatomic,retain)NSMutableArray *listStatuses;
@property(nonatomic,retain)QYPlaySound *playSound;
@property(nonatomic,retain) NSDictionary *currentUserInfo;
@property(nonatomic,retain) UIButton *moreBtn;
@property(nonatomic,retain) NSMutableDictionary *para;
@property(nonatomic,retain)NSString *lastBlogID;
//@property (retain, nonatomic) IBOutlet UITableView *weibo;

@end

@implementation SunHomeViewController
-(id)initWithStyle:(UITableViewStyle)style
{
    self =[super initWithStyle:style];
    if (self) {
        [self.tabBarItem initWithTitle:@"首页" image:[UIImage imageNamed:@"tabbar_home"] selectedImage:[UIImage imageNamed:@"tabbar_home_selected"]];
        NSArray *array =[[SunBlogDataBaseEngine shareInstance]queryTimeLinesFromDataBase];
        self.listStatuses =[[NSMutableArray alloc]initWithArray:array];
        if (self.listStatuses ==nil) {
            [SVProgressHUD showWithStatus:@"load data"];
            [self requestHomeLineFromSinaBlog];
            [self requestUserInfoFromSinaBlog];

        }
    }
    return self;
}
-(void)requestHomeLineFromSinaBlog
{
    
    NSString *urlApi =@"statuses/home_timeline.json";
    NSMutableDictionary *para =[NSMutableDictionary dictionaryWithObject:appDelegate.sinaBlog.userID forKey:@"uid"];
    [appDelegate.sinaBlog requestWithURL:urlApi params:para httpMethod:@"GET" delegate:self];
    
}
-(void)requestUserInfoFromSinaBlog
{
    
    NSString *urlApi =@"users/show.json";
    NSMutableDictionary *para =[NSMutableDictionary dictionaryWithObject:appDelegate.sinaBlog.userID forKey:@"uid"];
    [appDelegate.sinaBlog requestWithURL:urlApi params:para httpMethod:@"GET" delegate:self];
    
}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self requestHomeLineFromSinaBlog];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //上拉数据时调用addFooterWithCallback方法
    __block SunHomeViewController *homeBlog = self;
    [self.tableView addFooterWithCallback:^{
        [homeBlog upRefreshMoreData];
    }];
    
    //创建刷新控件
    
    UIRefreshControl *refreshController =[[UIRefreshControl alloc]init];
    refreshController.tintColor =[UIColor lightGrayColor];
    refreshController.backgroundColor =[UIColor clearColor];
    [refreshController addTarget:self action:@selector(onRefreshController:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl =refreshController;
    SunSafeRelease(refreshController);
    
    UIBarButtonItem *leftItem =[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigationbar_compose_os7"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButtonItem:)];
    self.navigationItem.leftBarButtonItem =leftItem;
    SunSafeRelease(leftItem);
    
    UIButton *btnTitle =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    btnTitle.frame =CGRectMake(150, 10, 200, 20);
    [btnTitle setTitle:@"" forState:UIControlStateNormal];
    [btnTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnTitle setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    btnTitle.titleLabel.font =[UIFont systemFontOfSize:15.0f] ;
    [btnTitle addTarget:self action:@selector(onTitleButtonTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView =btnTitle;
    SunSafeRelease(btnTitle);
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigationbar_pop_os7"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButtonItem:withEvent:)];
    self.navigationItem.rightBarButtonItem =rightItem;
    

    
}

//上拉刷新更多数据
-(void)upRefreshMoreData
{
    for (int i = 0; i < self.listStatuses.count; i++)
    {
        NSString *str = [[[self.listStatuses objectAtIndex:i] objectForKey:@"id"] stringValue];
        NSLog(@"%d>>>%@",i,str);
    }
    
    self.lastBlogID =[[[self.listStatuses lastObject]objectForKey:@"id"]stringValue];
    NSDictionary *moreData =@{@"max_id": self.lastBlogID,
                              @"uid":  appDelegate.sinaBlog.userID
                              };
    NSString *urlApi =@"statuses/home_timeline.json";
    self.para =[[NSMutableDictionary alloc]initWithDictionary:moreData];
   
    [appDelegate.sinaBlog requestWithURL:urlApi params:self.para httpMethod:@"GET" delegate:self];
    
}

-(void)onRefreshController:(UIRefreshControl *)refresh
{
    [SVProgressHUD showWithStatus:@"load Data"];
     _playSound =[[QYPlaySound alloc]initForPlayingSoundEffectWith:@"msgcome.wav"];
    NSString *urlApi =@"statuses/home_timeline.json";
    self.para =[NSMutableDictionary dictionaryWithObject:appDelegate.sinaBlog.userID forKey:@"uid"];
    [appDelegate.sinaBlog requestWithURL:urlApi params:self.para httpMethod:@"GET" delegate:self];

}
-(void)onLeftButtonItem:(UIBarButtonItem *)sender
{
    SunEditStatusViewController *editStatusViewController =[[SunEditStatusViewController alloc]init];
    [self presentViewController:editStatusViewController animated:YES completion:nil];
    SunSafeRelease(editStatusViewController);
}
-(void)onTitleButtonTapped:(UIButton *)sender forEvent:(UIEvent*)event
{

    TSActionSheet *actionSheet =[[TSActionSheet alloc]initWithTitle:@""];
    actionSheet.titleFont =[UIFont boldSystemFontOfSize:14.0f];
    actionSheet.popoverBaseColor =[UIColor blackColor];
    CGRect oldFrame =actionSheet.frame;
    CGRect newFrame =CGRectMake(oldFrame.origin.x, oldFrame.origin.y, 160, oldFrame.size.height);
    actionSheet.frame =newFrame;
    [actionSheet addButtonWithTitle:@"时间顺序" block:^{
        NSLog(@"pushed hoge1 button");
    }];
    [actionSheet addButtonWithTitle:@"智能排序" block:^{
        NSLog(@"pushed hoge2 button");
    }];
    [actionSheet addButtonWithTitle:@"我的微博" block:^{
        NSLog(@"pushed hoge3 button");
    }];
    [actionSheet addButtonWithTitle:@"密友圈" block:^{
        NSLog(@"pushed hoge4 button");
    }];
    [actionSheet addButtonWithTitle:@"互相关注的人群" block:^{
        NSLog(@"pushed hoge5 button");
    }];
    actionSheet.cornerRadius =1.0f;
    [actionSheet showWithTouch:event];
   
    
    
}
-(void)onRightButtonItem:(UIBarButtonItem *)sender withEvent:(UIEvent *)event
{
    TSActionSheet *actionSheet =[[TSActionSheet alloc]initWithTitle:@""];
    actionSheet.titleFont =[UIFont boldSystemFontOfSize:14.0f];
    CGRect oldFrame =actionSheet.frame;
    CGRect newFrame =CGRectMake(oldFrame.origin.x, oldFrame.origin.y, 130, oldFrame.size.height);
    actionSheet.frame =newFrame;
    [actionSheet addButtonWithTitle:@"刷新" block:^{
        [self onRefreshController:nil];
    }];
    [actionSheet addButtonWithTitle:@"扫一扫" block:^{
        NSLog(@"扫一扫");
    }];
    [actionSheet showWithTouch:event];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listStatuses.count;
}


//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}


NSUInteger statuseseImageViewWidth =70.0f;
NSUInteger statuseseImageViewHeight =70.0f;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //========================
     static NSString *cellIdentifier =@"cellIdentify";
    SunStatusesTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell =[[SunStatusesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.cellData = self.listStatuses[indexPath.section];
    cell.delegate = self;
    //=========================
    /*
    NSString *cellIdentifier =@"cellIdentify";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell ==nil) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
      
        UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 35, 35)];
        imageView.tag =1000;
        [cell.contentView addSubview:imageView];

        UILabel *labelName =[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) +10, 5, 100, 20)];
        labelName.font =[UIFont systemFontOfSize:14.0f];
        labelName.tag =1001;
        [cell.contentView addSubview:labelName];
        // NSLog(@"----------%@",NSStringFromCGRect(labelName.frame));
        
        UILabel *labelCreatTime =[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) +10, CGRectGetMaxY(labelName.frame)+2, 100, 20)];
        labelCreatTime.tag =1002;
        labelCreatTime.font =[UIFont systemFontOfSize:14.0f];
        [cell.contentView addSubview:labelCreatTime];
        
        UILabel *labelStatusesSource =[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labelCreatTime.frame) +10, labelCreatTime.frame.origin.y, 200, 20)];
        labelStatusesSource.tag =1003;
        labelStatusesSource.font =[UIFont systemFontOfSize:14.0f];
        [cell.contentView addSubview:labelStatusesSource];
        
        
        UILabel *statusesText =[[UILabel alloc]initWithFrame:CGRectZero];
        statusesText.tag =1004;
        [cell.contentView addSubview:statusesText];
        
         //创建微博图片视图,背景视图，将来微博附带的图片要放在这个视图，实际上相当于一个容器
        UIView *statusesImageViewBg =[[UIView alloc]initWithFrame:CGRectZero];
        statusesImageViewBg.tag =1005;
        [cell.contentView addSubview:statusesImageViewBg];
//        SunSafeRelease(statusesImageViewBg);
       
        //        转发微博正文的UILabel对象
        UILabel *labelRetweetStatus =[[UILabel alloc]initWithFrame:CGRectZero];
        labelRetweetStatus.font =[UIFont systemFontOfSize:14.0f];
        labelRetweetStatus.tag =1006;
        labelRetweetStatus.numberOfLines =0;
        labelRetweetStatus.backgroundColor =[UIColor lightGrayColor];
        [cell.contentView addSubview:labelRetweetStatus];
//        SunSafeRelease(labelRetweetStatus);

        //        转发微博附带图片显示的背景视图
        UIView *retweetImageviewBg =[[UIView alloc]initWithFrame:CGRectZero];
        retweetImageviewBg.tag =1007;
        [cell.contentView addSubview:retweetImageviewBg];

        SunSafeRelease(retweetImageviewBg);
        SunSafeRelease(labelRetweetStatus);
        SunSafeRelease(imageView);
        SunSafeRelease(labelName);
        SunSafeRelease(labelCreatTime);
        SunSafeRelease(labelStatusesSource);
        SunSafeRelease(statusesText);

    }
    NSDictionary *statusesInfo =self.listStatuses[indexPath.section];
    NSDictionary *userInfo =[statusesInfo objectForKey:@"user"];
   
    UIImageView *avatarView =(UIImageView *)[cell.contentView viewWithTag:1000];
    NSString *strURL =[userInfo objectForKey:@"profile_image_url"];
    NSData *imageData =[NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    avatarView.image =[UIImage imageWithData:imageData];
    
    
    UILabel *name =(UILabel *)[cell.contentView viewWithTag:1001];
    name.text =[userInfo objectForKey:@"screen_name"];
    
    //=================分析时间
    UILabel *creatTime =(UILabel *)[cell.contentView viewWithTag:1002];
    NSString *date =[statusesInfo objectForKey:@"created_at"];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    NSDate *dateFormString =[dateFormatter dateFromString:date];
    NSTimeInterval interval =[dateFormString timeIntervalSinceNow];
    int timeInterval =abs((int)(interval/60));
    if (timeInterval >(24 *60) ) {
        creatTime.text =[NSString stringWithFormat:@"%d天之前",timeInterval/(24 *60)];
    }else if (timeInterval >60){
     creatTime.text =[NSString stringWithFormat:@"%d小时之前",timeInterval/60];
    }else{
        creatTime.text =[NSString stringWithFormat:@"%d分钟之前",timeInterval];
    }
    //============源分析
    UILabel *source =(UILabel *)[cell.contentView viewWithTag:1003];
    NSDictionary *dicSourceInfo =[NSDictionary dictionaryWithXMLString:[statusesInfo objectForKey:@"source"]];
    NSString *string =[dicSourceInfo objectForKey:XMLDictionaryTextKey];
    source.text =string;
    
    UILabel *contentText =(UILabel *)[cell.contentView viewWithTag:1004];
    contentText.text =[statusesInfo objectForKey:@"text"];
    contentText.font =[UIFont systemFontOfSize:14.0f];
    CGRect newFrame = CGRectMake(5, CGRectGetMaxY(source.frame)+5, 310,[contentText.text frameHeightWithFontSize:14.0f forViewWidth:310.0] );
   // newFrame.size.height = [contentText.text frameHeightWithFontSize:14.0f forViewWidth:310.0];
    contentText.numberOfLines =0;
    contentText.frame = newFrame;
   
    //避免重用队列引起来的问题
    UIView *stImageViewBg =[cell.contentView viewWithTag:1005];
    for (UIView *stView in [stImageViewBg subviews]) {
        [stView removeFromSuperview];
    }
    UIView *retImageViewBg =[cell.contentView viewWithTag:1007];
    for (UIView *retView in [retImageViewBg subviews]) {
        [retView removeFromSuperview];
    }
    
    //    尝试取出转发微博数据，如果取出的nil表示，这仅仅是一条原创的微博，如果不空，说明这是一条转发微博
    NSDictionary *retweetStatusesInfo =[statusesInfo objectForKey:@"retweeted_status"];
  
    //代码的服用问题
    UILabel *retweetContextTextLabel =(UILabel *)[cell.contentView viewWithTag:1006];
    retweetContextTextLabel.frame =CGRectZero;
    
    if (retweetStatusesInfo == nil){
        NSArray *statusPicUrls =[statusesInfo objectForKey:@"pic_urls"];
//        UIView *statusesImageviewBg =[cell.contentView viewWithTag:1005];
        
        if (statusPicUrls.count ==1) {
            //            如果原阶微博附带的只有一张图片 ， 则按原始大小显示就可以了。
            //            将表示图片的字符串URL从数据集里取出
            
            NSString *strPicUrls =[statusPicUrls[0] objectForKey:@"thumbnail_pic"];
           //根据url取出图片
            NSData *dataImage =[NSData dataWithContentsOfURL:[NSURL URLWithString:strPicUrls]];
            UIImage *image =[UIImage imageWithData:dataImage];
            
            UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, image.size.width, image.size.height)];
            imageView.image =image;
            [stImageViewBg addSubview:imageView];
            stImageViewBg.frame =CGRectMake(10, CGRectGetMaxY(contentText.frame), image.size.width, image.size.height);
            SunSafeRelease(imageView);
            
        }else{
            stImageViewBg.frame =CGRectMake(5, CGRectGetMaxY(contentText.frame), 310, 80*ceil(statusPicUrls.count/3));
            for (int i = 0; i<statusPicUrls.count; i++) {
                UIImageView *imageView =nil;
                if (statusPicUrls.count ==4 ) {
                    imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5+statusesImageWidth*(i%2), statuseseImageHeight*(i/2), statusesImageWidth, statuseseImageHeight)];
                }else{
                    imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5+statusesImageWidth*(i%3), statuseseImageHeight *(i/3), statusesImageWidth, statuseseImageHeight)];
                }
                NSString *strPicUrls =[statusPicUrls[i] objectForKey:@"thumbnail_pic"];
                [imageView setImageWithURL:[NSURL URLWithString:strPicUrls]];
                [stImageViewBg addSubview:imageView];
                SunSafeRelease(imageView);
                
                }
        
            }
    }else{
        
        
        NSString *statusText = [retweetStatusesInfo objectForKey:@"text"];
        retweetContextTextLabel.text = statusText;
        CGRect newFrame = CGRectMake(5, CGRectGetMaxY(contentText.frame)+5, 310, [statusText frameHeightWithFontSize:14.0 forViewWidth:310.0f]);
        retweetContextTextLabel.frame = newFrame;

        // 转发微博正文附带图片
        NSArray *retStatusPicUrls = [retweetStatusesInfo objectForKey:@"pic_urls"];
        if (retStatusPicUrls.count == 1) {
            NSString *retStrPicUrls =[retStatusPicUrls[0] objectForKey:@"thumbnail_pic"];
            //根据url取出图片
            NSData *dataImage =[NSData dataWithContentsOfURL:[NSURL URLWithString:retStrPicUrls]];
            UIImage *image =[UIImage imageWithData:dataImage];
            
            UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, image.size.width, image.size.height)];
            imageView.image =image;
            [retImageViewBg addSubview:imageView];
            retImageViewBg.frame =CGRectMake(10, CGRectGetMaxY(retweetContextTextLabel.frame), image.size.width, image.size.height);
        }else if (retStatusPicUrls.count > 1){
            retImageViewBg.frame =CGRectMake(5, CGRectGetMaxY(retweetContextTextLabel.frame), 310, 80*ceil(retStatusPicUrls.count/3));
            for (int i = 0; i<retStatusPicUrls.count; i++) {
                UIImageView *imageView =nil;
                if (retStatusPicUrls.count ==4 ) {
                    imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5+statusesImageWidth*(i%2), statuseseImageHeight*(i/2), statusesImageWidth, statuseseImageHeight)];
                }else{
                    imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5+statusesImageWidth*(i%3), statuseseImageHeight *(i/3), statusesImageWidth, statuseseImageHeight)];
                }
                NSString *strPicUrls =[retStatusPicUrls[i] objectForKey:@"thumbnail_pic"];
                [imageView setImageWithURL:[NSURL URLWithString:strPicUrls]];
                [retImageViewBg addSubview:imageView];
            }
        }
    }
    */
    
    return cell;


}
-(void)onAttitudesBtn:(UIButton *)sender
{
    NSUInteger  nAttitudeCount;
    if (sender.selected) {
        sender.selected =NO;
        nAttitudeCount = [[sender titleForState:UIControlStateSelected]integerValue];
        nAttitudeCount--;
        [sender setTitle:[NSString stringWithFormat:@"%d",(int)nAttitudeCount] forState:UIControlStateNormal];
    }else{
        sender.selected= YES;
        nAttitudeCount = [[sender titleForState:UIControlStateNormal]integerValue];
        nAttitudeCount++;
        [sender setTitle:[NSString stringWithFormat:@"%d",(int)nAttitudeCount] forState:UIControlStateSelected];
    }
}
-(void)onRetweetButton:(UIButton *)sender
{
    //    创建一个新的界面（viewController),导航控制器push
    SunEditStatusViewController *editViewController =[[SunEditStatusViewController alloc]init];
    editViewController.hidesBottomBarWhenPushed =YES;
    editViewController.dicStatus =self.listStatuses[sender.tag];
   // [appDelegate.sinaBlog requestWithURL:@"statuses/repost" params:[NSMutableDictionary dictionaryWithObject:[editViewController.dicStatus objectForKey:@"text"] forKey:@"status"] httpMethod:@"POST" delegate:self];

    [self.navigationController pushViewController:editViewController animated:YES];
    SunSafeRelease(editViewController);
  
    
    
}
-(void)onCommentsBtn:(UIButton *)sender
{
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 35.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}
#pragma mark-------------SinaWeiboRequestDelegate--------
- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}
- (void)request:(SinaWeiboRequest *)request didReceiveRawData:(NSData *)data
{
}
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{

    
   // NSLog(@"%@",result);
    NSURL *url =[NSURL URLWithString:request.url];
    NSString *stringCompensionUrl =[[url pathComponents]lastObject];
    if ([stringCompensionUrl isEqualToString:@"show.json"]) {
        self.currentUserInfo =(NSDictionary *)result;
        UIButton *btnTitle =(UIButton *)self.navigationItem.titleView;
        NSString *title =[self.currentUserInfo objectForKey:@"screen_name"];
        [btnTitle setTitle:title forState:UIControlStateNormal];
        [btnTitle setTitle:title forState:UIControlStateHighlighted];
        [[SunBlogDataBaseEngine shareInstance]savaUserInfo2DataBase:self.currentUserInfo withStatusID:[self.currentUserInfo objectForKey:@"status"][@"id"]];
        
        
    }else if([stringCompensionUrl isEqualToString:@"home_timeline.json"]){
        
       // NSLog(@"11111111111111111%@",self.listStatuses);
        //若果是下来刷新通过reques。params返回的是用微博用户的access_token，uid，若果是上拉刷新则返回的是access_token，uid(我自己)，id
        NSDictionary *data = request.params;
        
        //对数据进行判断，是否是新数据，若果是新数据则data。count == 2，因为通过uid返回一个token，当老数据返回时，则是三个有，id，uid，token；
        if (data.count ==2) {
            NSArray *tempData=[result objectForKey:@"statuses"];
            self.listStatuses =[[NSMutableArray alloc]initWithArray:tempData];
            [self.tableView reloadData];
        }else{
            //这是取得历史数据
            NSArray *data1 =[result objectForKey:@"statuses"];
            NSMutableArray *ret =[[NSMutableArray alloc]initWithArray:data1];
            //移除0是因为上拉刷新的时候会把最后一个微博id作为上拉刷新后的第一条数据，为了避免重复就删除第一条
            
            [ret removeObjectAtIndex:0];
            //统计出来当前微博的个数
            NSInteger currentCount =self.listStatuses.count;
            //把历史数据放到新数据后面
            [self.listStatuses addObjectsFromArray:ret];
            //统计插入历史微博后的总微博的个数
            NSUInteger lastCount =self.listStatuses.count;
            //创建indexset集合
            NSMutableIndexSet *indexSet =[[NSMutableIndexSet alloc]init];
            //通过for循环吧i的值传给indexset
            for (NSInteger i =currentCount; i < lastCount; i++) {
                NSIndexSet *tempIndexSet = [NSIndexSet indexSetWithIndex:i];
                [indexSet addIndexes:tempIndexSet];
            }
            //开始更新数据
            [self.tableView beginUpdates];
            //通过indexset把历史微博导入到sections（因为）给cell。celldata赋值的时候用的是indepth【section】
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            
            [self.tableView footerEndRefreshing];
            
        }

    }
       [_playSound play];
    [self.refreshControl endRefreshing];
    [SVProgressHUD dismiss];
   // sqlite3_close(sunDB);
}
#pragma mark -------sunStatusesTableViewCellDelegate-----------
- (void)showFullImageView:(NSString *)stringUrl
{
    //1.下载图片
    NSURL *imageUrl =[NSURL URLWithString:stringUrl];
    NSData *imageDate =[NSData dataWithContentsOfURL:imageUrl];
    UIImage *image =[UIImage imageWithData:imageDate];
    
    //  2.创建一个ImageView对象
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image =image;
    imageView.tag =1008;
    
    UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onGestureTapped:)];
    [imageView addGestureRecognizer:tapGesture];
    
    imageView.userInteractionEnabled =YES;
    imageView.multipleTouchEnabled =YES;
    //3.创建一个uiscrollView，配置一下scrollview的属性,代理
    UIScrollView *scrollView =[[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    scrollView.contentSize =image.size;
    scrollView.delegate=self;
    scrollView.minimumZoomScale =0.5;
    scrollView.maximumZoomScale =1.0;
    scrollView.backgroundColor =[UIColor blackColor];
    scrollView.pagingEnabled=YES;
    scrollView.showsHorizontalScrollIndicator =NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [scrollView addSubview:imageView];
    SunSafeRelease(imageView);
    //4.让scrollview全屏显示，将scrollview对象添加到window
    UIWindow *window =[[UIApplication sharedApplication] keyWindow];
    [window addSubview:scrollView];
}

-(void)statusesTableViewCell:(SunStatusesTableViewCell *)cell StatusesImageViewDidSelected:(UIGestureRecognizer *)gesture
{
    
    //1.从服务器下载原始图片
  
    NSString *stringUrl =[cell.cellData objectForKey:@"original_pic"];
    [self showFullImageView:stringUrl];
}
#pragma mark -----------uiscrollerViewDelegate----------
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:1008];
}

-(void)statusesTableViewCell:(SunStatusesTableViewCell *)cell avatarImageViewDidSelected:(UIGestureRecognizer *)gesture
{
   
    SunAboutMeViewController *aboutMeViewController =[[SunAboutMeViewController alloc]initWithStyle:UITableViewStyleGrouped];
    //aboutMeViewController.userID =[[[cell.cellData objectForKey:@"user"]objectForKey:@"id"]stringValue];
    aboutMeViewController.isHidenNavigationBar =NO;
   
    [aboutMeViewController setValue:[cell.cellData objectForKey:@"user"] forKey:@"currentUserInfo"];
    
    [aboutMeViewController setValue:cell.cellData  forKey:@"userTimeLine"];
    [self.navigationController pushViewController:aboutMeViewController animated:YES];
    SunSafeRelease(aboutMeViewController);
    
}

-(void)onGestureTapped:(UITapGestureRecognizer *)gesture
{
    //gesture.view 是imageView superView 是UIScorllview
    [gesture.view.superview removeFromSuperview];
}
-(void)statusesTableViewCell:(SunStatusesTableViewCell *)cell retweetStatusesImageViewDidSelected:(UIGestureRecognizer *)gesture
{
    NSDictionary *retweetImage =[cell.cellData objectForKey:@"retweeted_status"];
    NSString *stringUrl =[retweetImage objectForKey:@"original_pic"];
    [self showFullImageView:stringUrl];
}


- (void)dealloc {
   // [_weibo release];
    SunSafeRelease(_para);
    [super dealloc];
}
@end
