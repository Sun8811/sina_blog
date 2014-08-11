//
//  JLRefreshConst.h
//  JLRefresh
//
//  Created by JL on 14-1-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#ifdef DEBUG
#define JLLog(...) NSLog(__VA_ARGS__)
#else
#define JLLog(...)
#endif

// 文字颜色
#define JLRefreshLabelTextColor [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]

extern const CGFloat JLRefreshViewHeight;
extern const CGFloat JLRefreshAnimationDuration;

extern NSString *const JLRefreshBundleName;
#define kSrcName(file) [JLRefreshBundleName stringByAppendingPathComponent:file]

extern NSString *const JLRefreshFooterPullToRefresh;
extern NSString *const JLRefreshFooterReleaseToRefresh;
extern NSString *const JLRefreshFooterRefreshing;

extern NSString *const JLRefreshHeaderPullToRefresh;
extern NSString *const JLRefreshHeaderReleaseToRefresh;
extern NSString *const JLRefreshHeaderRefreshing;
extern NSString *const JLRefreshHeaderTimeKey;

extern NSString *const JLRefreshContentOffset;
extern NSString *const JLRefreshContentSize;