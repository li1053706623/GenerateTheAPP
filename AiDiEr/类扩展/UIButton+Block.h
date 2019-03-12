//
//  UIButton+Block.h
//  AiDiEr
//
//  Created by Apple on 2019/2/27.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^tapActionBlock)(UIButton *button);
typedef NS_ENUM(NSUInteger, MKButtonEdgeInsetsStyle) {
    MKButtonEdgeInsetsStyleTop, // image在上，label在下
    MKButtonEdgeInsetsStyleLeft, // image在左，label在右
    MKButtonEdgeInsetsStyleBottom, // image在下，label在上
    MKButtonEdgeInsetsStyleRight // image在右，label在左
};

@interface UIButton (Block)

@property(nonatomic,copy)tapActionBlock actionBlock;

/**
 通过block对button的点击事件封装
 
 @param frame       frame
 @param title       标题
 @param bgImageName 背景图片
 @param actionBlock 点击事件回调block
 
 @return button
 */

+(UIButton *)createBtnFrame:(CGRect)frame title:(NSString *)title bgImageName:(NSString *)bgImageName action:(tapActionBlock)actionBlock;

-(void)addAcionBlock:(tapActionBlock)action;
/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style imageTitleSpace:(CGFloat)space;


@end



NS_ASSUME_NONNULL_END
