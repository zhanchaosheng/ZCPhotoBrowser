//
//  ZCScaleAnimator.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ZCScaleAnimator.h"

@implementation ZCScaleAnimator

- (instancetype)initWithStartView:(UIView *)start endView:(UIView *)end scaleView:(UIView *)scale {
    self = [super init];
    if (self) {
        _startView = start;
        _endView = end;
        _scaleView = scale;
    }
    return self;
}

- (instancetype)init {
    return [self initWithStartView:nil endView:nil scaleView:nil];
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // 判断是presentataion动画还是dismissal动画
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (fromVC == nil || toVC == nil) {
        return;
    }
    BOOL presentation = (toVC.presentingViewController == fromVC);
    
    // dismissal转场，需要把presentedView隐藏，只显示scaleView
    UIView *presentedView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    if (!presentation && presentedView) {
        presentedView.hidden = YES;
    }
    
    // 转场容器
    UIView  *containerView = transitionContext.containerView;
    
    if (self.startView == nil || self.scaleView == nil) {
        return;
    }
    
    CGRect startFrame = [self.startView convertRect:self.startView.bounds toView:containerView];
    
    // 暂不求endFrame
    CGRect endFrame = startFrame;
    CGFloat endAlpha = 0.0;
    
    if (self.endView) {
        // 当前正在显示视图的前一个页面关联视图已经存在，此时分两种情况
        // 1、该视图显示在屏幕内，作scale动画
        // 2、该视图不显示在屏幕内，作fade动画
        CGRect relativeFrame = [self.endView convertRect:self.endView.bounds toView:nil];
        CGRect keyWindowBounds = [UIScreen mainScreen].bounds;
        if (CGRectIntersectsRect(keyWindowBounds, relativeFrame)) {
            // 在屏幕内，求endFrame，让其缩放
            endAlpha = 1.0;
            endFrame = [self.endView convertRect:self.endView.bounds toView:containerView];
        }
    }
    
    self.scaleView.frame = startFrame;
    [containerView addSubview:self.scaleView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.scaleView.alpha = endAlpha;
        self.scaleView.frame = endFrame;
    } completion:^(BOOL finished) {
        // presentation转场，需要把目标视图添加到视图栈
        UIView *presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
        if (presentation && presentedView) {
            [containerView addSubview:presentedView];
        }
        [self.scaleView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
