//
//  JYJCommenItem.h
//  JYJSlideMenuController
//
//  Created by JYJ on 2017/6/16.
//  Copyright © 2017年 baobeikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JYJCommenItemOption)();

@interface JYJCommenItem : NSObject
/**
 *  图标
 */
@property (nonatomic, copy) NSString *icon;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  子标题
 */
@property (nonatomic, copy) NSString *subtitle;
/**
 *  点击那个cell需要做什么事情
 */
@property (nonatomic, copy) JYJCommenItemOption option;

/**
 *  点击这行cell需要做的事情
 */
@property (nonatomic, assign) NSInteger destClass;

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title subtitle:(NSString *)subtitle destVcClass:(NSInteger)destVcClass;
@end
