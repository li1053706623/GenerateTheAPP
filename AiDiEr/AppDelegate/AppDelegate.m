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
#import "ZLStartPageView.h"
#import <Foundation/Foundation.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIView *lunchView;

@property(nonatomic,strong)TencentOAuth *oauth;
@end

@implementation AppDelegate
@synthesize lunchView;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor =[UIColor whiteColor];
    
    // 设置窗口的根控制器
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] init]];
    [self.window makeKeyAndVisible];
    
    [self checkworking];
    
    [self hsUpdateApp];
    
     [defaults setObject:[ConfigData getConfigDataFromDictionary] forKey:@"dataDict"];
    
//    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
//        [platformsRegister setupQQWithAppId:[dataDict objectForKey:@"qqId"] appkey:[dataDict objectForKey:@"qqAppkey"]];
//        [platformsRegister setupWeChatWithAppId:[dataDict objectForKey:@"wechatId"] appSecret:[dataDict objectForKey:@"wechatSecret"]];
//        [platformsRegister setupSMSOpenCountryList:NO];
//    }];
    
    [WXApi registerApp:[dataDict objectForKey:@"wechatId"]];
    _oauth = [[TencentOAuth alloc]initWithAppId:[dataDict objectForKey:@"qqId"] andDelegate:self];
    
     [self setupStartPageView];
    
//    lunchView  = [[UIView alloc]init];
//    lunchView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    [self.window addSubview:lunchView];
//    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    [imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"startPicture"]]]];
//    [lunchView addSubview:imageV];
//
//
//
//    [self.window bringSubviewToFront:lunchView];
//
//    [NSTimer scheduledTimerWithTimeInterval:[[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"starttime"]]integerValue] target:self selector:@selector(removeLun) userInfo:nil repeats:NO];
    
     [self replyPushNotificationAuthorization:application];
    [self resetApplicationIconBadgeNumber];
    
    return YES;
}

/**
 *  设置启动页
 */

- (void)setupStartPageView {
    
    ZLStartPageView *startPageView = [[ZLStartPageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) WithLaunchImageString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"startPicture"]]];

    [startPageView showWithStartAnimationDuration:[[dataDict objectForKey:@"starttime"]floatValue]];
    
    startPageView.showGuidePage = ^{
        if ([[dataDict objectForKey:@"leadSwitch"]integerValue] == 1) {
         
            if (![defaults boolForKey:first]) {
                [defaults setBool:YES forKey:first];
                
                DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc]dh_initWithFrame:self.window.frame imageNameArray:[dataDict objectForKey:@"leadPicture"] buttonIsHidden:NO WithLeadType:[[dataDict objectForKey:@"leadType"]integerValue]];
                [self.window addSubview:guidePage];
                
            }
        }
    };
}


/**
  *  天朝专用检测app更新
 **/
-(void)hsUpdateApp{
   // 获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    //从网络获取app版本号
//    NSError *error;
//     NSData *response = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id"]]] returningResponse:nil error:nil];
////    NSURLSession
//
//    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
//
//    NSArray *array = appInfoDic[@"results"];
//    NSDictionary *dic = array[0];
    
      NSString *appVersion = @"10.0";
//    [HttpManager postWithURLString:@"" parameters:@{} success:^(NSDictionary *responseObject) {
//
//        appVersion = @"10.0";
//
//    } failure:^(NSError *error) {
//
//    }];
   
    //当前版本号小于商店版本号,就更新
    if ([currentVersion floatValue] < [appVersion floatValue]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(V %@),是否更新",appVersion] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"暂不更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication].keyWindow.rootViewController exitApplication];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http:www.baidu.com"] options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
            }
            
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    
    
}

-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"wechatId"]]]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"tencent%@",[dataDict objectForKey:@"qqId"]]]){
        return [QQApiInterface handleOpenURL:url delegate:self];
        
    }else{
        return YES;
    }
}
//登录成功
-(void)tencentDidLogin{
    if (_oauth.accessToken &&0 != [_oauth.accessToken length]) {
        
    }else{
        
    }
}
//非网络错误导致登录失败
-(void)tencentDidNotLogin:(BOOL)cancelled{
    if (cancelled) {
        
    }else{
        
    }
}
//网络错误导致登录失败
-(void)tencentDidNotNetWork{
    
}
//处理来至QQ的请求
-(void)onReq:(QQBaseReq *)req{
//    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
//         NSString *strMsg = [NSString stringWithFormat:@"发送消息结果:%d", resp.errCode];
//         NSLog(@"strmsg %@",strMsg);
//    }
}
// 处理来至QQ的响应
- (void)onResp:(QQBaseResp *)resp{

}
// 处理QQ在线状态的回调
- (void)isOnlineResponse:(NSDictionary *)response{
    
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
    
//    [HttpManager postWithURLString:[NSString stringWithFormat:@""] parameters:@{@"token":deviceString} success:^(NSDictionary *responseObject) {
//
//    } failure:^(NSError *error) {
//
//    }];
    
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"z注册成功--deviceToken:%@",deviceString] preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//    }]];
//    
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
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
//        [UIApplication sharedApplication].applicationIconBadgeNumber = [badge integerValue];
        
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


//App处于后台接收通知时
-(void)applicationDidEnterBackground:(UIApplication *)application{
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    
     UIApplication *app= [UIApplication sharedApplication];
     __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if (bgTask != UIBackgroundTaskInvalid) {
                
                bgTask = UIBackgroundTaskInvalid;
                
            }
            
        });
        
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
            
        });
        
    });
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler

{
//    NSInteger badge = [[[userInfo objectForKey:@"aps"]objectForKey:@"badge"]integerValue];
//    NSLog(@"收到通知userInfo:%@-------badge:%ld", userInfo,(long)badge);
//    [UIApplication sharedApplication].applicationIconBadgeNumber = badge ;
    completionHandler(UIBackgroundFetchResultNewData);
   
    
}
//App通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    
    
//    //收到推送的请求
//    UNNotificationRequest *request = response.notification.request;
//
//    //收到推送的内容
//    UNNotificationContent *content = request.content;
//
//    //收到用户的基本信息
//    NSDictionary *userInfo = content.userInfo;
//
//    //收到推送消息的角标
//    NSNumber *badge = content.badge;
//
//    //收到推送消息body
//    NSString *body = content.body;
//
//    //推送消息的声音
//    UNNotificationSound *sound = content.sound;
//
//    // 推送消息的副标题
//    NSString *subtitle = content.subtitle;
//
//    // 推送消息的标题
//    NSString *title = content.title;
//
//    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
//        NSLog(@"iOS10 收到远程通知:%@",userInfo);
//        //此处省略一万行需求代码。。。。。。
//
//    }else {
//        // 判断为本地通知
//        //此处省略一万行需求代码。。。。。。
//        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
//    }
    //2016-09-27 14:42:16.353978 UserNotificationsDemo[1765:800117] Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler(); // 系统要求执行这个方法
}


#pragma mark -iOS 10之前收到通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"iOS9及以下系统，收到通知:%@", userInfo);
    //此处省略一万行需求代码。。。。。。
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
//    completionHandler(UIBackgroundFetchResultNewData);
//    //此处省略一万行需求代码。。。。。。
//}

- (void)resetApplicationIconBadgeNumber{
    //使用这个方法清除角标，如果置为0的话会把之前收到的通知内容都清空；置为-1的话，不但能保留以前的通知内容，还有角标消失动画，iOS10之前这样设置是没有作用的 ，iOS10之后才有效果 。
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
}


@end
