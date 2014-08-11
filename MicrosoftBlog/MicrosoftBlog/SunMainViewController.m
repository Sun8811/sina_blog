//
//  SunMainViewController.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunMainViewController.h"
#import"SunHomeViewController.h"
#import"SunMessageViewController.h"
#import"SunAboutMeViewController.h"
#import"SunPlazaViewController.h"
#import"SunMoreViewController.h"

@interface SunMainViewController ()

@end

@implementation SunMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_background"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SunHomeViewController *homeVCtrl =[[SunHomeViewController alloc]initWithStyle:UITableViewStyleGrouped];
    SunMessageViewController *messageVCtrl =[[SunMessageViewController alloc]initWithStyle:UITableViewStylePlain];
    SunPlazaViewController *plazaVCtrl =[[SunPlazaViewController alloc]init];
    
    SunAboutMeViewController *aboutMeVCtrl =[[SunAboutMeViewController alloc]init];
    SunMoreViewController *moreVCtrl =[[SunMoreViewController alloc]initWithStyle:UITableViewStylePlain];
    
    NSArray *viewControllers =@[homeVCtrl,messageVCtrl,plazaVCtrl,aboutMeVCtrl,moreVCtrl];
    NSMutableArray *vcs =[[NSMutableArray alloc]initWithCapacity:5];
    for (UIViewController *vc in viewControllers) {
        UINavigationController *nav =[[UINavigationController alloc]initWithRootViewController:vc];
        [vcs addObject:nav];
        SunSafeRelease(nav);
        SunSafeRelease(vc);
        
        
    }
    self.viewControllers=vcs;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
