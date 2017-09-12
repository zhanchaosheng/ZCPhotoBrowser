//
//  ZCPhotoBrowser.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ZCPhotoBrowser.h"
#import "ZCPhotoBrowserLayout.h"
#import "ZCPhotoBrowserCell.h"
#import "ZCScaleAnimator.h"
#import "ZCScaleAnimatorCoordinator.h"

@interface ZCPhotoBrowser ()<UICollectionViewDataSource,UICollectionViewDelegate,
UIViewControllerTransitioningDelegate,ZCPhotoBrowserCellDelegate>

/// 当前正在显示视图的前一个页面关联视图
@property (nonatomic, strong) UIView *relatedView;
/// 本VC的presentingViewController
@property (nonatomic, strong) UIViewController *presentingVC;
/// 容器
@property (nonatomic, strong) UICollectionView *collectionView;
/// 容器layout
@property (nonatomic, strong) ZCPhotoBrowserLayout *flowLayout;
/// presentation转场动画
@property (nonatomic, weak) ZCScaleAnimator *presentationAnimator;
/// 转场协调器
@property (nonatomic, weak) ZCScaleAnimatorCoordinator *animatorCoordinator;

/// PageControl
@property (nonatomic, strong) UIView *pageControl;
/// 标记第一次viewDidAppeared
@property (nonatomic, assign) BOOL onceViewDidAppeared;
/// 保存原windowLevel
@property (nonatomic, assign) UIWindowLevel originWindowLevel;

@end

@implementation ZCPhotoBrowser

- (instancetype)initWithPresentingViewController:(UIViewController *)presentingVC
                                     andDelegate:(id<ZCPhotoBrowserDelegate>)delegate {
    self = [super init];
    if (self) {
        _photoSpacing = 30;
        _imageScaleMode = UIViewContentModeScaleAspectFill;
        _imageMaximumZoomScale = 2.0;
        _imageZoomScaleForDoubleTap = 2.0;
        _originWindowLevel = -1;
        _presentingVC = presentingVC;
        _photoBrowserDelegate = delegate;
        _flowLayout = [[ZCPhotoBrowserLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:self.flowLayout];
    }
    return self;
}

- (void)showAtIndex:(NSUInteger)index {
    self.currentIndex = index;
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    [self.presentingVC presentViewController:self animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // flowLayout
    self.flowLayout.minimumLineSpacing = self.photoSpacing;
    self.flowLayout.itemSize = self.view.bounds.size;
    
    // collectionView
    self.collectionView.frame = self.view.bounds;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[ZCPhotoBrowserCell class]
            forCellWithReuseIdentifier:NSStringFromClass([ZCPhotoBrowserCell class])];
    [self.view addSubview:self.collectionView];
    
    // 立即加载collectionView
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:NO];
    [self.collectionView layoutIfNeeded];
    // 取当前应显示的cell，完善转场动画器的设置
    ZCPhotoBrowserCell *cell = (ZCPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZCPhotoBrowserCell class]]) {
        self.presentationAnimator.endView = cell.imageView;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
        imageView.contentMode = self.imageScaleMode;
        imageView.clipsToBounds = YES;
        self.presentationAnimator.scaleView = imageView;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 遮盖状态栏
    [self coverStatusBar:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 页面出来后，再显示pageControl
    if ([self.photoBrowserPageControlDelegate respondsToSelector:@selector(photoBrowserPageControl:didMoveTo:)] &&
        [self.photoBrowserPageControlDelegate respondsToSelector:@selector(photoBrowserPageControl:needLayoutIn:)]) {
        if (!self.onceViewDidAppeared && self.pageControl) {
            self.onceViewDidAppeared = YES;
            [self.view addSubview:self.pageControl];
            [self.photoBrowserPageControlDelegate photoBrowserPageControl:self.pageControl
                                                                didMoveTo:self.view];
        }
        [self.photoBrowserPageControlDelegate photoBrowserPageControl:self.pageControl
                                                         needLayoutIn:self.view];
    }
}

/// 禁止旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - getter & setter

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    _currentIndex = currentIndex;
    [self.animatorCoordinator updateCurrentHiddenView:self.relatedView];
    if (self.pageControl &&
        [self.photoBrowserPageControlDelegate respondsToSelector:@selector(photoBrowserPageControl:didChangedCurrentPage:)]) {
        [self.photoBrowserPageControlDelegate photoBrowserPageControl:self.pageControl
                                                didChangedCurrentPage:currentIndex];
    }
}

- (UIView *)pageControl {
    if (_pageControl == nil) {
        if ([self.photoBrowserPageControlDelegate respondsToSelector:@selector(pageControlOfPhotoBrowser:)]) {
            _pageControl = [self.photoBrowserPageControlDelegate pageControlOfPhotoBrowser:self];
        }
    }
    return _pageControl;
}

- (UIView *)relatedView {
    if ([self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:thumbnailViewForIndex:)]) {
        return [self.photoBrowserDelegate photoBrowser:self thumbnailViewForIndex:self.currentIndex];
    }
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.photoBrowserDelegate respondsToSelector:@selector(numberOfPhotos:)]) {
        return [self.photoBrowserDelegate numberOfPhotos:self];
    }
    else {
        return 0;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZCPhotoBrowserCell *cell = (ZCPhotoBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZCPhotoBrowserCell class]) forIndexPath:indexPath];
    cell.photoBrowserCellDelegate = self;
    cell.imageView.contentMode = self.imageScaleMode;
    cell.imageMaximumZoomScale = self.imageMaximumZoomScale;
    cell.imageZoomScaleForDoubleTap = self.imageZoomScaleForDoubleTap;
    [self setCellImage:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 减速完成后，计算当前页
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width + self.photoSpacing;
    self.currentIndex = (NSUInteger)(offsetX / width);
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    // 在本方法被调用时，endView和scaleView还未确定。需于viewDidLoad方法中给animator赋值endView
    ZCScaleAnimator *animator = [[ZCScaleAnimator alloc] initWithStartView:self.relatedView
                                                                   endView:nil
                                                                 scaleView:nil];
    self.presentationAnimator = animator;
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    ZCPhotoBrowserCell *cell = [self.collectionView.visibleCells firstObject];
    if (![cell isKindOfClass:[ZCPhotoBrowserCell class]]) {
        return nil;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    imageView.contentMode = self.imageScaleMode;
    imageView.clipsToBounds = YES;
    
    return [[ZCScaleAnimator alloc] initWithStartView:cell.imageView
                                              endView:self.relatedView
                                            scaleView:imageView];
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    ZCScaleAnimatorCoordinator *coordinator = [[ZCScaleAnimatorCoordinator alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    coordinator.currentHiddenView = self.relatedView;
    self.animatorCoordinator = coordinator;
    return coordinator;
}

#pragma mark - ZCPhotoBrowserCellDelegate
/// 单击时回调
- (void)photoBrowserCellDidSingleTap:(ZCPhotoBrowserCell *)cell {
    [self coverStatusBar:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 拖动时回调。scale:缩放比率
- (void)photoBrowserCell:(ZCPhotoBrowserCell *)cell didPanScale:(CGFloat)scale {
    if (self.animatorCoordinator) {
        // 实测用scale的平方，效果比线性好些
        CGFloat alpha = scale * scale;
        self.animatorCoordinator.maskView.alpha = alpha;
        // 半透明时重现状态栏，否则遮盖状态栏
        [self coverStatusBar:(alpha >= 1.0)];
    }
}

/// 长按时回调
- (void)photoBrowserCell:(ZCPhotoBrowserCell *)cell didLongPressWithImage:(UIImage *)image {
    if ([self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:didLongPressForIndex:andImage:)]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath) {
            [self.photoBrowserDelegate photoBrowser:self didLongPressForIndex:indexPath.item andImage:image];
        }
    }
}

#pragma mark - private
- (void)setCellImage:(ZCPhotoBrowserCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    UIImage *placeholder = nil;
    if ([self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        placeholder = [self.photoBrowserDelegate photoBrowser:self placeholderImageForIndex:item];
    }
    NSURL *highQualityUrl = nil;
    if ([self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:highQualityUrlForIndex:)]) {
        highQualityUrl = [self.photoBrowserDelegate photoBrowser:self highQualityUrlForIndex:item];
    }
    NSURL *rawUrl = nil;
    if ([self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:rawUrlForIndex:)]) {
        rawUrl = [self.photoBrowserDelegate photoBrowser:self rawUrlForIndex:item];
    }
    [cell setImageWithPlaceholder:placeholder highQuality:highQualityUrl raw:rawUrl];
}

/// 遮盖状态栏。以改变windowLevel的方式遮盖
- (void)coverStatusBar:(BOOL)cover {
    UIWindow *window = self.view.window ? self.view.window : [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        return;
    }
    if (self.originWindowLevel == -1) {
        self.originWindowLevel = window.windowLevel;
    }
    if (cover) {
        if (window.windowLevel == UIWindowLevelStatusBar + 1) {
            return;
        }
        window.windowLevel = UIWindowLevelStatusBar + 1;
    }
    else {
        if (window.windowLevel == self.originWindowLevel) {
            return;
        }
        window.windowLevel = self.originWindowLevel;
    }
}

#pragma mark - 3D Touch

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    NSMutableArray *arrItem = [NSMutableArray array];
    
    UIPreviewAction *previewAction0 = [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        NSLog(@"预览菜单\"取消\"");
    }];
    
    UIPreviewAction *previewAction1 = [UIPreviewAction actionWithTitle:@"相关操作" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"预览菜单\"相关操作\"");
        
    }];
    
    [arrItem addObjectsFromArray:@[previewAction0 ,previewAction1]];
    
    return arrItem;
}

@end
