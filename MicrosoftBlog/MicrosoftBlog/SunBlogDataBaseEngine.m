//
//  SunBlogDataBaseEngine.m
//  MicrosoftBlog
//
//  Created by qingyun on 14-8-8.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "SunBlogDataBaseEngine.h"
#import "FMDatabase.h"

@interface SunBlogDataBaseEngine ()
@property(nonatomic,retain)FMDatabase *mdb;
@end

@implementation SunBlogDataBaseEngine

+(instancetype)shareInstance
{
    static SunBlogDataBaseEngine *dbEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbEngine =[[self alloc]init];
    });
    return dbEngine;
}
-(id)init
{
    self =[super init];
    if (self) {
        NSString *dataBaseName =[NSString stringWithFormat:@"%@.sqlite",kSunBlogDataBaseName];
        //这个路径就是在documents路径下的绝对路径
        NSString *dbPath =[self copyDataBase2Documents:dataBaseName];
        //创建一个数据库在mac上，当退出的时候会销毁
        self.mdb =[FMDatabase databaseWithPath:dbPath];
        if (![self.mdb open]) {
            NSLog(@"open %@error,error message %@",dbPath,[self.mdb lastErrorMessage]);
        }
    }
    return self;
}
#pragma mark---------------保存数据---------------------
-(void)savaUserInfo2DataBase:(NSDictionary *)dictUserInfo withStatusID:(NSString *)statusID
{
    if (dictUserInfo !=nil) {
        NSString *sql =@"insert into T_USER(id,user_id,screen_name,name,status_id,avatar_large)values(null,?,?,?,?,?)";
      BOOL isOK =  [self.mdb executeUpdate:sql,[dictUserInfo objectForKey:@"id"],[dictUserInfo objectForKey:@"screen_name"],[dictUserInfo objectForKey:@"name"],statusID,[dictUserInfo objectForKey:@"avatar_large"] ];
        if (!isOK) {
            NSLog(@"error is %@",[self.mdb lastErrorMessage]);
            return;
        }
        
    }
}
-(void)saveStatus2DataBase:(NSDictionary *)dictStatus
{
    NSLog(@"%s",__func__);
    NSString *sql =@"insert into T_STATUS (id,status_id,created_at,text,source,thumbnail_pic,\
    original_pic,user_id,retweeted_status_id,reposts_count,\
    comments_count,attitudes_count) VALUES \
    (null,?,?,?,?,?,?,?,?,?,?,?)";
   BOOL isOK = [ self.mdb executeUpdate:sql,[dictStatus objectForKey:@"id"],[dictStatus objectForKey:@"created_at"],[dictStatus objectForKey:@"text"],[dictStatus objectForKey:@"source"],[dictStatus objectForKey:@"thumbnail_pic"],[dictStatus objectForKey:@"original_pic"],[[dictStatus objectForKey:@"user"]objectForKey:@"id"],[[dictStatus objectForKey:@"retweeted_status"] objectForKey:@"id"],[dictStatus objectForKey:@"reposts_count"],[dictStatus objectForKey:@"comments_count"],[dictStatus objectForKey:@"attitudes_count"]];
    if (!isOK) {
        NSLog(@"=+++++++==%@",[self.mdb lastErrorMessage]);
        return;
    }
    //通过微博ID找到用户信息保存起来
    [self savaUserInfo2DataBase:[dictStatus objectForKey:@"user"] withStatusID:[dictStatus objectForKey:@"id"]];
    //判断是否有转发微博,如果有则需要递归，将转发的微博保存到数据库
    
    NSDictionary *reweetStatus =[dictStatus objectForKey:@"retweeted_status"];
    if (reweetStatus !=nil) {
        [self saveStatus2DataBase:reweetStatus];
    }else{
        NSLog(@"Warrning:save data parame is emporty");

    }
    
}


-(void)saveTimeLines2DataBase:(NSArray *)timeLines
{
    for (NSDictionary *dict in timeLines) {
        [self saveStatus2DataBase:dict];
    }
}
#pragma mark--------------吧数据库复制到documents文件夹下-------------------------
//将数据库文件从资源库目录复制到Documents目录，由于沙盒目录只有Documents目录明确表示可以读写数据
-(NSString *)copyDataBase2Documents:(NSString *)fileName
{
    NSFileManager *fileManager =[NSFileManager  defaultManager];
    
    NSError *error =nil;
    //找到documents路径
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    //得到沙盒路径目录
    NSString *documentDirect =paths[0];
    //将数据库文件名追加到Doucuments目录后面，生成一个绝对路径
    //这里面的filename是数据库的名字
    NSString *destPath =[documentDirect stringByAppendingPathComponent:fileName];
    
    //如果没有当前文件，就复制进去，如果存在，就没有必要复制
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *southPath =[[NSBundle mainBundle]pathForResource:kSunBlogDataBaseName ofType:@"sqlite"];
        [fileManager copyItemAtPath:southPath toPath:destPath error:&error];
        if (error !=nil) {
            NSLog(@"%@",error);
            return @"";
        }
    }
    return destPath;
}
#pragma mark------------从数据库获取信息--------------
-(NSArray*)queryTimeLinesFromDataBase
{
    
    //从数据库获取最近的20条微博信息
    NSString *sql=@"SELECT status_id,created_at,text,source, thumbnail_pic,\
    original_pic,user_id,retweeted_status_id, reposts_count,comments_count,attitudes_count\
    FROM T_STATUS \
    where created_at < ? limit 20";
    
    //格式化事件style
    NSDateFormatter *dateFormate =[[NSDateFormatter alloc]init];
    [dateFormate setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    NSString *currentTime =[dateFormate stringFromDate:[NSDate date]];
    
    FMResultSet *result =[self.mdb executeQuery:sql,currentTime];
    NSMutableArray *arrayRet =[[NSMutableArray alloc]initWithCapacity:20];

    //取出来用户信息
    while ([result next])
    {
        NSDictionary *userInfo = [self queryUserInfoFromDataBase:[result objectForColumnIndex:6]];
        if (nil ==  userInfo)
        {
            NSLog(@"<><><><>");
            return nil;
        }
    //取出来微博信息
        NSDictionary *statusInfo =[self queryStatusFromDataBase:[result objectForColumnIndex:7]];
    //判断是否有转发微博，如果有则读出来
        if (statusInfo !=nil)
        {
            [arrayRet addObject:@{@"id": [result objectForColumnIndex:0],
                                  @"created_at": [result objectForColumnIndex:1],
                                  @"text": [result objectForColumnIndex:2],
                                  @"source":[result objectForColumnIndex:3],
                                  @"thumbnail_pic":[result objectForColumnIndex:4],
                                  @"original_pic":[result objectForColumnIndex:5],
                                  @"user": userInfo,
                                  @"retweeted_status":statusInfo,
                                  @"reposts_count":[result objectForColumnIndex:8],
                                  @"comments_count":[result objectForColumnIndex:9],
                                  @"attitudes_count":[result objectForColumnIndex:10]
                                  }];
        }else{
            [arrayRet addObject:@{@"id": [result objectForColumnIndex:0],
                                  @"created_at": [result objectForColumnIndex:1],
                                  @"text": [result objectForColumnIndex:2],
                                  @"source":[result objectForColumnIndex:3],
                                  @"thumbnail_pic":[result objectForColumnIndex:4],
                                  @"original_pic":[result objectForColumnIndex:5],
                                  @"user": userInfo,
                                  @"avatar_large":[userInfo objectForKey:@"avatar_large"],
                                  @"reposts_count":[result objectForColumnIndex:8],
                                  @"comments_count":[result objectForColumnIndex:9],
                                  @"attitudes_count":[result objectForColumnIndex:10]
                                  }];
        }
    }
    
    
    return arrayRet;
}

-(NSDictionary *)queryUserInfoFromDataBase:(NSString *)userID
{
    NSString *sql = @"SELECT user_id,screen_name,name,avatar_large FROM T_USER where user_id = ?";
    FMResultSet *result = [self.mdb executeQuery:sql,userID];
    NSDictionary *decRet = nil;
    while ([result next]) {
        decRet =@{@"id": [result objectForColumnIndex:0],
                  @"sceen_name": [result objectForColumnIndex:1],
                  @"name": [result objectForColumnIndex:2],
                  @"avatar_large": [result objectForColumnIndex:3]
                  };
    }
    return decRet;
}
-(NSDictionary *)queryStatusFromDataBase:(NSString *)statusID
{
    NSString *sql = @"SELECT created_at,text,source,thumbnail_pic,original_pic\
    reposts_count,comments_count,attitudes_count FROM T_STATUS where status_id = ?";
    FMResultSet *result =[self.mdb executeQuery:sql,statusID];
    NSDictionary *dicStatus = nil;
    while ([result next]) {
        dicStatus =@{@"id": statusID,
                     @"created_at" : [result objectForColumnIndex:0],
                     @"text": [result objectForColumnIndex:1],
                     @"source" : [result objectForColumnIndex:2],
                     @"thumbnail_pic" : [result objectForColumnIndex:3],
                     @"original_pic" : [result objectForColumnIndex:4],
                     @"reposts_count":[result objectForColumnIndex:5],
                     @"comments_count":[result objectForColumnIndex:6],
                     @"attitudes_count":[result objectForColumnIndex:7]
                     };
    }
    return dicStatus;
}
@end
