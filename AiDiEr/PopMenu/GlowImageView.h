//
//  GlowImageView.h
//  AiDiEr
//
//  Created by Apple on 2019/3/4.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlowImageView : UIButton


/**
 *  设置阴影的偏移值（+，+）表示向左下偏移 默认为 （0,0）
 */
@property (nonatomic, assign) CGSize glowOffset;

/**
 *  设置阴影的模糊度 默认为： 5
 */
@property (nonatomic, assign) CGFloat glowAmount;

/**
 *  设置阴影的颜色 默认为 grayColor 灰色
 */
@property (nonatomic, strong) UIColor *glowColor;

@end

NS_ASSUME_NONNULL_END
