//
//  ZCPhotoBrowser.h
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZCPhotoBrowser;

@protocol ZCPhotoBrowserDelegate <NSObject>
@required
/// 实现本方法以返回图片数量
- (NSInteger)numberOfPhotos:(ZCPhotoBrowser *)photoBrowser;

/// 实现本方法以返回默认图片，缩略图或占位图
- (UIImage *)photoBrowser:(ZCPhotoBrowser *)photoBrowser thumbnailImageForIndex:(NSInteger)index;

/// 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
/// 比如你可返回ImageView，或整个Cell
- (UIView *)photoBrowser:(ZCPhotoBrowser *)photoBrowser thumbnailViewForIndex:(NSInteger)index;

@optional
/// 实现本方法已返回默认图。可选
- (UIImage *)photoBrowser:(ZCPhotoBrowser *)photoBrowser placeholderImageForIndex:(NSInteger)index;

/// 实现本方法以返回高质量图片的url。可选
- (NSURL *)photoBrowser:(ZCPhotoBrowser *)photoBrowser highQualityUrlForIndex:(NSInteger)index;

/// 实现本方法以返回原图url。可选
- (NSURL *)photoBrowser:(ZCPhotoBrowser *)photoBrowser rawUrlForIndex:(NSInteger)index;

/// 长按时回调。可选
- (UIImage *)photoBrowser:(ZCPhotoBrowser *)photoBrowser didLongPressForIndex:(NSInteger)index andImage:(UIImage *)image;

@end


@protocol ZCPhotoBrowserPageControlDelegate <NSObject>

/// 取PageControl，只会取一次
- (UIView *)pageControlOfPhotoBrowser:(ZCPhotoBrowser *)photoBrowser;

/// 添加到父视图上时调用
- (void)photoBrowserPageControl:(UIView *)pageControl didMoveTo:(UIView *)superView;

/// 让pageControl布局时调用
- (void)photoBrowserPageControl:(UIView *)pageControl needLayoutIn:(UIView *)superView;

/// 页码变更时调用
- (void)photoBrowserPageControl:(UIView *)pageControl didChangedCurrentPage:(NSUInteger)currentPage;

@end


@interface ZCPhotoBrowser : UIViewController

@property (nonatomic, weak) id<ZCPhotoBrowserDelegate> photoBrowserDelegate;
@property (nonatomic, weak) id<ZCPhotoBrowserPageControlDelegate> photoBrowserPageControlDelegate;

/// 当前显示的图片序号，从0开始
@property (nonatomic, assign) NSUInteger currentIndex;

/// 左右两张图之间的间隙, defualt is 30
@property (nonatomic, assign) CGFloat photoSpacing;

/// 图片缩放模式, defualt is UIViewContentModeScaleAspectFill
@property (nonatomic, assign) UIViewContentMode imageScaleMode;

/// 捏合手势放大图片时的最大允许比例, defualt is 2.0
@property (nonatomic, assign) CGFloat imageMaximumZoomScale;

/// 双击放大图片时的目标比例, defualt is 2.0
@property (nonatomic, assign) CGFloat imageZoomScaleForDoubleTap;


/// 初始化，传入用于present出本VC的VC，以及实现了PhotoBrowserDelegate协议的对象
- (instancetype)initWithPresentingViewController:(UIViewController *)presentingVC
                                     andDelegate:(id<ZCPhotoBrowserDelegate>)delegate;

/// 展示，传入图片序号，从0开始
- (void)showAtIndex:(NSUInteger)index;

@end
