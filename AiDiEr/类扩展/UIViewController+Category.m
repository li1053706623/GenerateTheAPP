//
//  UIViewController+Category.m
//  ChangeIcons
//
//  Created by Apple on 2019/2/11.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "UIViewController+Category.h"
#import <objc/runtime.h>
#import "MainNavigationBarView.h"

@implementation UIViewController (Category)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method presentM = class_getInstanceMethod(self.class, @selector(presentViewController:animated:completion:));
        Method dismissAlertViewController = class_getInstanceMethod(self.class, @selector(dismissAlertViewControllerPresentViewController:animated:completion:));
        //runtime方法交换
        //通过拦截弹框事件,实现方法转换,从而去掉弹框
        method_exchangeImplementations(presentM, dismissAlertViewController);
    });
}
- (void)dismissAlertViewControllerPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion {

    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        //        NSLog(@"title : %@",((UIAlertController *)viewControllerToPresent).title);
        //        NSLog(@"message : %@",((UIAlertController *)viewControllerToPresent).message);

        UIAlertController *alertController = (UIAlertController *)viewControllerToPresent;
        if (alertController.title == nil && alertController.message == nil) {
            return;
        }
    }

    [self dismissAlertViewControllerPresentViewController:viewControllerToPresent animated:animated completion:completion];
}

-(float)mStatusbarHeight{
    //状态栏高度
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

-(float)mNavigationbarHeight{
    //导航栏高度+状态栏高度
    return self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
}

-(float)mTabbarHeight{
    //Tabbar高度
    UITabBarController *tabBarVC = [[UITabBarController alloc] init];//(这儿取你当前tabBarVC的实例)
    return tabBarVC.tabBar.bounds.size.height;
}


-(void)GetFunctionWithfunctionSender:(SPButton *)sender WithfunctionId:(NSInteger)functionId{
    NSInteger functionTag;
    if (sender.tag == 0) {
        functionTag = functionId;
    }else{
        functionTag = sender.tag;
    }


    /**
     1：分享功能
     2：刷新
     3：前进
     4：后退
     5：打电话-联系客服
     6：浏览器打开网页
     7：打开网站连接
     8:关于我们
     9:清除缓存
     10:打开左边栏---左侧栏按钮不带这个功能
     11:扫一扫
     12:回到主页
     13关闭app    只有titlebar按钮以及主页底部菜单按钮可以打开这个功能
     */


    switch (functionTag) {
        case 1:
            [self loadshare];
            break;
        case 2:
            //            [self loadfresh];
            break;
        case 3:

            break;

        case 4:

            break;
        case 5:
            [self dialPhoneNumber];
            break;
        case 6:
        {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baidu.com"] options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
            }
            break;
        }
        case 7:
        {
            URLViewController *urlVC = [[URLViewController alloc]init];
            [self.navigationController pushViewController:urlVC animated:YES];
        }
            break;
        case 8:
            [self aboutus];
            break;
        case 9:
            [self folderSize];

            break;
        case 10:
        {
            JYJAnimateViewController *vc = [[JYJAnimateViewController alloc] init];

            vc.view.backgroundColor = [UIColor clearColor];
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
        }
            break;
        case 11:
        {
            DIYScanViewController *scanvc = [[DIYScanViewController alloc] init];
            [self.navigationController pushViewController:scanvc animated:YES];
        }
            break;
        case 12:

            break;

        case 13:
        {
            [self exitApplication];
        }

            break;
        default:
            break;
    }

    //    NSLog(@"----%ld",functionTag);
}

#pragma mark---分享
-(void)loadshare{
    
    
    
    if ([[dataDict objectForKey:@"QQradio"]integerValue] == 1 ||
        [[dataDict objectForKey:@"wechatRadio"]integerValue] == 1 ||
        [[dataDict objectForKey:@"messages"]integerValue] == 1) {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareContent"]]
                                         images:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareImage"]]
                                            url:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareURL"]]]
                                          title:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareTitle"]]
                                           type:SSDKContentTypeAuto];
        [ShareSDK showShareActionSheet:nil customItems:[NSArray arrayWithObjects:
                                                        @(SSDKPlatformSubTypeQQFriend),// QQ好友
                                                        @(SSDKPlatformSubTypeQZone),//QQ空间
                                                        @(SSDKPlatformSubTypeWechatSession), //微信好友
                                                        @(SSDKPlatformSubTypeWechatTimeline), //微信朋友圈
                                                        @(SSDKPlatformTypeSMS) // 短信
                                                        ,nil]
                           shareParams:shareParams sheetConfiguration:nil onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
            switch (state) {
                case SSDKResponseStateSuccess:
                {
                    [self showAlertViewContrllerWithMessage:@"分享成功"];
                }

                    break;
                case SSDKResponseStateFail:
                {
                    [self showAlertViewContrllerWithMessage:@"分享失败"];
                }
                    break;

                default:
                    break;
            }
        }];
    }else{
        [self showAlertViewContrllerWithMessage:@"您没有开启此功能"];
    }
   
    
    
}

//-(void)loadfresh{
//    self.webview.scrollView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
//        [self.webview reload];
//        [self.webview.scrollView.mj_header endRefreshing];
//    }];
//}
-(void)dialPhoneNumber{
    
    NSMutableString *str = [[NSMutableString alloc]initWithFormat:@"tel:%@",@"0371-55175089"];
    WKWebView *callwebview = [[WKWebView alloc]init];
    [callwebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callwebview];
}
-(void)aboutus{
    
    AboutUSViewController *aboutus = [[AboutUSViewController alloc]init];
    [self.navigationController pushViewController:aboutus animated:YES];
}
-(void)folderSize{
    CGFloat folderSize = 0.0;
    //获取路径
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)firstObject];
    //获取所有文件的数组
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    
    for(NSString *path in files) {
        NSString*filePath = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",path]];
        //累加
        folderSize += [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil].fileSize;
    }
    CGFloat sizeM = folderSize /1024.0/1024.0;
    [self removeCacheWithSize:sizeM];
}
-(void)removeCacheWithSize:(CGFloat)sizeM{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"确定要删除%.2fM的缓存吗",sizeM] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)objectAtIndex:0];
        //返回路径中的文件数组
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
        for (NSString *p in files) {
            NSError *error;
            NSString*path = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
            if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
                BOOL isRemove = [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
                if (isRemove) {
                    [YJProgressHUD showMessage:@"清除成功" inView:self.view];
                    [self folderSize];
                }else{
                    [YJProgressHUD showMessage:@"清除失败" inView:self.view];
                }
            }
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark--提示框
-(void)showAlertViewContrllerWithMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)getNavigationBarWithNavigationType:(NSInteger)navigationType{
    
}


-(BOOL)isUrl:(NSString *)url{
        if (url == nil) {
            return NO;
        }
        
        if (url.length>4 && [[url substringToIndex:4]isEqualToString:@"www."]) {
            url = [NSString stringWithFormat:@"http://%@",self];
        }else{
            url = url;
        }
        NSString *urlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
        NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",urlRegex];
        
        
        return [urlTest evaluateWithObject:url];
}

-(void)GetUPBottomView{
    if ([[dataDict objectForKey:@"menuBarRadio"]integerValue] !=0) {
        __weak __typeof__(self) weakSelf = self;
        MainBottomView *bottomView = [[MainBottomView alloc]init];
        bottomView.frame = CGRectMake(0, SCREEN_HEIGHT - [self mTabbarHeight] , SCREEN_WIDTH, [self mTabbarHeight]);
       
        if (@available(iOS 11.0, *)) {
            bottomView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"menubarBgc"]]];
        } else {
            // Fallback on earlier versions
        }
        
        bottomView.myBlock = ^(SPButton * _Nonnull button) {
            [weakSelf GetFunctionWithfunctionSender:button WithfunctionId:0];
        };
        
        [UIView setViewBorder:bottomView color:[UIColor colorWithHexString:@"#C0C0C0"] border:0.5f type:UIViewBorderLineTypeTop];
        
        [self.view addSubview:bottomView];
    }
    
}

#pragma mark---强制退出app
- (void)exitApplication{
     AppDelegate *delegate  = (AppDelegate *)[UIApplication sharedApplication].delegate;
     UIWindow *window = delegate.window;
    [UIView animateWithDuration:1.0 animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
        
    } completion:^(BOOL finished) {
        exit(0);
    }];
    
}


-(void)GoBackWithString:(NSString *)imageStr{
     self.navigationItem.hidesBackButton = YES;
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [backButton setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [backButton setShowsTouchWhenHighlighted:TRUE];
    UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationItem.leftBarButtonItem = barBackItem;
    [backButton addAcionBlock:^(UIButton * _Nonnull button) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

-(void)GetUPNavigationView{
    MainNavigationBarView *barView = [[MainNavigationBarView alloc]init];
    barView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [self mNavigationbarHeight]);
    barView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navbarBgc"]]];
    
    [UIView setViewBorder:barView color:[UIColor colorWithHexString:@"#C0C0C0"] border:0.5f type:UIViewBorderLineTypeBottom];
        /**
         导航栏左右按钮添加点击事件
         */
         __weak typeof(self)weakSelf = self;
    
        [barView.leftButton addAcionBlock:^(UIButton * _Nonnull button) {
    
            SPButton *spButton = (SPButton *)button;
            [weakSelf GetFunctionWithfunctionSender:spButton WithfunctionId:0];
        }];
    
        [barView.rightButton addAcionBlock:^(UIButton * _Nonnull button) {
            SPButton *spButton = (SPButton *)button;
            [weakSelf GetFunctionWithfunctionSender:spButton WithfunctionId:0];
        }];
    [self.view addSubview:barView];
}

@end
