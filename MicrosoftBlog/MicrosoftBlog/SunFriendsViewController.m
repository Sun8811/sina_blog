//
//  SunFriendsViewController.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-7-30.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunFriendsViewController.h"
#import "ChineseToPinyin.h"
#import "SunHomeViewController.h"
#import "UIImageView+WebCache.h"
@interface SunFriendsViewController ()<SinaWeiboRequestDelegate,UISearchBarDelegate>
@property(nonatomic,retain)NSArray *indexKeys;
@property(nonatomic,retain)NSArray *friendList;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property(retain,nonatomic)NSArray *modifyFriendContacts;
@property(retain,nonatomic)NSMutableDictionary *showContact;
@property(nonatomic,retain)NSArray *sectionsTitle;

@end

@implementation SunFriendsViewController

- (void)requestFriendList
{
    [appDelegate.sinaBlog requestWithURL:@"friendships/friends.json" params:[NSMutableDictionary dictionaryWithObject:appDelegate.sinaBlog.userID forKey:@"uid"] httpMethod:@"GET" delegate:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController ==nil) {
        self.tableView.contentInset =UIEdgeInsetsMake(20, 0, 0, 0);
        self.tableView.contentOffset =CGPointMake(0, -20);

    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestFriendList];
    _showContact =[[NSMutableDictionary alloc]initWithCapacity:10];
    self.indexKeys =[[NSArray alloc]initWithObjects:UITableViewIndexSearch,@"A",@"B", @"C",@"D", @"E", @"F", @"G", @"H", @"I",
    @"J",@"K", @"L", @"M",@"N", @"O", @"P", @"Q", @"R",
    @"S", @"T", @"U", @"V", @"W", @"X",  @"Y", @"Z", @"#", nil];
    self.searchBar.placeholder = @"输入联系人名字";
    self.searchBar.showsBookmarkButton = YES;
    self.searchBar.showsCancelButton =YES;
    
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (title ==UITableViewIndexSearch) {
        [self.tableView scrollRectToVisible:self.searchBar.frame animated:YES];
        return -1;
    }else{
        NSUInteger i =[self.sectionsTitle indexOfObject:title];
        return i;
        
    }
   

}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexKeys;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.sectionsTitle.count;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionsTitle[section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key =self.sectionsTitle[section];
    NSArray *contacts =self.showContact[key];
    return contacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    NSString *key =self.sectionsTitle[indexPath.section];
    cell.textLabel.text =[self.showContact[key][indexPath.row] objectForKey:@"screen_name"];
    NSString *stringUrl =[self.showContact[key][indexPath.row] objectForKey:@"profile_image_url"];
    [cell.imageView setImageWithURL:[NSURL URLWithString:stringUrl]];
    return cell;
}
#pragma mark -------------searchBar Delegate点击的事件----------
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton =YES;
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.showsCancelButton =NO;
    [searchBar resignFirstResponder];
    if (self.navigationController !=nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
  
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self doSearchWithText:searchBar.text];
    
}

#pragma mark--------------取出来朋友列表------------
- (void)creatContactFriendList:(NSArray *)searchContacts
{
    for (NSDictionary *contact in searchContacts) {
        NSString *friendName =[contact objectForKey:@"screen_name"];
        //取出来字母
        NSString *nameFirstLetter =[self getPinyinNameFirstLetter:friendName];
        //判断字母是否是英文字母
        if (!isalpha([nameFirstLetter characterAtIndex:0])) {
            nameFirstLetter =@"#";
        }
        //根据名字的首字母取出来成员列表
        //self。showcontact是字典，它把每个user的screen_name的pinyinshouzimu作为key；
        //        self.showContact[nameFirstLetter]是个数组,通过它可以取得每个key对应的user；
        NSMutableArray *tempContactArray =self.showContact[nameFirstLetter];
        // 如果等空， 表示这个key是首次解析， 所以需要重新创建一个数组，用于存放人员信息
        if (tempContactArray == nil) {
            tempContactArray =[[NSMutableArray alloc]initWithCapacity:10];
            [tempContactArray addObject:contact];
            [self.showContact setValue:tempContactArray forKey:nameFirstLetter];
            SunSafeRelease(tempContactArray);
        }else{
            [tempContactArray addObject:contact];
            
        }
        
        
    }
    //将字典里面的key进行排序
    //将array转化成mutableArray用mutableCopy
    NSMutableArray *titleArray =[[[self.showContact allKeys]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]mutableCopy];
    //将#放到titilearray最后
    NSUInteger index =[titleArray indexOfObject:@"#"];
    //    如果找到了#号对应的数据，则先删险， 然后再移动
    if (index != NSNotFound) {
        [titleArray removeObjectAtIndex:index];
        [titleArray addObject:@"#"];
    }
    //sectionTitle是个数组
    self.sectionsTitle =titleArray;
    SunSafeRelease(titleArray);
    
    
    
    [self.tableView reloadData];
}

- (void)doSearchWithText:(NSString *)searchText
{
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"screen_name CONTAINS[c]%@",searchText];
    NSArray *searchContacts =[self.friendList filteredArrayUsingPredicate:predicate];
    if ([searchText isEqualToString:@""]) {
        searchContacts =[self.friendList copy];
    }
    [self.showContact removeAllObjects];
    [self creatContactFriendList:searchContacts];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText == nil) {
        [self.showContact removeAllObjects];
        [self creatContactFriendList:self.friendList];
    }
    //[self doSearchWithText:searchText];

    
    
}
-(NSString *)getPinyinNameFirstLetter:(NSString *)friendName
{
    NSString *str;
//    if ([friendName canBeConvertedToEncoding:NSASCIIStringEncoding]) {
    if ([[friendName substringToIndex:1] canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        str = [[NSString stringWithFormat:@"%c",[friendName characterAtIndex:0]]uppercaseString];
        
    }else{
        unichar firstLetter =pinyinFirstLetter([friendName characterAtIndex:0]);
        str = [[NSString stringWithFormat:@"%c",firstLetter]uppercaseString];
    }
//    NSLog(@">>>>%@",str);
    return str;
}
#pragma mark ----------sinaBlogRequestDelegate----------
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    //  遍历friendList的所有元素，根据friendList的素情况进行数据转换
    //    首先，将每个人的名字取出，然后判断这个名字是否是英文字母， 如果是，则提取出来，做为字典的key来构建数据， 如果不是， 则需要将其转化为拼音或者是英文字母，再提出构建字典
    //self.friendList 是数组，里面的对象是所关注的人；
    self.friendList = [result objectForKey:@"users"];
    //因为self.friendList数组里面的每个对象是字典所以用字典来遍历每个人user 取出来他们的screen_name和拼音首字母；
    [self creatContactFriendList:self.friendList];
}

- (void)dealloc {
    [_searchBar release];
    SunSafeRelease(_showContact);
    
    [super dealloc];
}
@end
