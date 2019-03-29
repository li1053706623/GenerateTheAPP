//
//  ZLStartPageView.h
//  AiDiEr
//
//  Created by Apple on 2019/3/28.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLStartPageView : UIView

@property(nonatomic,copy)void(^showGuidePage)(void);

- (instancetype)initWithFrame:(CGRect)frame WithLaunchImageString:(NSString *)launchImageString;

/**
 *  显示引导页面方法
 */
-(void)showWithStartAnimationDuration:(CGFloat)startAnimationDuration;

@end

NS_ASSUME_NONNULL_END
