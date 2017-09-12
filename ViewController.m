//
//  ViewController.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ViewController.h"
#import "PhotoCollectionViewCell.h"
#import "ZCPhotoBrowser.h"
#import "ZCPhotoBrowserDefaultPageControlDelegate.h"
#import "ZCPhotoBrowserNumberPageControlDelegate.h"
#import <UIImageView+WebCache.h>
#import "testViewController0.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerPreviewingDelegate, ZCPhotoBrowserDelegate>
@property (nonatomic, strong) NSArray *thumbnailImageUrls;
@property (nonatomic, strong) NSArray *highQualityImageUrls;
@property (nonatomic, weak) PhotoCollectionViewCell *selectedCell;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZCPhotoBrowserNumberPageControlDelegate *pageControlDelegate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.thumbnailImageUrls = @[@"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                               @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg",
                               @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                               @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                               @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7qjop4j20i00hw4c6.jpg",
                               @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                               @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                               @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                               @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7usmc8j20i543zngx.jpg"];
    
    self.highQualityImageUrls = @[@"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                                  @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg",
                                  @"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                                  @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                                  @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7qjop4j20i00hw4c6.jpg",
                                  @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                                  @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                                  @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                                  @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7usmc8j20i543zngx.jpg",];
    
    CGFloat colCount = 3;
    CGFloat rowCount = 3;
    
    CGFloat xMargin = 60.0;
    CGFloat interitemSpacing = 10.0;
    CGFloat width = self.view.bounds.size.width - xMargin * 2;
    CGFloat itemSize = (width - 2 * interitemSpacing) / (CGFloat)colCount;
    
    CGFloat lineSpacing = 10.0;
    CGFloat height = itemSize * rowCount + lineSpacing * 2;
    CGFloat y = 60.0;
    
    CGRect frame = CGRectMake(xMargin, y, width, height);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = interitemSpacing;
    layout.itemSize = CGSizeMake(itemSize, itemSize);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [cv registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([PhotoCollectionViewCell class])];
    
    [self.view addSubview:cv];
    
    cv.dataSource = self;
    cv.delegate = self;
    cv.backgroundColor = [UIColor whiteColor];
    self.collectionView = cv;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnailImageUrls.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCollectionViewCell class]) forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:self.thumbnailImageUrls[indexPath.item]];
    
    //注册3D Touch
    /**
     从iOS9开始，我们可以通过这个类来判断运行程序对应的设备是否支持3D Touch功能。
     
     UIForceTouchCapabilityUnknown = 0,     //未知
     UIForceTouchCapabilityUnavailable = 1, //不可用
     UIForceTouchCapabilityAvailable = 2    //可用
     */
    if ([self respondsToSelector:@selector(traitCollection)]) {
        
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (!cell) {
        return;
    }
    self.selectedCell = cell;
    
    // 调起图片浏览器
    ZCPhotoBrowser *photoBrowser = [[ZCPhotoBrowser alloc] initWithPresentingViewController:self andDelegate:self];
    self.pageControlDelegate = [[ZCPhotoBrowserNumberPageControlDelegate alloc] initWithNumberOfPages:self.thumbnailImageUrls.count];
    photoBrowser.photoBrowserPageControlDelegate = self.pageControlDelegate;
    [photoBrowser showAtIndex:indexPath.item];
}

#pragma mark - ZCPhotoBrowserDelegate
/// 实现本方法以返回图片数量
- (NSInteger)numberOfPhotos:(ZCPhotoBrowser *)photoBrowser {
    return self.thumbnailImageUrls.count;
}

/// 实现本方法以返回默认图片，缩略图或占位图
- (UIImage *)photoBrowser:(ZCPhotoBrowser *)photoBrowser thumbnailImageForIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.imageView.image;
}

/// 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
/// 比如你可返回ImageView，或整个Cell
- (UIView *)photoBrowser:(ZCPhotoBrowser *)photoBrowser thumbnailViewForIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

/// 实现本方法已返回默认图。可选
- (UIImage *)photoBrowser:(ZCPhotoBrowser *)photoBrowser placeholderImageForIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.imageView.image;
}

/// 实现本方法以返回高质量图片的url。可选
- (NSURL *)photoBrowser:(ZCPhotoBrowser *)photoBrowser highQualityUrlForIndex:(NSInteger)index {
    NSString *url = self.highQualityImageUrls[index];
    return [NSURL URLWithString:url];
}

#pragma mark - UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)previewingContext.sourceView];
    
    ZCPhotoBrowser *photoBrowser = [[ZCPhotoBrowser alloc] initWithPresentingViewController:self andDelegate:self];
    self.pageControlDelegate = [[ZCPhotoBrowserNumberPageControlDelegate alloc] initWithNumberOfPages:self.thumbnailImageUrls.count];
    photoBrowser.photoBrowserPageControlDelegate = self.pageControlDelegate;
    photoBrowser.currentIndex = indexPath.item;
    
    //指定当前上下文视图Rect
    //CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
    previewingContext.sourceRect = previewingContext.sourceView.frame;
    
    return photoBrowser;
}

//- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
//    
//    [self showViewController:viewControllerToCommit sender:self];
//}

@end
