//
//  ZCPhotoBrowserProgressView.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/4.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ZCPhotoBrowserProgressView.h"

@interface ZCPhotoBrowserProgressView()
/// 外边界
@property (nonatomic, strong) CAShapeLayer *circleLayer;
/// 扇形区
@property (nonatomic, strong) CAShapeLayer *fanshapedLayer;

@end

@implementation ZCPhotoBrowserProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 50, 50);
        }
        [self setupUI];
        self.progress = 0;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.fanshapedLayer.path = [self makeProgressPath:progress].CGPath;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    CGColorRef strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
    
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.strokeColor = strokeColor;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.path = [self makeCirclePath].CGPath;
    [self.layer addSublayer:self.circleLayer];
    
    self.fanshapedLayer = [CAShapeLayer layer];
    self.fanshapedLayer.fillColor = strokeColor;
    [self.layer addSublayer:self.fanshapedLayer];
}

- (UIBezierPath *)makeCirclePath {
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:25 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    path.lineWidth = 2;
    return path;
}

- (UIBezierPath *)makeProgressPath:(CGFloat)progress {
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = CGRectGetMidY(self.bounds) - 2.5;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:center];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.bounds), center.y - radius)];
    [path addArcWithCenter:center radius:radius startAngle:-M_PI / 2 endAngle:-M_PI / 2 + M_PI * 2 * progress clockwise:YES];
    [path closePath];
    path.lineWidth = 1;
    return path;
}
@end
