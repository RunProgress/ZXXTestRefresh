//
//  XXFreshHeader.h
//  ZXAnimationRefresh
//
//  Created by zhang on 2017/4/7.
//  Copyright © 2017年 zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RefreshHandler)();

@interface XXFreshAnimationHeader : UIView

@property (nonatomic, copy)RefreshHandler refreshHandler;
- (void)endRefreshing;
@end
