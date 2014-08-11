//
//  JLRefreshBaseView.h
//  JLRefresh
//  
//  Created by JL on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>

/**
 枚举
 */
// 控件的刷新状态
typedef enum {
	JLRefreshStatePulling = 1, // 松开就可以进行刷新的状态
	JLRefreshStateNormal = 2, // 普通状态
	JLRefreshStateRefreshing = 3, // 正在刷新中的状态
    JLRefreshStateWillRefreshing = 4
} JLRefreshState;

// 控件的类型
typedef enum {
    JLRefreshViewTypeHeader = -1, // 头部控件
    JLRefreshViewTypeFooter = 1 // 尾部控件
} JLRefreshViewType;

@class JLRefreshBaseView;

/**
 回调的Block定义
 */
// 开始进入刷新状态就会调用
typedef void (^BeginRefreshingBlock)(JLRefreshBaseView *refreshView);
// 刷新完毕就会调用
typedef void (^EndRefreshingBlock)(JLRefreshBaseView *refreshView);
// 刷新状态变更就会调用
typedef void (^RefreshStateChangeBlock)(JLRefreshBaseView *refreshView, JLRefreshState state);

/**
 代理的协议定义
 */
@protocol JLRefreshBaseViewDelegate <NSObject>
@optional
// 开始进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(JLRefreshBaseView *)refreshView;
// 刷新完毕就会调用
- (void)refreshViewEndRefreshing:(JLRefreshBaseView *)refreshView;
// 刷新状态变更就会调用
- (void)refreshView:(JLRefreshBaseView *)refreshView stateChange:(JLRefreshState)state;
@end

/**
 类的声明
 */
@interface JLRefreshBaseView : UIView
{
    // 父控件一开始的contentInset
    UIEdgeInsets _scrollViewInitInset;
    // 父控件
    __weak UIScrollView *_scrollView;
    
    // 子控件
    __weak UILabel *_lastUpdateTimeLabel;
	__weak UILabel *_statusLabel;
    __weak UIImageView *_arrowImage;
	__weak UIActivityIndicatorView *_activityView;
    
    // 状态
    JLRefreshState _state;
}

// 构造方法
- (instancetype)initWithScrollView:(UIScrollView *)scrollView;
// 设置要显示的父控件
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic,assign)BOOL isCanRefresh;
// 内部的控件
@property (nonatomic, retain, readonly) UILabel *lastUpdateTimeLabel;
@property (nonatomic, retain, readonly) UILabel *statusLabel;
@property (nonatomic, retain, readonly) UIImageView *arrowImage;

// Block回调
@property (nonatomic, copy) BeginRefreshingBlock beginRefreshingBlock;
@property (nonatomic, copy) RefreshStateChangeBlock refreshStateChangeBlock;
@property (nonatomic, copy) EndRefreshingBlock endStateChangeBlock;
// 代理
@property (nonatomic, assign) id<JLRefreshBaseViewDelegate> delegate;

// 是否正在刷新
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
// 开始刷新
- (void)beginRefreshing;
// 结束刷新
- (void)endRefreshing;
// 不静止地结束刷新
//- (void)endRefreshingWithoutIdle;
// 结束使用、释放资源
- (void)free;

/**
 交给子类去实现 和 调用
 */
- (void)setState:(JLRefreshState)state;
- (int)totalDataCountInScrollView;
@end