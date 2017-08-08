//
//  ZCPhotoBrowserCell.h
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZCPhotoBrowserCell;

@protocol ZCPhotoBrowserCellDelegate <NSObject>

/// 单击时回调
- (void)photoBrowserCellDidSingleTap:(ZCPhotoBrowserCell *)cell;

/// 拖动时回调。scale:缩放比率
- (void)photoBrowserCell:(ZCPhotoBrowserCell *)cell didPanScale:(CGFloat)scale;

/// 长按时回调
- (void)photoBrowserCell:(ZCPhotoBrowserCell *)cell didLongPressWithImage:(UIImage *)image;

@end

@interface ZCPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, weak) id<ZCPhotoBrowserCellDelegate> photoBrowserCellDelegate;
/// 显示图片
@property (nonatomic, strong) UIImageView *imageView;
/// 内嵌容器。本类不能继承UIScrollView。
/// 因为实测UIScrollView遵循了UIGestureRecognizerDelegate协议，而本类也需要遵循此协议，
/// 若继承UIScrollView则会覆盖UIScrollView的协议实现，故只内嵌而不继承。
@property (nonatomic, strong) UIScrollView *scrollView;
/// 原图url
@property (nonatomic, strong) NSURL *rawUrl;
/// 捏合手势放大图片时的最大允许比例，默认是2.0
@property (nonatomic, assign) CGFloat imageMaximumZoomScale;
/// 双击放大图片时的目标比例，默认是2.0
@property (nonatomic, assign) CGFloat imageZoomScaleForDoubleTap;

- (void)setImageWithPlaceholder:(UIImage *)image
                    highQuality:(NSURL *)highQualityUrl
                            raw:(NSURL *)rawUrl;
@end
