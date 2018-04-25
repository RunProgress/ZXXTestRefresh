//
//  UIScrollView+ZXXPullRefresh.m
//  ZXAnimationRefresh
//
//  Created by zhang on 2017/4/10.
//  Copyright © 2017年 zhang. All rights reserved.
//

#import "UIScrollView+ZXXPullRefresh.h"
#import "XXFreshAnimationHeader.h"
#import <objc/runtime.h>

@implementation UIScrollView (ZXXPullRefresh)

+ (void)load
{
    SEL originSelector = NSSelectorFromString(@"dealloc");
    SEL exchangeSelector = NSSelectorFromString(@"zxx_load");
    Method originMethod = class_getInstanceMethod([self class], originSelector);
    Method exchangeMethod = class_getInstanceMethod([self class], exchangeSelector);
    
    BOOL addResult = class_addMethod([self class], NSSelectorFromString(@"dealloc"), method_getImplementation(exchangeMethod), method_getTypeEncoding(exchangeMethod));
    if (addResult) {
        class_replaceMethod([self class], NSSelectorFromString(@"zxx_load"), method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }
    else{
        method_exchangeImplementations(originMethod, exchangeMethod);
    }
}

- (void)setHeader:(XXFreshAnimationHeader *)header
{
    objc_setAssociatedObject(self, @selector(header), header, OBJC_ASSOCIATION_RETAIN);
}

- (XXFreshAnimationHeader *)header
{
    return  objc_getAssociatedObject(self, @selector(header));
}

- (void)addRefreshHeaderWithHandler:(void (^)())handler {
    XXFreshAnimationHeader *header = [XXFreshAnimationHeader new];
    header.refreshHandler = handler;
    self.header = header;
    header.center = CGPointMake(self.center.x, header.center.y);
    [self insertSubview:header atIndex:0];
}

- (void)zxx_load{
    @try {
        [self removeObserver:self.header forKeyPath:@"contentOffset"];
        self.header = nil;
    } @catch (NSException *exception) {
        
    } @finally {
        [self zxx_load];
    }
}

@end
