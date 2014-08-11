//
//  SunUserGuideViewController.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunUserGuideViewController.h"

@interface SunUserGuideViewController ()

@end

@implementation SunUserGuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.scrollerView.contentSize =CGSizeMake(self.view.bounds.size.width*5, self.view.bounds.size.height);
    self.scrollerView.delegate =self;
    self.scrollerView.showsHorizontalScrollIndicator =NO;
    self.scrollerView.showsVerticalScrollIndicator =NO;
    self.scrollerView.directionalLockEnabled =YES;
    self.scrollerView.pagingEnabled=YES;
    
    for (int i =0 ; i<5; i++) {
        UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*i , 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"new_features_%d.jpg",i+1]];
//        imageView.tag =i;
//        if (i ==4) {
//            UIButton *btn =[[UIButton alloc]initWithFrame:CGRectMake(100, 400, 150, 40)];
//            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//           [ btn setTitle:@"开始你的神奇之旅吧" forState:UIControlStateNormal];
//            btn.backgroundColor =[UIColor redColor];
//            [imageView addSubview:btn];
//        }
        [self.scrollerView addSubview:imageView];
        SunSafeRelease(imageView);
    }
    
}
-(void)btnAction:(UIButton *)sender
{
    NSLog(@"%s",__func__);
    [appDelegate.sinaBlog logIn];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger offSet =self.view.bounds.size.width *4 +100;
    if (self.scrollerView.contentOffset.x -offSet >0) {
        [SunViewControllerManager presentViewControllerWithType:sunLoginViewController];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
