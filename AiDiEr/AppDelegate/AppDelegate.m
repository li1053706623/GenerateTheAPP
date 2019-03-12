//
//  AppDelegate.m
//  AiDiEr
//
//  Created by Apple on 2019/3/11.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DHGuidePageHUD.h"


#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIView *lunchView;

@end

@implementation AppDelegate
@synthesize lunchView;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor =[UIColor whiteColor];
    
    // 设置窗口的根控制器
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] init]];
    [self.window makeKeyAndVisible];
    
    [self checkworking];
    
     [defaults setObject:[ConfigData getConfigDataFromDictionary] forKey:@"dataDict"];
    
    lunchView  = [[UIView alloc]init];
    lunchView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.window addSubview:lunchView];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"startPicture"]]]];
    [lunchView addSubview:imageV];
    
    if (![defaults boolForKey:first]) {
        [defaults setBool:YES forKey:first];
        
        DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc]dh_initWithFrame:self.window.frame imageNameArray:[[defaults objectForKey:@"dataDict"]objectForKey:@"leadPicture"] buttonIsHidden:NO WithLeadType:[[dataDict objectForKey:@"leadType"]integerValue]];
        [self.window addSubview:guidePage];
    }
    
    [self.window bringSubviewToFront:lunchView];
    
    [NSTimer scheduledTimerWithTimeInterval:[[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"starttime"]]integerValue] target:self selector:@selector(removeLun) userInfo:nil repeats:NO];
    
     [self replyPushNotificationAuthorization:application];
    
    return YES;
}

-(void)removeLun{
    [lunchView removeFromSuperview];
}
#pragma mark---监听网络状态
-(void)checkworking{
    
    [SZKNetWorkUtils netWorkState:^(NSInteger netState) {
        if (netState == 0) {
            self.netWorkStatesCode = 0;
             NSDictionary *dic = @{@"status":@"0"};
             self.netWorkStatesCode = [[dic objectForKey:@"status"]intValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotReachable" object:nil userInfo:dic];
        }else{
             NSDictionary *dic = @{@"status":@"1"};
            self.netWorkStatesCode = [[dic objectForKey:@"status"]intValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noNotReachable" object:nil userInfo:dic];
        }
    }];
    
    //注册通知，异步加载，判断网络连接情况
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
   
    
}
/**
 *此函数通过判断联网方式，通知给用户
 */
//-(void)reachabilityChanged:(NSNotification *)notification{
//    Reachability *curReachability = [notification object];
//    NSParameterAssert([curReachability isKindOfClass:[Reachability class]]);
//    NetworkStatus status = [curReachability currentReachabilityStatus];
//    if (status == NotReachable) {
//        self.netWorkStatesCode = 0;
//        NSDictionary *dic = @{@"status":@"0"};
//        self.netWorkStatesCode = [[dic objectForKey:@"status"]intValue];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotReachable" object:nil userInfo:dic];
//    }else{
//        NSDictionary *dic = @{@"status":@"1"};
//        self.netWorkStatesCode = [[dic objectForKey:@"status"]intValue];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"noNotReachable" object:nil userInfo:dic];
//    }
//
//}

#pragma mark - Exception Delegate

- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(NSDictionary*)info{
    NSLog(@"----exceptionMessage:%@-----------info:%@",exceptionMessage,info);
}

#pragma mark - 申请通知权限
// 申请通知权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application{
    
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                NSLog(@"注册成功");
            }else{
                //用户点击不允许
                NSLog(@"注册失败");
            }
            // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
            //            之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                NSLog(@"========%@",settings);
            }];
        }];
    } else {
        // Fallback on earlier versions
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
        
    }
  
    //注册远端消息通知获取device token
    [application registerForRemoteNotifications];
}

#pragma  mark - 获取device Token
//获取DeviceToken成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //解析NSData获取字符串
    //我看网上这部分直接使用下面方法转换为string，你会得到一个nil（别怪我不告诉你哦）
    //错误写法
    //NSString *string = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
    //正确写法
    NSString *deviceString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceString = [deviceString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken===========%@",deviceString);
}
//获取DeviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"[DeviceToken Error]:%@\n",error.description);
}
#pragma mark - iOS10 收到通知（本地和远端） UNUserNotificationCenterDelegate
//App处于前台接收通知时
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    
    
    //收到推送的请求
    UNNotificationRequest *request = notification.request;
    
    //收到推送的内容
    UNNotificationContent *content = request.content;
    
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    
    //收到推送消息body
    NSString *body = content.body;
    
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    
    // 推送消息的标题
    NSString *title = content.title;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //此处省略一万行需求代码。。。。。。
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
        
    }else {
        // 判断为本地通知
        //此处省略一万行需求代码。。。。。。
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
    
}

//App通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    
    
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;
    
    //收到推送的内容
    UNNotificationContent *content = request.content;
    
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    
    //收到推送消息body
    NSString *body = content.body;
    
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    
    // 推送消息的标题
    NSString *title = content.title;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
        //此处省略一万行需求代码。。。。。。
        
    }else {
        // 判断为本地通知
        //此处省略一万行需求代码。。。。。。
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    //2016-09-27 14:42:16.353978 UserNotificationsDemo[1765:800117] Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler(); // 系统要求执行这个方法
}

#pragma mark -iOS 10之前收到通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"iOS6及以下系统，收到通知:%@", userInfo);
    //此处省略一万行需求代码。。。。。。
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    //此处省略一万行需求代码。。。。。。
}




@end
