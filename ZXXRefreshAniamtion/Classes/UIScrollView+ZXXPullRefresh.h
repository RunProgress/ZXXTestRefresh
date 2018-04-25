//
//  UIScrollView+ZXXPullRefresh.h
//  ZXAnimationRefresh
//
//  Created by zhang on 2017/4/10.
//  Copyright © 2017年 zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXFreshAnimationHeader;
@interface UIScrollView (ZXXPullRefresh)

@property (nonatomic, strong, readonly) XXFreshAnimationHeader *header;

- (void)addRefreshHeaderWithHandler:(void (^)())handler;

@end
