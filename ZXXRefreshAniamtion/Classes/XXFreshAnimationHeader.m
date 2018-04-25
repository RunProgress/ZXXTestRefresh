//
//  XXFreshHeader.m
//  ZXAnimationRefresh
//
//  Created by zhang on 2017/4/7.
//  Copyright © 2017年 zhang. All rights reserved.
//

#import "XXFreshAnimationHeader.h"

#define topPointColor    [UIColor colorWithRed:90 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1.0].CGColor
#define leftPointColor   [UIColor colorWithRed:250 / 255.0 green:85 / 255.0 blue:78 / 255.0 alpha:1.0].CGColor
#define bottomPointColor [UIColor colorWithRed:92 / 255.0 green:201 / 255.0 blue:105 / 255.0 alpha:1.0].CGColor
#define rightPointColor  [UIColor colorWithRed:253 / 255.0 green:175 / 255.0 blue:75 / 255.0 alpha:1.0].CGColor

const CGFloat XXRefreshSize = 35.0f;
const CGFloat XXRefreshPointRadius = 5.0f;
const CGFloat XXRefreshMaxPullLength = 55.0f;
const CGFloat XXRefreshTransitionRang = 5.0f;

@interface XXFreshAnimationHeader ()

@property (nonatomic, weak)UIScrollView *observeScrollView;

@property (nonatomic, strong)CAShapeLayer *topPointLayer;
@property (nonatomic, strong)CAShapeLayer *leftPointLayer;
@property (nonatomic, strong)CAShapeLayer *bottomPointLayer;
@property (nonatomic, strong)CAShapeLayer *rightPointLayer;
@property (nonatomic, strong)CAShapeLayer *pointLineLayer;

@property (nonatomic, assign)CGPoint topPoint;
@property (nonatomic, assign)CGPoint leftPoint;
@property (nonatomic, assign)CGPoint bottomPoint;
@property (nonatomic, assign)CGPoint rightPoint;

@property (nonatomic, assign)CGFloat pullDistance; // 下拉刷新的幅度
@property (nonatomic, assign)BOOL isRefreshing ;
@property (nonatomic, assign)BOOL isStartRefresh;

@end

@implementation XXFreshAnimationHeader

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, XXRefreshSize, XXRefreshSize)];
    if (self) {
        [self setupPointLayerAndLiner];
    }
    return self;
}

- (void)setupPointLayerAndLiner
{
    [self addFourPoint];
    [self addLineBetweenPoint];
    _pointLineLayer.strokeStart = 0;
    _pointLineLayer.strokeEnd = 0;
}

// --- 初始化界面 生成shapelayer ---
- (void)addFourPoint
{
    CGFloat centerPosition = XXRefreshSize / 2.0;
    
    self.topPoint = CGPointMake(centerPosition, XXRefreshPointRadius);
    self.topPointLayer = [self createPointShapeLayerByCenterPoint:_topPoint length:XXRefreshPointRadius * 2 color:topPointColor];
    [self.layer addSublayer:_topPointLayer];
    
    self.leftPoint = CGPointMake(XXRefreshPointRadius, centerPosition);
    self.leftPointLayer = [self createPointShapeLayerByCenterPoint:_leftPoint length:XXRefreshPointRadius * 2 color:leftPointColor];
    [self.layer addSublayer:_leftPointLayer];
    
    self.bottomPoint = CGPointMake(centerPosition, XXRefreshSize - XXRefreshPointRadius);
    self.bottomPointLayer = [self createPointShapeLayerByCenterPoint:_bottomPoint length:XXRefreshPointRadius * 2 color:bottomPointColor];
    [self.layer addSublayer:_bottomPointLayer];
    
    self.rightPoint = CGPointMake(XXRefreshSize - XXRefreshPointRadius, centerPosition);
    self.rightPointLayer = [self createPointShapeLayerByCenterPoint:_rightPoint length:XXRefreshPointRadius * 2 color:rightPointColor];
    [self.layer addSublayer:_rightPointLayer];
    
}

- (void)addLineBetweenPoint
{
    _pointLineLayer = [CAShapeLayer layer];
    _pointLineLayer.lineJoin = kCALineJoinRound;
    _pointLineLayer.lineCap = kCALineCapRound;
    _pointLineLayer.frame = self.bounds;
    _pointLineLayer.lineWidth = XXRefreshPointRadius * 2;
    _pointLineLayer.fillColor = topPointColor;
    _pointLineLayer.strokeColor = topPointColor;
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:_topPoint];
    [linePath addLineToPoint:_leftPoint];
    [linePath moveToPoint:_leftPoint];
    [linePath addLineToPoint:_bottomPoint];
    [linePath moveToPoint:_bottomPoint];
    [linePath addLineToPoint:_rightPoint];
    [linePath moveToPoint:_rightPoint];
    [linePath addLineToPoint:_topPoint];
    _pointLineLayer.path = linePath.CGPath;
    
    [self.layer addSublayer:_pointLineLayer];
}

- (CAShapeLayer *)createPointShapeLayerByCenterPoint:(CGPoint)center
                                               length:(CGFloat)length
                                                color:(CGColorRef)color
{
    CAShapeLayer *shapLayer = [CAShapeLayer layer];
    shapLayer.frame = CGRectMake(center.x - length/2, center.y - length/2, length, length);
    shapLayer.fillColor = color;
    shapLayer.strokeColor = color;
    shapLayer.lineCap = kCALineCapRound;
    shapLayer.lineJoin = kCALineJoinRound;
    shapLayer.path = [self pointShapeLayerPathWithRadius:length/2];
    return shapLayer;
}

- (CGPathRef)pointShapeLayerPathWithRadius:(CGFloat)radius
{
    UIBezierPath *circleBezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:(2*M_PI) clockwise:YES];
    return  circleBezier.CGPath;
}

// 当视图添加到 scrollView 上的时候 添加对 srollView 的监听
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        if ([newSuperview isKindOfClass:[UIScrollView class]]) {
             self.observeScrollView = (UIScrollView *)newSuperview;
            [self.observeScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self.observeScrollView addObserver:self forKeyPath:@"isDragging" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    else {
        @try {
            [self.observeScrollView removeObserver:self forKeyPath:@"contentOffset"];
        } @catch (NSException *exception) {
            
        } @finally {
            NSLog(@"移除观察者失败");
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([object isEqual:self.observeScrollView] ){
        
        if ([keyPath isEqualToString:@"contentOffset"]) {
            self.pullDistance = - self.observeScrollView.contentOffset.y;
            [self refreshAnimation];
        }

    }
}

- (void)startRefresh
{
    if (_isRefreshing) {
        return;
    }
    _isRefreshing = YES;
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets inset = self.observeScrollView.contentInset;
        inset.top = XXRefreshMaxPullLength;
        self.observeScrollView.contentInset = inset;
    } completion:^(BOOL finished) {
        if (self.refreshHandler) {
            self.refreshHandler();
        }
    }];
    [self startAni];
}

- (void)endRefreshing
{
    _isRefreshing = NO;
    NSLog(@"下拉刷新 完毕");
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets inset = self.observeScrollView.contentInset;
        inset.top = 0;
        self.observeScrollView.contentInset = inset;
    } completion:^(BOOL finished) {
        [self.topPointLayer removeAllAnimations];
        [self.leftPointLayer removeAllAnimations];
        [self.bottomPointLayer removeAllAnimations];
        [self.rightPointLayer removeAllAnimations];
        [self.layer removeAllAnimations];
    }];
}

- (void)refreshAnimation
{
    NSLog(@"--- %lf", _pullDistance);
    CGRect frame = self.frame;
    if (!_isRefreshing) {
        if (_pullDistance < XXRefreshSize) {
            frame.origin.y = - _pullDistance;
        }
        else if (_pullDistance >= XXRefreshSize && _pullDistance < XXRefreshMaxPullLength) {
            CGFloat originY = - (XXRefreshSize + (_pullDistance - XXRefreshSize)/2.0);
            frame.origin.y = originY;
            self.isStartRefresh = NO;
        }
        else {
            CGFloat originY = - (XXRefreshSize + (XXRefreshMaxPullLength - XXRefreshSize)/2.0);
            frame.origin.y = originY;
        }
        [self startLineLayerWithPullDistance:_pullDistance];

    }
    if (_pullDistance >= XXRefreshMaxPullLength && !self.isRefreshing && !self.observeScrollView.dragging) {
        [self startRefresh];
    }
    self.frame = frame;
}

- (void)startLineLayerWithPullDistance:(CGFloat)pullDistance
{
    CGFloat startProgress = 0.0f;
    CGFloat endProgress = 0.0f;
    
    if (pullDistance < 0) {
        self.topPointLayer.opacity = 0;
        [self changePointStatmentByNowIndex:0];
    }
    else if (pullDistance >= 0 && pullDistance < (XXRefreshMaxPullLength - 40)){
        self.topPointLayer.opacity = pullDistance / 20;
        [self changePointStatmentByNowIndex:0];
    }
    else if (pullDistance >= (XXRefreshMaxPullLength - 40) && pullDistance < XXRefreshMaxPullLength){
        self.topPointLayer.opacity = 1.0;
        
        NSInteger stage = (pullDistance - (XXRefreshMaxPullLength - 40)) / 10;
        CGFloat subProgress = (pullDistance - (XXRefreshMaxPullLength - 40)) - (stage * 10);
        if (subProgress >= 0 && subProgress <= 5) {
            [self changePointStatmentByNowIndex:stage * 2];
            startProgress = stage / 4.0;
            endProgress = stage / 4.0 + subProgress / 40.0 * 2;
        }
        
        if (subProgress > 5 && subProgress < 10) {
            [self changePointStatmentByNowIndex:stage * 2 + 1];
            startProgress = stage / 4.0 + (subProgress - 5) / 40.0 * 2;
            if (startProgress < (stage + 1) / 4.0  - 0.1) {
                startProgress = (stage + 1) / 4.0  - 0.1;
            }
            endProgress = (stage + 1) / 4.0;
        }
    }
    else {
        self.topPointLayer.opacity = 1.0;
        [self changePointStatmentByNowIndex:NSIntegerMax];
        startProgress = 1.0f;
        endProgress = 1.0f;
    }
    self.pointLineLayer.strokeStart = startProgress;
    self.pointLineLayer.strokeEnd = endProgress;
    
}

- (void)changePointStatmentByNowIndex:(NSInteger)index
{
    self.leftPointLayer.hidden = index > 1 ? NO : YES;
    self.bottomPointLayer.hidden = index > 3 ? NO : YES;
    self.rightPointLayer.hidden = index > 5 ? NO : YES;
    self.pointLineLayer.strokeColor = index > 5 ? rightPointColor : index > 3 ? bottomPointColor : index > 1 ? leftPointColor : topPointColor;
}

- (void)startAni {

    [self addTranslationAniToLayer:self.topPointLayer xValue:0 yValue:XXRefreshTransitionRang];
    [self addTranslationAniToLayer:self.leftPointLayer xValue:XXRefreshTransitionRang yValue:0];
    [self addTranslationAniToLayer:self.bottomPointLayer xValue:0 yValue:-XXRefreshTransitionRang];
    [self addTranslationAniToLayer:self.rightPointLayer xValue:-XXRefreshTransitionRang yValue:0];
    [self addRotationAniToLayer:self.layer];
}

- (void)addTranslationAniToLayer:(CALayer *)layer xValue:(CGFloat)x yValue:(CGFloat)y {
    CAKeyframeAnimation * translationKeyframeAni = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    translationKeyframeAni.duration = 1.0;
    translationKeyframeAni.repeatCount = HUGE;
    translationKeyframeAni.removedOnCompletion = NO;
    translationKeyframeAni.fillMode = kCAFillModeForwards;
    translationKeyframeAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    NSValue * fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 0, 0.f)];
    NSValue * toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(x, y, 0.f)];
    translationKeyframeAni.values = @[fromValue, toValue, fromValue, toValue, fromValue];
    [layer addAnimation:translationKeyframeAni forKey:@"translationKeyframeAni"];
}

- (void)addRotationAniToLayer:(CALayer *)layer {
    CABasicAnimation * rotationAni = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAni.fromValue = @(0);
    rotationAni.toValue = @(M_PI * 2);
    rotationAni.duration = 1.0;
    rotationAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAni.repeatCount = HUGE;
    rotationAni.fillMode = kCAFillModeForwards;
    rotationAni.removedOnCompletion = NO;
    [layer addAnimation:rotationAni forKey:@"rotationAni"];
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
