//
//  SunLoginViewController.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-25.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunLoginViewController.h"

@interface SunLoginViewController ()

@end

@implementation SunLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)doLogin:(UIButton *)sender {
    [appDelegate.sinaBlog logIn];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLogin:) name:kSunNotificationNameLogin object:nil];

}
-(void)onLogin:(NSNotificationCenter *)notification
{
    [SunViewControllerManager presentViewControllerWithType:sunMainViewController];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSunNotificationNameLogin object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
