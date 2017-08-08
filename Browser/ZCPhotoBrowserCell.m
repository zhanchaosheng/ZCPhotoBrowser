//
//  ZCPhotoBrowserCell.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ZCPhotoBrowserCell.h"
#import "ZCPhotoBrowserProgressView.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ZCPhotoBrowserCell()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
/// 加载进度指示器
@property (nonatomic, strong) ZCPhotoBrowserProgressView *progressView;
/// 计算contentSize应处于的中心位置
@property (nonatomic, assign) CGPoint centerOfContentSize;
/// 查看原图按钮
@property (nonatomic, strong) UIButton *rawImageButton;
/// 取图片适屏size
@property (nonatomic, assign) CGSize fitSize;
/// 取图片适屏frame
@property (nonatomic, assign) CGRect fitFrame;
/// 记录pan手势开始时imageView的位置
@property (nonatomic, assign) CGRect beganFrame;
/// 记录pan手势开始时，手势位置
@property (nonatomic, assign) CGPoint beganTouch;

@end

@implementation ZCPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageMaximumZoomScale = 2.0;
        _imageZoomScaleForDoubleTap = 2.0;
        _beganFrame = CGRectZero;
        _beganTouch = CGPointZero;
        
        _scrollView = [[UIScrollView alloc] init];
        [self.contentView addSubview:_scrollView];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = _imageMaximumZoomScale;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.showsHorizontalScrollIndicator = false;
        
        _imageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_imageView];
        _imageView.clipsToBounds = true;
        
        _progressView = [[ZCPhotoBrowserProgressView alloc] init];
        [self.contentView addSubview:_progressView];
        _progressView.hidden = YES;
        
        // 长按手势
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(onLongPress:)];
        [self.contentView addGestureRecognizer:longPress];
        
        // 双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(onDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:doubleTap];
        
        // 单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(onSingleTap:)];
        [self.contentView addGestureRecognizer:singleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        // 拖动手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onPan:)];
        pan.delegate = self;
        [_scrollView addGestureRecognizer:pan];

    }
    return self;
}

- (void)setImageWithPlaceholder:(UIImage *)image
                    highQuality:(NSURL *)highQualityUrl
                            raw:(NSURL *)rawUrl {
    // 查看原图按钮
    self.rawImageButton.hidden = (rawUrl == nil);
    self.rawUrl = rawUrl;
    
    // 取placeholder图像，默认使用传入的缩略图
    UIImage *placeholder = image;
    // 若已有原图缓存，优先使用原图
    // 次之使用高清图
    NSURL *url = highQualityUrl;
    UIImage *cacheImage = [self imageForURL:rawUrl];
    if (cacheImage) {
        self.rawImageButton.hidden = YES;
        self.imageView.image = cacheImage;
        [self doLayout];
        return;
    }
    else {
        cacheImage = [self imageForURL:highQualityUrl];
        if (cacheImage) {
            self.imageView.image = cacheImage;
            [self doLayout];
            return;
        }
    }
    
    // 处理只配置了原图而不配置高清图的情况。此时使用原图代替高清图作为下载url
    if (url == nil) {
        url = rawUrl;
    }
    if (url == nil) {
        self.imageView.image = image;
        [self doLayout];
        return;
    }
    [self loadImageWithPlaceholder:placeholder andURL:url];
    [self doLayout];
}

#pragma mark - getter & setter

- (void)setImageMaximumZoomScale:(CGFloat)imageMaximumZoomScale {
    _imageMaximumZoomScale = imageMaximumZoomScale;
    self.scrollView.maximumZoomScale = imageMaximumZoomScale;
}

/// 计算contentSize应处于的中心位置
- (CGPoint)centerOfContentSize {
    CGFloat deltaWidth = self.bounds.size.width - self.scrollView.contentSize.width;
    CGFloat offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0;
    CGFloat deltaHeight = self.bounds.size.height - self.scrollView.contentSize.height;
    CGFloat offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0;
    return CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,
                       self.scrollView.contentSize.height * 0.5 + offsetY);
}

- (UIButton *)rawImageButton {
    if (_rawImageButton == nil) {
        _rawImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rawImageButton setTitle:@"查看原图" forState:UIControlStateNormal];
        [_rawImageButton setTitle:@"查看原图" forState:UIControlStateHighlighted];
        [_rawImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rawImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _rawImageButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _rawImageButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _rawImageButton.layer.borderWidth = 1;
        _rawImageButton.layer.cornerRadius = 4;
        _rawImageButton.layer.masksToBounds = YES;
        [_rawImageButton addTarget:self
                            action:@selector(onRawImageButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _rawImageButton;
}

- (CGSize)fitSize {
    if (self.imageView.image) {
        CGFloat width = self.scrollView.bounds.size.width;
        CGFloat scale = self.imageView.image.size.height / self.imageView.image.size.width;
        return CGSizeMake(width, scale * width);
    }
    else {
        return CGSizeZero;
    }
}

- (CGRect)fitFrame {
    CGSize size = self.fitSize;
    CGFloat y = (self.scrollView.bounds.size.height - size.height) > 0 ? (self.scrollView.bounds.size.height - size.height) * 0.5 : 0;
    return CGRectMake(0, y, size.width, size.height);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = self.centerOfContentSize;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 只响应pan手势
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint velocity = [pan velocityInView:self];
    // 向上滑动时，不响应手势
    if (velocity.y < 0) {
        return NO;
    }
    // 横向滑动时，不响应pan手势
    if (fabs(velocity.x) > velocity.y) {
        return NO;
    }
    // 向下滑动，如果图片顶部超出可视区域，不响应手势
    if (self.scrollView.contentOffset.y > 0) {
        return NO;
    }

    return YES;
}

#pragma mark - target & event
/// 响应查看原图按钮
- (void)onRawImageButton:(UIButton *)sender {
    [self loadImageWithPlaceholder:self.imageView.image andURL:self.rawUrl];
    self.rawImageButton.hidden = YES;
}

/// 响应长按
- (void)onLongPress:(UILongPressGestureRecognizer *)gesturer {
    if (gesturer.state == UIGestureRecognizerStateBegan &&
        [self.photoBrowserCellDelegate respondsToSelector:@selector(photoBrowserCell:didLongPressWithImage:)] &&
        self.imageView.image) {
        [self.photoBrowserCellDelegate photoBrowserCell:self didLongPressWithImage:self.imageView.image];
    }
}

/// 响应双击
- (void)onDoubleTap:(UITapGestureRecognizer *)gesturer {
    // 如果当前没有任何缩放，则放大到目标比例
    // 否则重置到原比例
    if (![self isZoomScale]) {
        // 以点击的位置为中心，放大
        CGPoint pointInView = [gesturer locationInView:self.imageView];
        CGFloat w = self.scrollView.bounds.size.width / self.imageZoomScaleForDoubleTap;
        CGFloat h = self.scrollView.bounds.size.height / self.imageZoomScaleForDoubleTap;
        CGFloat x = pointInView.x - (w / 2.0);
        CGFloat y = pointInView.y - (h / 2.0);
        [self.scrollView zoomToRect:CGRectMake(x, y, w, h) animated:YES];
    }
    else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

/// 响应单击
- (void)onSingleTap:(UIGestureRecognizer *)gesturer {
    if ([self.photoBrowserCellDelegate respondsToSelector:@selector(photoBrowserCellDidSingleTap:)]) {
        [self.photoBrowserCellDelegate photoBrowserCellDidSingleTap:self];
    }
}

/// 响应拖动
- (void)onPan:(UIPanGestureRecognizer *)gesturer {
    switch (gesturer.state) {
        case UIGestureRecognizerStateBegan: {
            self.beganFrame = self.imageView.frame;
            self.beganTouch = [gesturer locationInView:self.scrollView];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // 拖动偏移量
            CGPoint translation = [gesturer translationInView:self.scrollView];
            CGPoint currentTouch = [gesturer locationInView:self.scrollView];
            
            // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
            CGFloat scale = MIN(1.0, MAX(0.3, 1 - translation.y / self.bounds.size.height));
            CGFloat width = self.beganFrame.size.width * scale;
            CGFloat height = self.beganFrame.size.height * scale;
            // 计算x和y。保持手指在图片上的相对位置不变。
            // 即如果手势开始时，手指在图片X轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
            CGFloat xRate = (self.beganTouch.x - self.beganFrame.origin.x) / self.beganFrame.size.width;
            CGFloat currentTouchDeltaX = xRate * width;
            CGFloat x = currentTouch.x - currentTouchDeltaX;
            
            CGFloat yRate = (self.beganTouch.y - self.beganFrame.origin.y) / self.beganFrame.size.height;
            CGFloat currentTouchDeltaY = yRate * height;
            CGFloat y = currentTouch.y - currentTouchDeltaY;
            
            self.imageView.frame = CGRectMake(x, y, width, height);
            
            // 通知代理，发生了缩放。代理可依scale值改变背景蒙板alpha值
            if ([self.photoBrowserCellDelegate respondsToSelector:@selector(photoBrowserCell:didPanScale:)]) {
                [self.photoBrowserCellDelegate photoBrowserCell:self didPanScale:scale];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if ([gesturer velocityInView:self].y > 0) {
                // dismiss
                [self onSingleTap:gesturer];
            }
            else {
                // 取消dismiss
                [self endPan];
            }
            break;
        }
        default:
            [self endPan];
            break;
    }
}

- (void)endPan {
    if ([self.photoBrowserCellDelegate respondsToSelector:@selector(photoBrowserCell:didPanScale:)]) {
        [self.photoBrowserCellDelegate photoBrowserCell:self didPanScale:1.0];
    }
    if ([self isZoomScale]) {
        [self.scrollView setZoomScale:1.0 animated:NO];
    }
    // 如果图片当前显示的size小于原size，则重置为原size
    CGSize size = self.fitSize;
    BOOL needResetSize = self.imageView.bounds.size.width < size.width || self.imageView.bounds.size.height < size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.center = self.centerOfContentSize;
        if (needResetSize) {
            //CGRect frame = self.imageView.frame;
            //self.imageView.frame = CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height);
            self.imageView.frame = self.fitFrame;
        }
    }];
}

#pragma mark - private

/// 布局
- (void)doLayout {
    if ([self isZoomScale]) {
        NSLog(@"isZoomScale!!!");
    }
    self.scrollView.frame = self.contentView.bounds;
    [self.scrollView setZoomScale:1.0 animated:NO];
    self.imageView.frame = self.fitFrame;
    [self.scrollView setZoomScale:1.0 animated:NO];
    self.progressView.center = CGPointMake(CGRectGetMidX(self.contentView.bounds),
                                           CGRectGetMidY(self.contentView.bounds));
    // 查看原图按钮
    if (!self.rawImageButton.hidden) {
        [self.contentView addSubview:self.rawImageButton];
        [self.rawImageButton sizeToFit];
        self.rawImageButton.center = CGPointMake(CGRectGetMidX(self.contentView.bounds),
                                                 self.contentView.bounds.size.height - 20 - self.rawImageButton.bounds.size.height);
        self.rawImageButton.hidden = NO;
    }
}

/// 加载图片
- (void)loadImageWithPlaceholder:(UIImage *)image andURL:(NSURL *)url {
    self.progressView.hidden = NO;
    __weak __typeof(self)weakSelf = self;
    [self.imageView sd_setImageWithURL:url placeholderImage:image options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (expectedSize > 0) {
            weakSelf.progressView.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
        }
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        weakSelf.progressView.hidden = YES;
        [weakSelf doLayout];
    }];
}

/// 根据url从缓存取图像
- (UIImage *)imageForURL:(NSURL *)url {
    if (url == nil) {
        return nil;
    }
    SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    return [imageManager.imageCache imageFromCacheForKey:[imageManager cacheKeyForURL:url]];
}

- (BOOL)isZoomScale {
    if (self.scrollView.zoomScale == 1.0) {
        return NO;
    }
    return YES;
}
@end
