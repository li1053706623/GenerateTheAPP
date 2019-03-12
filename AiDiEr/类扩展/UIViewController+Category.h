//
//  UIViewController+Category.h
//  ChangeIcons
//
//  Created by Apple on 2019/2/11.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SPButton.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Category)

/**状态栏高度*/
-(float)mStatusbarHeight;
/**导航栏高度+状态栏高度*/
-(float)mNavigationbarHeight;
/**Tabbar高度*/
-(float)mTabbarHeight;
///**功能按钮功能的实现*/
-(void)GetFunctionWithfunctionSender:(SPButton *)sender WithfunctionId:(NSInteger)functionId;

-(void)getNavigationBarWithNavigationType:(NSInteger)navigationType;

-(BOOL)isUrl:(NSString *)url;

-(void)GetUPBottomView;

-(void)dialPhoneNumber;

-(void)aboutus;

-(void)folderSize;

-(void)exitApplication;

//提示框
-(void)showAlertViewContrllerWithMessage:(NSString *)message;

-(void)GoBackWithString:(NSString *)imageStr;

-(void)GetUPNavigationView;
@end

NS_ASSUME_NONNULL_END
