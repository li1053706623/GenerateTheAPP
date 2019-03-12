//
//  UIView+YSAddClickBlock.m
//  AiDiEr
//
//  Created by Apple on 2019/2/27.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "UIView+YSAddClickBlock.h"
#import <objc/runtime.h>

static const void *YSUIViewBlockKey = &YSUIViewBlockKey;



@interface UIView ()

@property void(^clickBlock)(id);

@end

@implementation UIView (YSAddClickBlock)

- (void)setClickBlock:(void (^)(id))clickBlock {
    objc_setAssociatedObject(self, YSUIViewBlockKey, clickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(id))clickBlock{
    return objc_getAssociatedObject(self, YSUIViewBlockKey);
}

- (void)addClickEventBlock:(void (^)(id obj))aBlock{
    self.clickBlock = aBlock;
    if (![self gestureRecognizers]) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blockAction)];
        [self addGestureRecognizer:tap];
    }
}
-(void)addSlideWithSwipeGestureRecognizerDirection:(UISwipeGestureRecognizerDirection)direction EventBlock:(void (^)(id obj))aBlock{
    self.clickBlock = aBlock;
    if (![self gestureRecognizers]) {
        self.userInteractionEnabled = YES;
        UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(blockAction)];
         swipeGR.direction = direction;
        [self addGestureRecognizer:swipeGR];
    }
}
- (void)blockAction {
    if (self.clickBlock) {
        self.clickBlock(self);
    }
}

+(void)setViewBorder:(UIView *)view color:(UIColor *)color border:(float)border type:(UIViewBorderLineType)borderLineType{
     CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = color.CGColor;
    switch (borderLineType) {
        case UIViewBorderLineTypeTop:
            {
                lineLayer.frame = CGRectMake(0, 0, view.frame.size.width, border);
                 break;
            }
           
        case UIViewBorderLineTypeRight:
        {
            lineLayer.frame = CGRectMake(view.frame.size.width, 0, border, view.frame.size.height);
             break;
        }
           
        case UIViewBorderLineTypeBottom:
        {
            lineLayer.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, border);
             break;
        }
          
        case UIViewBorderLineTypeLeft:
        {
            lineLayer.frame = CGRectMake(0, 0, border, view.frame.size.width);
             break;
        }
        default:
        {
             lineLayer.frame = CGRectMake(0, 0, view.frame.size.width-42, border);
        }
            break;
    }
    
    [view.layer addSublayer:lineLayer];
}

- (void)setZKK_x:(CGFloat)ZKK_x
{
    CGRect frame = self.frame;
    frame.origin.x = ZKK_x;
    self.frame = frame;
}

- (CGFloat)ZKK_x
{
    return self.frame.origin.x;
}

- (void)setZKK_centerX:(CGFloat)ZKK_centerX
{
    CGPoint center = self.center;
    center.x = ZKK_centerX;
    self.center = center;
}

- (CGFloat)ZKK_centerX
{
    return self.center.x;
}

-(void)setZKK_centerY:(CGFloat)ZKK_centerY
{
    CGPoint center = self.center;
    center.y = ZKK_centerY;
    self.center = center;
}

- (CGFloat)ZKK_centerY
{
    return self.center.y;
}

- (void)setZKK_y:(CGFloat)ZKK_y
{
    CGRect frame = self.frame;
    frame.origin.y = ZKK_y;
    self.frame = frame;
}

- (CGFloat)ZKK_y
{
    return self.frame.origin.y;
}

- (void)setZKK_size:(CGSize)ZKK_size
{
    CGRect frame = self.frame;
    frame.size = ZKK_size;
    self.frame = frame;
    
}

- (CGSize)ZKK_size
{
    return self.frame.size;
}

- (void)setZKK_height:(CGFloat)ZKK_height
{
    CGRect frame = self.frame;
    frame.size.height = ZKK_height;
    self.frame = frame;
}

- (CGFloat)ZKK_height
{
    return self.frame.size.height;
}

- (void)setZKK_width:(CGFloat)ZKK_width
{
    CGRect frame = self.frame;
    frame.size.width = ZKK_width;
    self.frame = frame;
    
}

-(CGFloat)ZKK_width
{
    return self.frame.size.width;
}

- (void)setZKK_origin:(CGPoint)ZKK_origin
{
    CGRect frame = self.frame;
    frame.origin = ZKK_origin;
    self.frame = frame;
}

- (CGPoint)ZKK_origin
{
    return self.frame.origin;
}


@end
