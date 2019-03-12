//
//  AppDelegate.h
//  AiDiEr
//
//  Created by Apple on 2019/3/11.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/*
 当前的网络状态
 */
@property(nonatomic,assign)int netWorkStatesCode;

@end

