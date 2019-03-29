//
//  MainViewController.m
//  AiDiEr
//
//  Created by Apple on 2019/3/11.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "MainViewController.h"
#import "MainNavigationBarView.h"
#import "JSMainBottomView.h"
#import <MessageUI/MessageUI.h>


// WKWebView 内存不释放的问题解决
@interface WeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>

//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
@implementation WeakWebViewScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
//遵循WKScriptMessageHandler协议，必须实现如下方法，然后把方法向外传递
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end

#define Interval 4.0f
@interface MainViewController ()<WKUIDelegate,WKNavigationDelegate,UIGestureRecognizerDelegate,FSActionSheetDelegate,WKScriptMessageHandler,MainBottomViewDelegate,WXApiDelegate,TencentSessionDelegate,MFMessageComposeViewControllerDelegate>
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
@property(nonatomic,strong) MainNavigationBarView *barView;
@property(nonatomic,strong)WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate;
@property(nonatomic,strong)MainBottomView *bottomView;
@property(nonatomic,strong)JSMainBottomView *JSbottomView;
@property(nonatomic,strong)TencentOAuth *tencentOAuth;
//需要将dispatch_source_t myTimer设置为成员变量，不然会立即释放
@property (nonatomic, strong) dispatch_source_t myTimer;
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
          WKWebViewConfiguration *_Configuration  = [[WKWebViewConfiguration alloc]init];
        //允许视频播放
        _Configuration.allowsAirPlayForMediaPlayback = YES;
        // 允许在线播放
        _Configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        _Configuration.selectionGranularity = YES;
        
        _Configuration.preferences = [[WKPreferences alloc]init];
        
        _Configuration.preferences.minimumFontSize = 10;
        
        _Configuration.preferences.javaScriptEnabled = YES;
        
        _Configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        NSString * JS = [NSString stringWithFormat:@"loadDetail(\"%d\")",70];
        WKUserScript * script = [[WKUserScript alloc]initWithSource:JS injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        _weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        
        WKUserContentController * UserContentController = [[WKUserContentController alloc]init];
        [UserContentController addUserScript:script];
        
        // 是否支持记忆读取
        _Configuration.suppressesIncrementalRendering = YES;
        // 允许用户更改网页的设置
        _Configuration.userContentController = UserContentController;
        
        _Configuration.processPool = [[WKProcessPool alloc]init];
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:_Configuration];
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
                      [NSString stringWithFormat:@"no_network"]
                                                     titleStr:[NSString stringWithFormat:@"网络无法连接"]
                                                    detailStr:[NSString stringWithFormat:@"世界上最遥远的距离不是生与死,而是没有网络"]
                                                  btnTitleStr:[NSString stringWithFormat:@"重新加载"]
                                                btnClickBlock:^{
                                                   [weakSelf reloadView];
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

-(RefreshLoadingView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[RefreshLoadingView alloc]init];
        _loadingView.backgroundColor = [UIColor blackColor];
        _loadingView.alpha = 0.9;
        _loadingView.circleView.image           = [UIImage imageNamed:@"loading"];
     
        [self.view addSubview:self.loadingView];
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(200, 100));
        }];
    }
    return _loadingView;
}

-(MainNavigationBarView *)barView{
    if (!_barView) {
        MainNavigationBarView *barView = [[MainNavigationBarView alloc]init];
        barView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [self mNavigationbarHeight]);
        barView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navbarBgc"]]];
        
        [UIView setViewBorder:barView color:[UIColor colorWithHexString:@"#C0C0C0"] border:0.5f type:UIViewBorderLineTypeBottom];
        _barView = barView;
    }
    return _barView;
}
-(MainBottomView *)bottomView{
   
    if (!_bottomView) {
        _bottomView = [[MainBottomView alloc]init];
        
        _bottomView.frame =CGRectMake(0, SCREEN_HEIGHT - [self mTabbarHeight] , SCREEN_WIDTH, [self mTabbarHeight]);
        
        _bottomView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _bottomView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"menubarBgc"]]];
        } else {
            // Fallback on earlier versions
        }
        
        [UIView setViewBorder:_bottomView color:[UIColor colorWithHexString:@"#C0C0C0"] border:0.5f type:UIViewBorderLineTypeTop];
    }
    return _bottomView;
}
-(JSMainBottomView *)JSbottomView{
    
    if (!_JSbottomView) {
        _JSbottomView = [[JSMainBottomView alloc]init];
        
        _JSbottomView.frame =CGRectMake(0, SCREEN_HEIGHT - [self mTabbarHeight] , SCREEN_WIDTH, [self mTabbarHeight]);

        if (@available(iOS 11.0, *)) {
            _JSbottomView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"menubarBgc"]]];
        } else {
            // Fallback on earlier versions
        }
        
        [UIView setViewBorder:_bottomView color:[UIColor colorWithHexString:@"#C0C0C0"] border:0.5f type:UIViewBorderLineTypeTop];
    }
    return _JSbottomView;
}
//---------------------------------------以上为懒加载方法-------------------------------------------

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self.webView.configuration.userContentController addScriptMessageHandler:self.weakScriptMessageDelegate name:@"changeTitleBar"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self.weakScriptMessageDelegate name:@"changeRefreshImg"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self.weakScriptMessageDelegate name:@"changeBottomMenu"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self.weakScriptMessageDelegate name:@"changeLeftMenu"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self.weakScriptMessageDelegate name:@"changeOrientation"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self.weakScriptMessageDelegate name:@"saveLoginInfo"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"changeTitleBar"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"changeRefreshImg"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"changeBottomMenu"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"changeLeftMenu"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"changeOrientation"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"saveLoginInfo"];
    
    //销毁定时器
    dispatch_source_cancel(self.myTimer);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if (![defaults boolForKey:iconfirst]) {
//
//        [defaults setBool:YES forKey:iconfirst];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self changeIconBtnClick];
//        });
//    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self changeIconBtnClick];
//    });
    
    //加载等待视图
//    [self loadLoadingView];
    
    //创建一个专门执行timer回调的GCD队列
    dispatch_queue_t queue = dispatch_queue_create("name", 0);
    //创建Timer
    self.myTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //使用dispatch_source_set_timer函数设置timer参数
    /**
     * dispatch_source_set_timer(dispatch_source_t source,
     dispatch_time_t start,
     uint64_t interval,
     uint64_t leeway);
     * start 计时器起始时间，可以通过dispatch_time创建，如果使用DISPATCH_TIME_NOW，则创建后立即执行
     * interval 计时器间隔时间，可以通过timeInterval * NSEC_PER_SEC来设置，timeInterval为对应的秒数
     * leeway 这个参数告诉系统我们需要计时器触发的精准程度（所以你可以传入60，告诉系统60秒的误差是可接受的）
     */
    dispatch_source_set_timer(self.myTimer, dispatch_time(DISPATCH_TIME_NOW, 0), Interval, 0);

    //设置回调
    dispatch_source_set_event_handler(self.myTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
             self.loadingView.hidden = YES;
        });

    });
    dispatch_resume(self.myTimer);
    
   
    
    if ([[dataDict objectForKey:@"navbarA"]integerValue] == 0 && [[dataDict objectForKey:@"menuBarRadio"]integerValue] == 0) {
        //加载webView
        [self loadWebViewForType:0];
    }else if ([[dataDict objectForKey:@"navbarA"]integerValue] == 1 && [[dataDict objectForKey:@"menuBarRadio"]integerValue] == 0){
        //加载导航栏
        [self GetUPNavigationView];
        //加载webView
        [self loadWebViewForType:1];
    }else if ([[dataDict objectForKey:@"navbarA"]integerValue] == 0 && [[dataDict objectForKey:@"menuBarRadio"]integerValue] == 1){
        //加载webView
        [self loadWebViewForType:2];
        //加载底部菜单栏
        [self GetUPBottomView];
    }else{
        //加载导航栏
        [self GetUPNavigationView];
        //加载webView
        [self loadWebViewForType:3];
        //加载底部菜单栏
        [self GetUPBottomView];
    }
   
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
    
    self.webView.hidden = YES;
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
-(void)GetUPNavigationView{
   
    [self.barView.leftButton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navbarLIco"]]] forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        UIImage *refined = [UIImage imageWithCGImage:image.CGImage scale:3 orientation:image.imageOrientation];
        [self.barView.leftButton setImage:refined forState:UIControlStateNormal];
        
    }];
    
    [self.barView.rightButton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navRIcon"]]] forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        UIImage *refined = [UIImage imageWithCGImage:image.CGImage scale:3 orientation:image.imageOrientation];
        [self.barView.rightButton setImage:refined forState:UIControlStateNormal];
        
    }];
    

    

    /**
     导航栏左右按钮添加点击事件
     */
    __weak typeof(self)weakSelf = self;
    
    [self.barView.leftButton addAcionBlock:^(UIButton * _Nonnull button) {
      
        
        SPButton *spButton = (SPButton *)button;
        [weakSelf GetFunctionWithfunctionId:spButton.tag];
    }];
    
    [self.barView.rightButton addAcionBlock:^(UIButton * _Nonnull button) {
        SPButton *spButton = (SPButton *)button;
        [weakSelf GetFunctionWithfunctionId:spButton.tag];
    }];
    [self.view addSubview:self.barView];
}

-(void)GetUPBottomView{
    
//    _bottomView.Block  = ^(NSInteger buttonTag) {
//        NSLog(@"----%ld",buttonTag);
//    };
     [self.view addSubview:self.bottomView];
//    if ([[dataDict objectForKey:@"menuBarRadio"]integerValue] !=0) {
//        __weak __typeof__(self) weakSelf = self;
//
//        _bottomView.myBlock = ^(SPButton * _Nonnull button) {
//            NSLog(@"----%ld",button.tag);
//            [weakSelf GetFunctionWithfunctionSender:button WithfunctionId:0];
//        };
//
//        [self.view addSubview:self.bottomView];
//    }
    
}

#pragma mark---MainBottomViewDelegate

-(void)loadSendButtonTag:(NSInteger)tag{
    
    [self GetFunctionWithfunctionId:tag];
    
}
#pragma mark---加载webView
-(void)loadWebViewForType:(NSInteger)type{
    
    
//    __weak typeof(self)weakSelf = self;
    __weak WKWebView *webView = self.webView;
    __weak UIScrollView *scrollView = webView.scrollView;
    [self.view addSubview:self.webView];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"javascript.html" ofType:nil];
//    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"appUrl"]]]]];
    
    if (type == 0) { // 无导航栏无菜单栏
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).mas_offset([self mStatusbarHeight]);
            make.leading.bottom.trailing.mas_equalTo(self.view);
        }];
    }else if (type == 1){ // 有导航栏无菜单栏
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).mas_offset([self mNavigationbarHeight] + 0.5);
            make.leading.trailing.bottom.mas_equalTo(self.view);
        }];
    }else if (type == 2){ // 无导航栏有菜单栏
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).mas_offset([self mStatusbarHeight]);
            make.leading.trailing.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).mas_offset(-[self mTabbarHeight]);
        }];
    }else{ // 有导航栏有菜单栏
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.view).mas_offset([self mNavigationbarHeight] + 0.5);
             make.leading.trailing.mas_equalTo(self.view);
             make.bottom.mas_equalTo(self.view).mas_offset(-[self mTabbarHeight]);
        }];
    }
    
    
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
        
//        NSLog(@"-----%@",imgURL);
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
//        NSLog(@"二维码信息:%@", _qrCodeString);
        return YES;
    } else {
//        NSLog(@"无可识别的二维码");
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
    
    NSString *iconName = @"appIcon";
    if (@available(iOS 10.3, *)) {
        
        if (![[UIApplication sharedApplication]supportsAlternateIcons]) {
             //不支持动态更换icon
            return;
        }
        if ([iconName isEqualToString:@""] || !iconName) {
            iconName = nil;
        }
        
        [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
           
            if (error) {
                 NSLog(@"更换app图标发生错误了 ： %@",error.localizedDescription);
            }else{
                NSLog(@"更换app图标成功");
            }
            
        }];
        
    }else{
        
    }
    
}

#pragma mark - 网络状态发生变化通知方法
-(void)NetWorkStatesChange:(NSNotification *)notification{
    
    int networkState = 0;
    if (networkState == [notification.userInfo[@"status"]intValue]) {
        //无网视图
        [self CreatNoNetView];
        //        NSLog(@"----没有网络");
        [self.emptyView setHidden:NO];
    }else{
        //         NSLog(@"-----有网络");
//        [self reloadView];
    }
    
}
#pragma mark---加载URL
-(void)reloadView{
    self.webView.hidden = NO;
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
//        NSLog(@"向下拖动，显示导航栏");
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            self.webView.frame = CGRectMake(0, [self mNavigationbarHeight], SCREEN_WIDTH, SCREEN_HEIGHT - [self mNavigationbarHeight] - [self mTabbarHeight]);
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            
        } completion:^(BOOL finished) {
            
        }];
        
    }else if(velocity == 0){
        
        if (self.webView.scrollView.contentOffset.y == 0) {
//
            NSLog(@"7777777777777777");
        }
        NSLog(@"停止拖拽");
        //        停止拖拽
    }
}
/**功能按钮功能的实现*/
-(void)GetFunctionWithfunctionId:(NSInteger)functionId{
   
//    if (sender.tag == 0) {
//        functionTag = functionId;
//    }else{
//        functionTag = sender.tag;
//    }
    
    
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
    
    
    switch (functionId) {
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
                [YJProgressHUD showMessage:@"马不停蹄的往前走，已经前进了一大步耶！" inView:self.view afterDelayTime:2];
            }
        }
            break;
            
        case 4:
        {
            if (self.webView.canGoBack) {
                [self.webView goBack];
                [YJProgressHUD showMessage:@"退一步海阔天空，您已经后退成功了耶！" inView:self.view afterDelayTime:2];
            }
        }
            break;
        case 5:
        {
            [self dialPhoneNumber];
        }
            
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
            [YJProgressHUD showMessage:@"报告主人，您已完美回到主页！" inView:self.view afterDelayTime:2];
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
    
//        NSArray *imageArray = @[@"sns_icon_24",@"QQZONE",@"WeChat",@"WeChatFirend",@"SMS"];
//        NSArray *titleArray = @[@"QQ",@"QQ空间",@"微信好友",@"朋友圈",@"短信"];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:3];
    MenuItem *menuItem = [MenuItem itemWithTitle:@"QQ好友" iconName:@"sns_icon_24"];
    [items addObject:menuItem];
    
    menuItem = [MenuItem itemWithTitle:@"QQ空间" iconName:@"sns_icon_6"];
    [items addObject:menuItem];
    
    menuItem = [MenuItem itemWithTitle:@"微信好友" iconName:@"sns_icon_22"];
    [items addObject:menuItem];
    
    menuItem = [MenuItem itemWithTitle:@"朋友圈" iconName:@"sns_icon_23"];
    [items addObject:menuItem];
    
    menuItem = [MenuItem itemWithTitle:@"短信" iconName:@"sns_icon_19"];
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
    
   
       self.loadingView.hidden = NO;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"appUrl"]]]]];
}


- (void)YBJShareViewDidSelecteBtnWithBtnText:(NSString *)btText{
    
    if ([btText isEqualToString:@"QQ好友"] || [btText isEqualToString:@"QQ空间"]) {
        if (![TencentOAuth iphoneQQInstalled]) {
            [YJProgressHUD showMessage:@"请移步App Store去下载腾讯QQ客户端" inView:self.view afterDelayTime:1];
            
        }else{
            if ([[dataDict objectForKey:@"QQradio"]integerValue] == 0) {
                [YJProgressHUD showMessage:@"您在封装应用的时候未在第三方配置QQ分享功能" inView:self.view afterDelayTime:3];
            }else{
                self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:[dataDict objectForKey:@"qqId"]
                                                            andDelegate:self];
                QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareURL"]]] title:[dataDict objectForKey:@"shareTitle"] description:[dataDict objectForKey:@"shareContent"] previewImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareImage"]]]];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
                if ([btText isEqualToString:@"QQ好友"]) {
                    [QQApiInterface sendReq:req];
                }
                if ([btText isEqualToString:@"QQ空间"]) {
                    [QQApiInterface SendReqToQZone:req];
                }
            }
            
            
        }
    }
    
    
    if ([btText isEqualToString:@"微信好友"] || [btText isEqualToString:@"朋友圈"]) {
        if (![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi]) {
             [YJProgressHUD showMessage:@"请移步App Store去下载腾讯微信客户端" inView:self.view afterDelayTime:1];
        }else{
            if ([[dataDict objectForKey:@"wechatRadio"]integerValue] == 0) {
                 [YJProgressHUD showMessage:@"您在封装应用的时候未在第三方配置微信分享功能" inView:self.view afterDelayTime:3];
            }else{
                [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareImage"]]] options:SDWebImageDownloaderProgressiveDownload progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    
                    if (image) {
                        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                        WXMediaMessage *message = [WXMediaMessage message];
                        message.title = [dataDict objectForKey:@"shareTitle"];
                        message.description = [dataDict objectForKey:@"shareContent"];
                        [message setThumbImage:image];
                        
                        req.message = message;
                        
                        WXAppExtendObject *ext = [WXAppExtendObject object];
                        ext.url = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareURL"]];
//                        ext.extInfo = @"Hi 天气";
                        message.mediaObject = ext;
                        if ([btText isEqualToString:@"微信好友"]) {
                            req.scene = WXSceneSession;
                        };
                        if ([btText isEqualToString:@"朋友圈"]) {
                            req.scene = WXSceneTimeline;
                        }
                        [WXApi sendReq:req];
                    }
                    
                }];
            }
            
        }
    }
    
    if ([btText isEqualToString:@"短信"]) {
        if ([MFMessageComposeViewController canSendText]) {
            if ([[dataDict objectForKey:@"messages"]integerValue] == 0) {
                [YJProgressHUD showMessage:@"您在封装应用的时候未在第三方配置短信分享功能" inView:self.view afterDelayTime:3];
            }else{
                MFMessageComposeViewController *messsageVC = [[MFMessageComposeViewController alloc]init];
                messsageVC.body = [dataDict objectForKey:@"shareContent"];
                messsageVC.messageComposeDelegate = self;
//                [messsageVC addAttachmentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"shareImage"]]] withAlternateFilename:@"shareImage"];
                [self presentViewController:messsageVC animated:YES completion:nil];
            }
           
        }else{
            [YJProgressHUD showMessage:@"该设备不支持短信分享" inView:self.view afterDelayTime:1];
        }
      
        
    }
    
}
#pragma mark---MFMessageComposeViewConreoller
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultCancelled:
            [YJProgressHUD showMessage:@"取消分享" inView:self.view afterDelayTime:1];
            break;
        case MessageComposeResultSent:
            [YJProgressHUD showMessage:@"分享成功" inView:self.view afterDelayTime:1];
            break;
        case MessageComposeResultFailed:
            [YJProgressHUD showMessage:@"分享失败" inView:self.view afterDelayTime:1];
            break;
        default:
            break;
    }
    
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
    [YJProgressHUD showMessage:@"报告主人，当前页面已刷新完毕！" inView:self.view];
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

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message{
    
     //用message.body获得JS传出的参数体
     __weak typeof(self)weakSelf = self;
    if ([message.name isEqualToString:@"changeTitleBar"]) {
//         NSLog(@"1name:%@\\\\n 1body:%@\\\\n ",message.name,message.body);
        NSDictionary *bodyDict = [(NSDictionary *)message.body objectForKey:@"body"];
        self.barView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[bodyDict objectForKey:@"navbarBgc"]]];
        [self.barView.leftButton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[bodyDict objectForKey:@"navbarLIco"]]] forState:UIControlStateNormal];
        
        [self.barView.rightButton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[bodyDict objectForKey:@"navRIcon"]]] forState:UIControlStateNormal];
        
        self.barView.leftButton.tag = [[bodyDict objectForKey:@"navbarSelect"]integerValue];
        
        self.barView.rightButton.tag = [[bodyDict objectForKey:@"navbarRsele"]integerValue];
        [self.barView.leftButton addAcionBlock:^(UIButton * _Nonnull button) {
            [weakSelf GetFunctionWithfunctionId: weakSelf.barView.leftButton.tag];
        }];
        [self.barView.rightButton addAcionBlock:^(UIButton * _Nonnull button) {
            [weakSelf GetFunctionWithfunctionId:weakSelf.barView.rightButton.tag];
        }];
        
    }else if ([message.name isEqualToString:@"changeRefreshImg"]){
//         NSLog(@"2name:%@\\\\n 2body:%@\\\\n ",message.name,message.body);

        [self.loadingView.circleView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[(NSDictionary *)message.body objectForKey:@"body"]]]];
        
    }else if ([message.name isEqualToString:@"changeBottomMenu"]){
        
        [self.bottomView removeFromSuperview];
        [self.view addSubview:self.JSbottomView];
       
        NSDictionary *bodyDict = [(NSDictionary *)message.body objectForKey:@"body"];
//        NSLog(@"3name:%@\\\\n 3body:%@\\\\n 3menubarFun:%@\n",message.name,message.body,[bodyDict objectForKey:@"menubarFun"]);
        self.JSbottomView.myBlock = ^(SPButton * _Nonnull button) {
            [weakSelf GetFunctionWithfunctionId:button.tag];
        };
        [self.JSbottomView loadDefaultSettingWithMenuFun:[bodyDict objectForKey:@"menubarFun"] WithMenName:[bodyDict objectForKey:@"menName"] WithMenuTitleColorNormal:[bodyDict objectForKey:@"menuTitleColorNormal"] WithMenuTitleColorSelect:[bodyDict objectForKey:@"menuTitleColorSelect"] WithMenuDefauinput:[bodyDict objectForKey:@"menuDefauinput"] ];

        
    }else if ([message.name isEqualToString:@"changeLeftMenu"]){
//         NSLog(@"4name:%@\\\\n 4body:%@\\\\n ",message.name,message.body);
        
        
    }else if ([message.name isEqualToString:@"changeOrientation"]){
//         NSLog(@"5name:%@\\\\n 5body:%@\\\\n ",message.name,message.body);
    }else if ([message.name isEqualToString:@"saveLoginInfo"]){
//         NSLog(@"6name:%@\\\\n 6body:%@\\\\n ",message.name,message.body);
    }
   
}
-(void)loadLoadingView{
    
       self.loadingView.hidden = NO;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
