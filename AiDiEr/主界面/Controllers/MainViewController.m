//
//  MainViewController.m
//  AiDiEr
//
//  Created by Apple on 2019/3/11.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController ()<WKUIDelegate,WKNavigationDelegate,UIGestureRecognizerDelegate,FSActionSheetDelegate>
{
    NSString *_qrCodeString;
}
@property(nonatomic,assign)CGFloat navHight;
@property(nonatomic,strong)WKWebView *webView;
@property(nonatomic,strong)NSMutableArray *btnArray;
@property(nonatomic,strong) NSMutableArray *tagArray;
@property(nonatomic,strong) NSDictionary * runBlockDict;
@property(nonatomic,strong)LYEmptyView *emptyView;
@property(nonatomic,strong)UIImage *saveImage;
@property(nonatomic,strong) UIProgressView *myProgressView;
@property(nonatomic,strong)PopMenu *popMenu;
@property(nonatomic,strong)RefreshLoadingView *loadingView;

@end

@implementation MainViewController

-(NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}
-(NSMutableArray *)tagArray{
    if (!_tagArray) {
        _tagArray = [NSMutableArray array];
    }
    return _tagArray;
}

- (WKWebView *)webView{
    if (!_webView) {
        //设置网页的配置文件
        WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
        //允许视频播放
        Configuration.allowsAirPlayForMediaPlayback = YES;
        // 允许在线播放
        Configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        Configuration.selectionGranularity = YES;
        NSString * JS = [NSString stringWithFormat:@"loadDetail(\"%d\")",70];
        WKUserScript * script = [[WKUserScript alloc]initWithSource:JS injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController * UserContentController = [[WKUserContentController alloc]init];
        [UserContentController addUserScript:script];
        // 是否支持记忆读取
        Configuration.suppressesIncrementalRendering = YES;
        // 允许用户更改网页的设置
        Configuration.userContentController = UserContentController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:Configuration];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webView.contentMode = UIViewContentModeRedraw;
        _webView.opaque = YES;
        _webView.UIDelegate =self;
        _webView.navigationDelegate = self;
        //开启手势触摸
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.opaque = NO;
        _webView.multipleTouchEnabled = YES;
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return _webView;
}

- (UIProgressView *)myProgressView
{
    if (_myProgressView == nil) {
        _myProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 65, SCREEN_WIDTH, 0)];
        _myProgressView.tintColor = [UIColor blueColor];
        _myProgressView.trackTintColor = [UIColor whiteColor];
    }
    
    return _myProgressView;
}
-(LYEmptyView *)emptyView{
    if (!_emptyView) {
        __weak typeof(self)weakSelf = self;
        _emptyView = [LYEmptyView emptyActionViewWithImageStr:
                      [NSString stringWithFormat:@"多云@3x"]
                                                     titleStr:[NSString stringWithFormat:@"测试"]
                                                    detailStr:[NSString stringWithFormat:@"没有网络"]
                                                  btnTitleStr:[NSString stringWithFormat:@"重新加载"]
                                                btnClickBlock:^{
                                                   [weakSelf reload];
                                                }];
        _emptyView.subViewMargin = 12.f;
        
        _emptyView.titleLabTextColor = MainColor(125, 125, 125);
        
        _emptyView.detailLabTextColor = MainColor(192, 192, 192);
        
        _emptyView.actionBtnFont = [UIFont systemFontOfSize:15.f];
        _emptyView.actionBtnTitleColor = MainColor(90, 90, 90);
        _emptyView.actionBtnHeight = 30.f;
        _emptyView.actionBtnHorizontalMargin = 22.f;
        _emptyView.actionBtnCornerRadius = 2.f;
        _emptyView.actionBtnBorderColor = MainColor(150, 150, 150);
        _emptyView.actionBtnBorderWidth = 0.5;
        
    }
    return _emptyView;
}
//---------------------------------------以上为懒加载方法-------------------------------------------

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![defaults boolForKey:iconfirst]) {
        
        [defaults setBool:YES forKey:iconfirst];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeIconBtnClick];
        });
    }
    
    //加载导航栏
    [self GetUPNavigationView];
    
    //加载底部菜单栏
    [self GetUPBottomView];
    
    //加载webView
    [self loadWebView];
    
    //无网视图
    [self CreatNoNetView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NetWorkStatesChange:) name:@"isNotReachable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NetWorkStatesChange:) name:@"noNotReachable" object:nil];
    
    /**
     添加右滑显示左侧栏
     */
    if ([[dataDict objectForKey:@"navbarSelect"]integerValue] == 10) {
        
        __weak typeof(self)weakSelf = self;
        [self.view addSlideWithSwipeGestureRecognizerDirection:UISwipeGestureRecognizerDirectionRight EventBlock:^(id obj) {
            JYJAnimateViewController *vc = [[JYJAnimateViewController alloc] init];
            vc.view.backgroundColor = [UIColor clearColor];
            [weakSelf addChildViewController:vc];
            [weakSelf.view addSubview:vc.view];
        }];
    }
    
    
    [self.view addSubview:self.myProgressView];
}
/**
 无网视图
 */
#pragma mark--- 无网视图
-(void)CreatNoNetView{
    
    [self.view addSubview:self.emptyView];
    
}

#pragma mark--- 刚开始进入判断网络状态
-(void)startNetworkMonitoring{
    
    AppDelegate *delegate  = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.netWorkStatesCode == 0) {
        [self.emptyView setHidden:NO];
    }else{
        [self.emptyView setHidden:YES];
    }
}

#pragma mark---加载webView
-(void)loadWebView{
    
    CGFloat tabbatHeight;
    if ([[dataDict objectForKey:@"menuBarRadio"]integerValue] !=0) {
        tabbatHeight = [self mTabbarHeight];
    }else{
        tabbatHeight = 0;
    }
    __weak typeof(self)weakSelf = self;
    __weak WKWebView *webView = self.webView;
    __weak UIScrollView *scrollView = webView.scrollView;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"appUrl"]]]]];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset([weakSelf mNavigationbarHeight] + 0.5);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.equalTo(self.view).mas_equalTo(-tabbatHeight);
    }];
    
    //    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    webView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1 ;
    longPress.delegate = self;
    [webView addGestureRecognizer:longPress];
    
    
    [webView addClickEventBlock:^(id  _Nonnull obj) {
        UILongPressGestureRecognizer *sender = (UILongPressGestureRecognizer *)obj;
        CGPoint touchPoint = [sender locationInView:webView];
        // 获取长按位置对应的图片url的JS代码
        NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
        [webView evaluateJavaScript:imgJS completionHandler:^(id _Nullable imgURL, NSError * _Nullable error) {
            
            
        }];
    }];
    
    //    __weak WKWebView *webview = self.webview;
    ////
    
    ////
    //    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //
    scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [webView reload];
        
        
    }];
    
    
    
    
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender{
    
    
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    __weak WKWebView *webView = (WKWebView *)self.webView;
    __weak typeof(self)weakSelf = self;
    CGPoint touchPoint = [sender locationInView:webView];
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    // 执行对应的JS代码 获取url
    //    __weak typeof(self)weakSelf = self;
    [webView evaluateJavaScript:imgJS completionHandler:^(id _Nullable imgURL, NSError * _Nullable error) {
        
        NSLog(@"-----%@",imgURL);
        if (imgURL) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
            UIImage *image = [UIImage imageWithData:data];
            if (!image) {
                NSLog(@"读取图片失败");
                return;
            }
            
            weakSelf.saveImage = image;
            
            FSActionSheet *actionSheet = nil;
            if ([self isAvailableQRcodeIn:image]) {
                actionSheet = [[FSActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" highlightedButtonTitle:nil otherButtonTitles:@[@"保存图片", @"打开二维码"]];
            }else {
                actionSheet = [[FSActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" highlightedButtonTitle:nil otherButtonTitles:@[@"保存图片"]];
            }
            [actionSheet show];
        }
    }];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (BOOL)isAvailableQRcodeIn:(UIImage *)img{
    UIImage *image = [img imageByInsetEdge:UIEdgeInsetsMake(-20, -20, -20, -20) withColor:[UIColor lightGrayColor]];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >= 1) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        _qrCodeString = [feature.messageString copy];
        NSLog(@"二维码信息:%@", _qrCodeString);
        return YES;
    } else {
        NSLog(@"无可识别的二维码");
        return NO;
    }
}
#pragma mark - FSActionSheetDelegate
- (void)FSActionSheet:(FSActionSheet *)actionSheet selectedIndex:(NSInteger)selectedIndex{
    switch (selectedIndex) {
        case 0:
        {
            UIImageWriteToSavedPhotosAlbum(self.saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
            break;
        case 1:
        {
            NSURL *qrUrl = [NSURL URLWithString:_qrCodeString];
            // Safari打开
            if ([[UIApplication sharedApplication] canOpenURL:qrUrl]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:qrUrl options:@{} completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                }
            }
            // 内部应用打开
            
        }
            break;
            
        default:
            break;
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *message = nil ;
    if(error != NULL){
        
        message = @"保存图片失败" ;
        
    }else{
        
        message = @"保存图片成功" ;
        
    }
    
    [self showAlertViewContrllerWithMessage:message];
    
}

#pragma mark---更换Icon图标
- (void)changeIconBtnClick{
    
    
    
    NSString *iconName = [NSString stringWithFormat:@"%@",@"APPIcon"];
    //    must be used from main thread only
    if (@available(iOS 10.3, *)) {
        if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
            //不支持动态更换icon
            return;
        }
    } else {
        // Fallback on earlier versions
    }
    
    if ([iconName isEqualToString:@""] || !iconName) {
        iconName = nil;
    }
    if (@available(iOS 10.3, *)) {
        [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"更换app图标发生错误了 ： %@",error.localizedDescription);
            }else{
                NSLog(@"更换app图标成功");
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - 网络状态发生变化通知方法
-(void)NetWorkStatesChange:(NSNotification *)notification{
    
    int networkState = 0;
    if (networkState == [notification.userInfo[@"status"]intValue]) {
        //        NSLog(@"----没有网络");
        [self.emptyView setHidden:NO];
    }else{
        //         NSLog(@"-----有网络");
        //         [self.emptyView setHidden:YES];
    }
    
}
#pragma mark---加载URL
-(void)reload{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"appUrl"]]] ;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer;
    //获取到拖拽的速度 >0 向下拖动 <0 向上拖动
    CGFloat velocity = [pan velocityInView:scrollView].y;
    if (velocity <- 5) {
        NSLog(@"向上拖动，隐藏导航栏");
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            self.webView.frame = CGRectMake(0, [self mStatusbarHeight], SCREEN_WIDTH, SCREEN_HEIGHT - [self mTabbarHeight] - [self mStatusbarHeight]);
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            
        } completion:^(BOOL finished) {
            
        }];
        
    }else if (velocity > 5) {
        NSLog(@"向下拖动，显示导航栏");
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            self.webView.frame = CGRectMake(0, [self mNavigationbarHeight], SCREEN_WIDTH, SCREEN_HEIGHT - [self mNavigationbarHeight] - [self mTabbarHeight]);
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            
        } completion:^(BOOL finished) {
            
        }];
        
    }else if(velocity == 0){
        
        if (self.webView.scrollView.contentOffset.y == 0) {
            
            NSLog(@"7777777777777777");
        }
        NSLog(@"停止拖拽");
        //        停止拖拽
    }
}
/**功能按钮功能的实现*/
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
            [self mainloadshare];
            break;
        case 2:
            [self GobackMain];
            break;
        case 3:
        {
            if (self.webView.canGoForward) {
                [self.webView goForward];
            }
        }
            break;
            
        case 4:
        {
            if (self.webView.canGoBack) {
                [self.webView goBack];
            }
        }
            break;
        case 5:
            [self dialPhoneNumber];
            break;
        case 6:
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baidu.com"] options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
            }
            break;
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
        {
            [self.webView reloadFromOrigin];
        }
            break;
            
        case 13:
        {
            [self exitApplication];
        }
            
            break;
        default:
            break;
    }
}

-(void)mainloadshare{
    
    //    NSArray *imageArray = @[@"QQ",@"QQZONE",@"WeChat",@"WeChatFirend",@"SMS"];
    //    NSArray *titleArray = @[@"QQ",@"QQ空间",@"微信好友",@"朋友圈",@"短信"];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:3];
    MenuItem *menuItem = [MenuItem itemWithTitle:@"QQ好友" iconName:@"QQ"];
    [items addObject:menuItem];
    
    menuItem = [MenuItem itemWithTitle:@"QQ空间" iconName:@"QQZONE"];
    [items addObject:menuItem];
    
    menuItem = [MenuItem itemWithTitle:@"微信好友" iconName:@"WeChat"];
    [items addObject:menuItem];
    
    menuItem = [MenuItem itemWithTitle:@"朋友圈" iconName:@"WeChatFirend"];
    [items addObject:menuItem];
    
    menuItem = [MenuItem itemWithTitle:@"短信" iconName:@"SMS"];
    [items addObject:menuItem];
    
    if (!_popMenu) {
        _popMenu = [[PopMenu alloc] initWithFrame:self.view.bounds items:items];
        _popMenu.menuAnimationType = kPopMenuAnimationTypeNetEase;
    }
    if (_popMenu.isShowed) {
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    _popMenu.didSelectedItemCompletion = ^(MenuItem * _Nonnull selectedItem) {
        
        [weakSelf YBJShareViewDidSelecteBtnWithBtnText:selectedItem.title];
    };
    
    [_popMenu showMenuAtView:self.view startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, SCREEN_HEIGHT)];
}

-(void)GobackMain{
    
    self.loadingView = [[RefreshLoadingView alloc]init];
    self.loadingView.backgroundColor = [UIColor blackColor];
    self.loadingView.alpha = 0.9;
    self.loadingView.hidden = NO;
    [self.view addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 100));
    }];
    
    
    
    //    self.threeDot = [[FeThreeDotGlow alloc]initWithView:self.view blur:NO];
    //    self.threeDot.alpha = 0.9;
    //    [self.threeDot setHidden:NO];
    //    [self.view addSubview:self.threeDot];
    //    [self.threeDot show];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"appUrl"]]]]];
}


- (void)YBJShareViewDidSelecteBtnWithBtnText:(NSString *)btText{
    
    if ([btText isEqualToString:@"QQ好友"]) {
        if ([[dataDict objectForKey:@"QQradio"]integerValue] == 0) {
            [self showAlertViewContrllerWithMessage:@"您没有开启此功能"];
        }else{
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
                [self showShareSSDKPlatformType:SSDKPlatformSubTypeQQFriend];
            }else{
                [self showAlertViewContrllerWithMessage:@"您未安装QQ,暂无法分享"];
            }
            
        }
        
    }else if ([btText isEqualToString:@"QQ空间"]){
        if ([[dataDict objectForKey:@"QQradio"]integerValue] == 0) {
            [self showAlertViewContrllerWithMessage:@"您没有开启此功能"];
        }else{
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
                [self showShareSSDKPlatformType:SSDKPlatformSubTypeQZone];
            }else{
                [self showAlertViewContrllerWithMessage:@"您未安装QQ,暂无法分享"];
            }
            
        }
    }else if ([btText isEqualToString:@"微信好友"]){
        if ([[dataDict objectForKey:@"wechatRadio"]integerValue] == 0) {
            [self showAlertViewContrllerWithMessage:@"您没有开启此功能"];
        }else{
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]]) {
                [self showShareSSDKPlatformType:SSDKPlatformSubTypeWechatSession];
            }else{
                [self showAlertViewContrllerWithMessage:@"您未安装微信,暂无法分享"];
            }
            
        }
    }else if ([btText isEqualToString:@"朋友圈"]){
        if ([[dataDict objectForKey:@"wechatRadio"]integerValue] == 0) {
            [self showAlertViewContrllerWithMessage:@"您没有开启此功能"];
        }else{
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]]) {
                [self showShareSSDKPlatformType:SSDKPlatformSubTypeWechatTimeline];
            }else{
                [self showAlertViewContrllerWithMessage:@"您未安装微信,暂无法分享"];
            }
            
        }
    }else if ([btText isEqualToString:@"短信"]){
        if ([[dataDict objectForKey:@"messages"]integerValue] == 0) {
            [self showAlertViewContrllerWithMessage:@"您没有开启此功能"];
        }else{
            [self showShareSSDKPlatformType:SSDKPlatformTypeSMS];
        }
    }else{
        
    }
}

-(void)showShareSSDKPlatformType:(SSDKPlatformType)type{
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[UIImage imageNamed:@"shareImg.png"]];
    [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                     images:imageArray
                                        url:[NSURL URLWithString:@"http://mob.com"]
                                      title:@"分享标题"
                                       type:SSDKContentTypeAuto];
    
    [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                [YJProgressHUD showMessage:@"分享成功" inView:self.view];
            }
                
                break;
                
            case SSDKResponseStateFail:
            {
                [YJProgressHUD showMessage:[NSString stringWithFormat:@"分享失败:%@",error.description] inView:self.view];
            }
                break;
                
            case SSDKResponseStateCancel:
            {
                [YJProgressHUD showMessage:@"分享取消" inView:self.view];
            }
                
                break;
            default:
                break;
        }
    }];
}

#pragma mark - WKNavigationDelegate method
// 如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
-(void)webView:(WKWebView *)webview didFinishLoadingURL:(NSURL *)URL{
    
    // 不执行前段界面弹出列表的JS代码
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    NSLog(@"createWebViewWithConfiguration");
    //假如是重新打开窗口的话
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //    NSLog(@"加载完成");
    [self.webView.scrollView.mj_header endRefreshing];
    [self.loadingView setHidden:YES];
    [self.emptyView setHidden:YES];
}
#pragma mark - event response
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]){
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        self.myProgressView.alpha = 1.0f;
        [self.myProgressView setProgress:newprogress animated:YES];
        if (newprogress >=1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.myProgressView.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                
                [self.myProgressView setProgress:0 animated:NO];
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
