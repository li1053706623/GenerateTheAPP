//
//  MainBottomView.h
//  AiDiEr
//
//  Created by Apple on 2019/2/12.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainBottomView : UIView

/**********定义block************/
@property (nonatomic,copy) void (^myBlock)(SPButton *button);

@end

NS_ASSUME_NONNULL_END
