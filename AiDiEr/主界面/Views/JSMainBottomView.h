//
//  JSMainBottomView.h
//  AiDiEr
//
//  Created by Apple on 2019/3/26.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSMainBottomView : UIView


@property(nonatomic,strong)NSDictionary *MainBottomdataDict;

/**********定义block************/
@property (nonatomic,copy) void (^myBlock)(SPButton *button);

-(void)loadDefaultSettingWithMenuFun:(NSArray *)menubarFun WithMenName:(NSArray *)menName WithMenuTitleColorNormal:(NSString *)menuTitleColorNormal WithMenuTitleColorSelect:(NSString *)menuTitleColorSelect WithMenuDefauinput:(NSArray *)menuDefauinput;

@end

NS_ASSUME_NONNULL_END
