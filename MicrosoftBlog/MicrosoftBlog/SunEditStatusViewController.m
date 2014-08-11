//
//  SunEditStatusViewController.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunEditStatusViewController.h"
#import "SunFriendsViewController.h"
#import "SunHomeViewController.h"
#import "SVProgressHUD.h"
#import "SunEmojiPageView.h"
#import "NSString+FrameHeight.h"
#import "UIImageView+WebCache.h"


@interface SunEditStatusViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,SunEmojiPageViewDelegate,SinaWeiboRequestDelegate>
@property(nonatomic,retain) UISwipeGestureRecognizer *swipeGesture;
@property(nonatomic,retain) UIToolbar *kbToolBarView;
@property(nonatomic,retain) NSMutableArray *postImage;
@end
@interface SunEditStatusViewController ()
@property (retain, nonatomic) IBOutlet UIButton *cancelEdit;
@property (retain, nonatomic) IBOutlet UIButton *sendEditText;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property(nonatomic,retain) UIScrollView *emojiScrollerView;
@property(nonatomic,retain) UIView *retweetStatusBg;

@end

@implementation SunEditStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       // self.view.backgroundColor =[UIColor orangeColor];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SUNNSDC addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [SUNNSDC addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBarHidden =YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sendEditText.enabled =NO;
    self.sendEditText.alpha= 0.5;
    [self.textView becomeFirstResponder];
    self.textView.delegate=self;
    self.kbToolBarView =[[UIToolbar alloc]initWithFrame:CGRectMake(0, 568, 320, 44)];
    [self.view addSubview:self.kbToolBarView];
    //self.navigationController.navigationBarHidden = YES;
    self.kbToolBarView.backgroundColor =[UIColor orangeColor];
    [self createKbToolBarItems];
    if (self.dicStatus !=nil) {
        self.textView.text =[self.dicStatus objectForKey:@"text"];
        
       
        CGFloat statusTextHeight =[self.textView.text frameHeightWithFontSize:14.0f forViewWidth:300];
       // UIImageView *imageView =[UIImageView alloc]initWithFrame:CGRectMake(0, statusTextHeight, 80, 80);
        
        
        
        _retweetStatusBg =[[UIView alloc]initWithFrame:CGRectMake(0, statusTextHeight +10, 300, 80)];
        _retweetStatusBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _retweetStatusBg.layer.borderWidth = 0.5f;
        
        UIImageView *thumbImageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_retweetStatusBg addSubview:thumbImageView];
        
        UILabel *retweetUserName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(thumbImageView.frame)+10, 10, 200, 20)];
        retweetUserName.backgroundColor =[UIColor orangeColor];
        [_retweetStatusBg addSubview:retweetUserName];
        
        
        UILabel *labelRetweetStatusText = [[UILabel alloc] initWithFrame:CGRectMake(retweetUserName.frame.origin.x, CGRectGetMaxY(retweetUserName.frame)+5, 200, 40)];
        labelRetweetStatusText.numberOfLines = 2;
        labelRetweetStatusText.textColor = [UIColor lightGrayColor];
        labelRetweetStatusText.font = [UIFont systemFontOfSize:13.0f];
        [_retweetStatusBg addSubview:labelRetweetStatusText];
        
        NSDictionary *dicRetweetStatus =[self.dicStatus objectForKey:@"retweeted_status"];
        
        if (dicRetweetStatus != nil) {
            NSArray *picUrls =[dicRetweetStatus objectForKey:@"pic_urls"];
            if (picUrls.count >0 && picUrls != nil) {
                [thumbImageView setImageWithURL:[NSURL URLWithString:picUrls[0][@"thumbnail_pic"]]];
            }else{
                [thumbImageView setImageWithURL:[NSURL URLWithString:dicRetweetStatus[@"user"][@"avatar_large"]]];
            }
            retweetUserName.text =[dicRetweetStatus objectForKey:@"user"][@"screen_name"];
            labelRetweetStatusText.text =[dicRetweetStatus objectForKey:@"text"];
            
        }else{
            if (thumbImageView.image == nil) {
                [thumbImageView setImageWithURL:[NSURL URLWithString:[self.dicStatus objectForKey:@"user"][@"avatar_large"]]];
            }
            retweetUserName.text=[[self.dicStatus objectForKey:@"user"] objectForKey:@"screen_name"];
            labelRetweetStatusText.text =[self.dicStatus objectForKey:@"text"];
        }
        SunSafeRelease(retweetUserName);
        SunSafeRelease(labelRetweetStatusText);
        SunSafeRelease(thumbImageView);
        [self.textView addSubview:_retweetStatusBg];
       // SunSafeRelease(_retweetStatusBg);
        
    }
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SUNNSDC removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [SUNNSDC removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    self.navigationController.navigationBarHidden =NO;
}

-(void)keyBoardWillShow:(NSNotification *)notification
{
    NSLog(@"%@",notification);
    self.swipeGesture =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onSwipeGesture:)];
    self.swipeGesture.direction =UISwipeGestureRecognizerDirectionDown;
    
    [self.textView addGestureRecognizer:self.swipeGesture];
    SunSafeRelease(self.swipeGesture);
    
    NSDictionary *userInfo =notification.userInfo;
    CGRect keyBoardFrame =[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGRect kbToolBarFrame =CGRectMake(keyBoardFrame.origin.x, keyBoardFrame.origin.y -44, 320, 44);
    CGFloat timerInterval =[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    UIViewAnimationOptions animationOptions =[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]intValue];
    [UIView animateWithDuration:timerInterval delay:0 options:animationOptions animations:^{
        self.kbToolBarView.frame =kbToolBarFrame;
    } completion:nil];
      
    CGRect oldTextViewFrame = self.textView.frame;
    oldTextViewFrame.size.height -= (CGRectGetHeight(keyBoardFrame)+44);
    self.textView.frame = oldTextViewFrame;
}
-(void)keyBoardWillHide:(NSNotification *)notification
{
    [self.textView removeGestureRecognizer:self.swipeGesture];
    NSDictionary *userInfo =notification.userInfo;
    CGRect keyBoardFrame =[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGRect kbtoolBarFrame=CGRectMake(keyBoardFrame.origin.x, keyBoardFrame.origin.y -44, 320, 44);
    CGFloat timerInterval =[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    UIViewAnimationOptions animationOptions =[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]intValue];
    [UIView animateWithDuration:timerInterval delay:0 options:animationOptions animations:^{
        self.kbToolBarView.frame =kbtoolBarFrame;
    } completion:nil];
    
  
    CGRect oldTextViewFrame = self.textView.frame;
    oldTextViewFrame.size.height += (CGRectGetHeight(keyBoardFrame)+44);
    self.textView.frame = oldTextViewFrame;

}
-(void)onSwipeGesture:(UISwipeGestureRecognizer *)swipeGesture
{
    [self.textView resignFirstResponder];
}

- (IBAction)canelButton:(UIButton *)sender {
       UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"不保存" otherButtonTitles:@"保存草稿", nil];
    [actionSheet showInView:self.view];
}
#pragma ,mark --------------uiactionSheetdelegate-----------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if (self.navigationController !=nil) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self dismissViewControllerAnimated:YES completion:nil];
                }
                break;
        case 1:
        {
            //            将数据保存，可以保存到云端、服务器或者本地
            if (self.navigationController !=nil) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self dismissViewControllerAnimated:YES completion:nil];
            }

        }
            break;
        case 2:
            break;
            
        default:
            break;
    }
}
#pragma mark-----------发送按钮----------------
- (IBAction)sendButton:(UIButton *)sender {
    
    [SVProgressHUD  showWithStatus:@"正在发送..."];
    if (self.postImage ==nil || self.postImage.count == 0) {
        [appDelegate.sinaBlog requestWithURL:@"statuses/update.json" params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.textView.text,@"status", nil] httpMethod:@"POST" delegate:self];
    }else{
        UIImage *image =[self.postImage lastObject];
        [appDelegate.sinaBlog requestWithURL:@"statuses/upload.json" params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.textView.text,@"status",image,@"pic", nil] httpMethod:@"POST" delegate:self];
    }
    
}

-(void)createKbToolBarItems
{
    UIBarButtonItem *flexItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cameraItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(onCameraBarItemTapped:)];
    UIBarButtonItem *photoItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(onPhotoBarItemTapped:)];
 UIBarButtonItem *contactItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(onAtContactBarItemTapped:)];
UIBarButtonItem *emotionItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onEmotionBarItemTapped:)];
    UIBarButtonItem *addItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddBarItemTapped:)];
    [self.kbToolBarView setItems:@[cameraItem,flexItem,photoItem,flexItem,contactItem,flexItem,emotionItem,flexItem,addItem]];
}
#pragma mark -
#pragma mark UIBarButtonItem Callback
-(void)getMediaFromSource:(UIImagePickerControllerSourceType )sourceType
{
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker =[[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing =YES;
        picker.videoQuality =UIImagePickerControllerQualityTypeLow;
        picker.sourceType =sourceType;
        
        //必须以莫泰的方式弹出界面
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        UIAlertView *alter =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Device is not support" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil
                             ];
        [alter show];
    }

    
}
//当点击键盘上方，UIToolBar上的照相机按纽的时候，调用此方法
- (void)onCameraBarItemTapped:(UIBarButtonItem*)sender
{
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}
//当点击键盘上方，UIToolBar上的图片库的按纽的时候，调用此方法
- (void)onPhotoBarItemTapped:(UIBarButtonItem*)sender
{
    [self.textView resignFirstResponder];
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

//当点击键盘上方，UIToolBar上的联系人的按纽的时候，调用此方法
- (void)onAtContactBarItemTapped:(UIBarButtonItem*)sender
{
    SunFriendsViewController *friendViewController =[[SunFriendsViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [self presentViewController:friendViewController animated:YES completion:nil];
    
    SunSafeRelease(friendViewController);
    
    
}

//当点击键盘上方，UIToolBar上的表情的按纽的时候，调用此方法
- (void)onEmotionBarItemTapped:(UIBarButtonItem*)sender
{
    
    if ([self.textView.text isEqualToString:@"share"]) {
        self.textView.text =@"";
    }
    if (self.emojiScrollerView != nil) {
        [self.emojiScrollerView removeFromSuperview];
        self.emojiScrollerView =nil;
        [self.textView becomeFirstResponder];
    }else{
   _emojiScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen]bounds].size.height - 216, 320, 216)];
    self.emojiScrollerView.backgroundColor =[UIColor orangeColor];
    NSUInteger number =[SunEmojiPageView pagesForAllEmoji:35];
    self.emojiScrollerView.contentSize =CGSizeMake(number*320, 216);
    self.emojiScrollerView.pagingEnabled =YES;
    for (int i = 0; i < number; i++) {
         SunEmojiPageView *emojiPageView= [[SunEmojiPageView alloc]initWithFrame:CGRectMake(25 + 320*i, 20 , 270, 170)];
        emojiPageView.delegate =self;
        emojiPageView.backgroundColor =[UIColor clearColor];
         [emojiPageView loadEmojiItem:i size:CGSizeMake(30, 43)];
        [self.emojiScrollerView addSubview:emojiPageView];
    }
    [self.view addSubview:self.emojiScrollerView];
   // SunSafeRelease(_emojiScrollerView);
    [self.textView resignFirstResponder];
    
    }
   
    
}
//当点击键盘上方，UIToolBar上的添加的按纽的时候，调用此方法
- (void)onAddBarItemTapped:(UIBarButtonItem*)sender
{
    
}



- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.textView resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSRange range;
    range.location =0;
    range.length = 0;
    textView.selectedRange =range;
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text isEqualToString:@"share"]) {
        textView.text =@"";
    }else if(textView.text.length == 0){
        textView.text =@"share";
        textView.selectedRange =range;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length >0 && ![textView.text isEqualToString:@"share"]) {
        self.sendEditText.enabled =YES;
        self.sendEditText.alpha =1.0f;
    }else{
        self.sendEditText.enabled = NO;
        self.sendEditText.alpha = 0.5f;

    }

}
#pragma mark --------faceEmoji delegate-------
-(void)emojiItemSelected:(SunEmojiPageView *)view item:(UIButton *)sender
{
    NSLog(@"%@",[sender titleForState:UIControlStateNormal]);
    
    NSMutableString *string =(NSMutableString *)self.textView.text;
    string =(NSMutableString *) [string stringByAppendingString:[sender titleForState:UIControlStateNormal]];
    self.textView.text =string;
   
//    self.textView.text = [self.textView.text stringByAppendingString:[sender titleForState:UIControlStateNormal]];
}

#pragma mark --------uiimagePickeController delegate-------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image =[info objectForKey:UIImagePickerControllerEditedImage];
    UIImageView *imageView= [[UIImageView alloc]initWithFrame:CGRectMake(10, 30, 200, 100)];
    imageView.image=image;
    [self.textView addSubview:imageView];
    SunSafeRelease(imageView);
    
    if (self.postImage == nil) {
        self.postImage =[[NSMutableArray alloc]init];
    }
    [self.postImage  addObject:image];
    [SVProgressHUD dismiss];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark------------SinaWEIBOrequestDelegate---------------
- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *rsp =(NSHTTPURLResponse *)response;
    if (rsp.statusCode ==200) {
        [SVProgressHUD dismissWithSuccess:@"成功"];
        
    }
    if (self.navigationController !=nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)dealloc {
    [_cancelEdit release];
    [_sendEditText release];
    [_textView release];
    SunSafeRelease(_kbToolBarView);
    SunSafeRelease(_emojiScrollerView);
    [super dealloc];
}
@end
