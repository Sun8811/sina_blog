//
//  SunBlogDataBaseEngine.h
//  MicrosoftBlog
//
//  Created by qingyun on 14-8-8.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunBlogDataBaseEngine : NSObject
//由于考虑到数据库的使用，在整个工程， 使用一个数据库对象就可以满足各个界面的需求，所以需要用到单例设计模式
+(instancetype)shareInstance;
//将单条微博数据保存到数据库里，意味可以传递一个字典作参数
-(void)saveStatus2DataBase:(NSDictionary *)dictStatus;
//将多条微博数据保存到数据库， 意味着可以传一个数组， 数组里的元素是字典对象
-(void)saveTimeLines2DataBase:(NSArray *)timeLines;
//将用户信息保存到数据库
-(void)savaUserInfo2DataBase:(NSDictionary *)dictUserInfo withStatusID:(NSString*)statusID;
//保存草稿数据到草稿箱
-(void)savaTempStatus2DataBase:(NSDictionary *)tempStatus;

//获取数据库里的微博数据
-(NSArray *)queryTimeLinesFromDataBase;

//从数据里获取草稿箱的数据
-(NSArray *)queryTempStatusFromDataBase;

//从数据库里获取用户信息
-(NSDictionary *)queryUserInfoFromDataBase:(NSString *)userID;

//从数据库里获取微博虎踞
-(NSDictionary *)queryStatusFromDataBase:(NSString *)statusID;

@end
