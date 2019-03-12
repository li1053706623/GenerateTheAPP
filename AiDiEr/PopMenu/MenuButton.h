//
//  MenuButton.h
//  AiDiEr
//
//  Created by Apple on 2019/3/4.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MenuItem;

typedef void(^DidSelctedItemCompletedBlock)(MenuItem *menuItem);

@interface MenuButton : UIView


/**
 *  点击操作
 */
@property (nonatomic, copy) DidSelctedItemCompletedBlock didSelctedItemCompleted;

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame menuItem:(MenuItem *)menuItem;

@end

NS_ASSUME_NONNULL_END
