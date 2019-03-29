//
//  AppDelegate.h
//  AiDiEr
//
//  Created by Apple on 2019/3/11.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WXApi.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate,TencentSessionDelegate,QQApiInterfaceDelegate>

@property (strong, nonatomic) UIWindow *window;
/*
 当前的网络状态
 */
@property(nonatomic,assign)int netWorkStatesCode;

@end

