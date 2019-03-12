//
//  MainNavigationBarView.h
//  AiDiEr
//
//  Created by Apple on 2019/3/7.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainNavigationBarView : UIView
/**********左按钮************/
@property (nonatomic,strong) SPButton *leftButton;
/**********右按钮************/
@property (nonatomic,strong) SPButton *rightButton;

@end

NS_ASSUME_NONNULL_END
