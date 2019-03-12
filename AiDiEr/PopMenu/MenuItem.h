//
//  MenuItem.h
//  AiDiEr
//
//  Created by Apple on 2019/3/4.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface MenuItem : NSObject


/**
 *   标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  配图
 */
@property (nonatomic, strong) UIImage *iconImage;

/**
 *
 */
@property (nonatomic, strong) UIColor *glowColor;

/**
 *  按钮索引
 */
@property (nonatomic, assign) NSInteger index;

#pragma mark - 初始话 init

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor NS_AVAILABLE_IOS(2_0);

+ (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);

+ (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);
@end

NS_ASSUME_NONNULL_END
