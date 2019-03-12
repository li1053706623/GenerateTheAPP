//
//  UIView+YSAddClickBlock.h
//  AiDiEr
//
//  Created by Apple on 2019/2/27.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UIViewBorderLineType) {
    UIViewBorderLineTypeTop,
    UIViewBorderLineTypeRight,
    UIViewBorderLineTypeBottom,
    UIViewBorderLineTypeLeft,
};

@interface UIView (YSAddClickBlock)

@property (nonatomic, assign) CGFloat ZKK_x;
@property (nonatomic, assign) CGFloat ZKK_y;
@property (nonatomic, assign) CGFloat ZKK_centerX;
@property (nonatomic, assign) CGFloat ZKK_centerY;
@property (nonatomic, assign) CGFloat ZKK_width;
@property (nonatomic, assign) CGFloat ZKK_height;
@property (nonatomic, assign) CGSize  ZKK_size;
@property (nonatomic, assign) CGPoint ZKK_origin;


/**点击手势*/
- (void)addClickEventBlock:(void (^)(id obj))aBlock;
/**滑动手势*/
-(void)addSlideWithSwipeGestureRecognizerDirection:(UISwipeGestureRecognizerDirection)direction EventBlock:(void (^)(id obj))aBlock;


+(void)setViewBorder:(UIView *)view color:(UIColor *)color border:(float)border type:(UIViewBorderLineType)borderLineType;


@end

NS_ASSUME_NONNULL_END
