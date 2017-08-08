//
//  ZCScaleAnimatorCoordinator.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ZCScaleAnimatorCoordinator.h"

@implementation ZCScaleAnimatorCoordinator

- (UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}

- (void)updateCurrentHiddenView:(UIView *)view {
    self.currentHiddenView.hidden = NO;
    self.currentHiddenView = view;
    view.hidden = YES;
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    if (self.containerView == nil) {
        return;
    }
    [self.containerView addSubview:self.maskView];
    self.maskView.frame = self.containerView.bounds;
    self.maskView.alpha = 0;
    self.currentHiddenView.hidden = YES;
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.maskView.alpha = 1;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    self.currentHiddenView.hidden = YES;
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.maskView.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.currentHiddenView.hidden = NO;
    }];
}

@end
