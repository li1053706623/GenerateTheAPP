//
//  DIYScanViewController.m
//  AiDiEr
//
//  Created by Apple on 2018/12/11.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "DIYScanViewController.h"
#import "DIYScanResultViewController.h"

@interface DIYScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, weak) UIImageView *line;
@property (nonatomic, assign) NSInteger distance;

@end

@implementation DIYScanViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //初始化信息
    [self initInfo];
    
    //创建控件
    [self creatControl];
    
    //设置参数
    [self setupCamera];
    //添加定时器
    [self addTimer];
    //返回按钮
    [self GoBackWithString:@"navigation_back_normal"];
    
     __weak typeof(self)weakSelf = self;
    
    [self.view addSlideWithSwipeGestureRecognizerDirection:UISwipeGestureRecognizerDirectionRight EventBlock:^(id  _Nonnull obj) {
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopScanning];
}

- (void)initInfo
{
    //背景色
    self.view.backgroundColor = [UIColor blackColor];
    
    //导航标题
    self.navigationItem.title = @"二维码/条形码";
    
//    //导航右侧相册按钮
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(photoBtnOnClick)];
    
    [self.navigationController.navigationBar navBarBackGroundColor:[UIColor colorWithHexString:[NSString stringWithFormat:@"%@",@"#000000"]] image:nil isOpaque:YES];
    [self.navigationController.navigationBar navBarAlpha:0.5 isOpaque:YES];
}

- (void)creatControl
{
    CGFloat scanW = SCREEN_WIDTH * 0.65;
    CGFloat padding = 10.0f;
    CGFloat labelH = 20.0f;
    CGFloat tabBarH = 96.0f;
    CGFloat cornerW = 26.0f;
    CGFloat marginX = (SCREEN_WIDTH - scanW) * 0.5;
    CGFloat marginY = (SCREEN_HEIGHT - scanW - padding - labelH) * 0.5;
    
    //遮盖视图
    for (int i = 0; i < 4; i++) {
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, (marginY + scanW) * i, SCREEN_WIDTH, marginY + (padding + labelH) * i)];
        if (i == 2 || i == 3) {
            cover.frame = CGRectMake((marginX + scanW) * (i - 2), marginY, marginX, scanW);
        }
        cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self.view addSubview:cover];
    }
    
    //扫描视图
    UIView *scanView = [[UIView alloc] initWithFrame:CGRectMake(marginX, marginY, scanW, scanW)];
    [self.view addSubview:scanView];
    
    //扫描线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanW, 2)];
    [self drawLineForImageView:line];
    [scanView addSubview:line];
    self.line = line;
    
    //边框
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scanW, scanW)];
    borderView.layer.borderColor = [[UIColor whiteColor] CGColor];
    borderView.layer.borderWidth = 1.0f;
    [scanView addSubview:borderView];
    
    //扫描视图四个角
    for (int i = 0; i < 4; i++) {
        CGFloat imgViewX = (scanW - cornerW) * (i % 2);
        CGFloat imgViewY = (scanW - cornerW) * (i / 2);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, cornerW, cornerW)];
        if (i == 0 || i == 1) {
            imgView.transform = CGAffineTransformRotate(imgView.transform, M_PI_2 * i);
        }else {
            imgView.transform = CGAffineTransformRotate(imgView.transform, - M_PI_2 * (i - 1));
        }
        [self drawImageForImageView:imgView];
        [scanView addSubview:imgView];
    }
    
    //提示标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scanView.frame) + padding, SCREEN_WIDTH, labelH)];
    label.text = @"将二维码/条形码放入框内，即可自动扫描";
    label.font = [UIFont systemFontOfSize:16.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    //选项栏
    UIView *tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - tabBarH, SCREEN_WIDTH, tabBarH)];
    tabBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [self.view addSubview:tabBarView];
    
    //开启照明按钮和相册按钮
    
    NSArray *titleArray = [NSArray arrayWithObjects:@"相册",@"开启闪光灯", nil];
    NSArray *imageArray = [NSArray arrayWithObjects:@"相册",@"灯光", nil];
    for (NSInteger index = 0; index < titleArray.count; index++) {
        SPButton *button = [[SPButton alloc]initWithImagePosition:SPButtonImagePositionTop];
        button.frame = CGRectMake(index * (SCREEN_WIDTH / 2), 0, SCREEN_WIDTH / 2, tabBarH);
        [button setTitle:[NSString stringWithFormat:@"%@",titleArray[index]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",imageArray[index]]] forState:UIControlStateNormal];
        button.imageTitleSpace = 10.0f;
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        if (index == 0) {
            [button addTarget:self action:@selector(photoBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:self action:@selector(lightBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:[NSString stringWithFormat:@"%@",@"关闭闪光灯"] forState:UIControlStateSelected];
        }
        [tabBarView addSubview:button];
    }
    
}

- (void)setupCamera
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化相机设备
        weakSelf.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        //初始化输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:weakSelf.device error:nil];
        
        //初始化输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //设置代理，主线程刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //初始化链接对象
        weakSelf.session = [[AVCaptureSession alloc] init];
        //高质量采集率
        [weakSelf.session setSessionPreset:AVCaptureSessionPresetHigh];
        
        if ([weakSelf.session canAddInput:input]) [weakSelf.session addInput:input];
        if ([weakSelf.session canAddOutput:output]) [weakSelf.session addOutput:output];
        
        //条码类型（二维码/条形码）
        output.metadataObjectTypes = [NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil];
        
        //更新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.preview = [AVCaptureVideoPreviewLayer layerWithSession:weakSelf.session];
            weakSelf.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            weakSelf.preview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [weakSelf.view.layer insertSublayer:weakSelf.preview atIndex:0];
            [weakSelf.session startRunning];
        });
    });
}

- (void)addTimer
{
    _distance = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timerAction
{
    if (_distance++ > SCREEN_WIDTH * 0.65) _distance = 0;
    _line.frame = CGRectMake(0, _distance, SCREEN_WIDTH * 0.65, 2);
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

//照明按钮点击事件
- (void)lightBtnOnClick:(SPButton *)btn
{
    //判断是否有闪光灯
    if (![_device hasTorch]) {
        [self showAlertWithTitle:@"当前设备没有闪光灯，无法开启照明功能" message:nil sureHandler:nil cancelHandler:nil];
        return;
    }
    
    btn.selected = !btn.selected;
    
    [_device lockForConfiguration:nil];
    if (btn.selected) {
        [_device setTorchMode:AVCaptureTorchModeOn];
    }else {
        [_device setTorchMode:AVCaptureTorchModeOff];
    }
    [_device unlockForConfiguration];
}

//进入相册
- (void)photoBtnOnClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
    }else {
        [self showAlertWithTitle:@"当前设备不支持访问相册" message:nil sureHandler:nil cancelHandler:nil];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描完成
    if ([metadataObjects count] > 0) {
        //停止扫描
        [self stopScanning];
//        //显示结果
        DIYScanResultViewController *resultVC = [[DIYScanResultViewController alloc]init];
        resultVC.result = [[metadataObjects firstObject]stringValue];
        [self.navigationController pushViewController:resultVC animated:YES];
//        NSLog(@"%@",[[metadataObjects firstObject]stringValue]);
//        [self showAlertWithTitle:@"扫描结果" message:[[metadataObjects firstObject] stringValue] sureHandler:nil cancelHandler:nil];
    }
}

- (void)stopScanning
{
    [_session stopRunning];
    _session = nil;
    [_preview removeFromSuperlayer];
    [self removeTimer];
}

#pragma mark - UIImagePickerControllrDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //获取相册图片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        //识别图片
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        
        //识别结果
        if (features.count > 0) {
//            [self showAlertWithTitle:@"扫描结果" message:[[features firstObject] messageString] sureHandler:nil cancelHandler:nil];
            DIYScanResultViewController *resultVC = [[DIYScanResultViewController alloc]init];
            resultVC.result = [[features firstObject]messageString];
            [self.navigationController pushViewController:resultVC animated:YES];
        }else{
            [self showAlertWithTitle:@"没有识别到二维码或条形码" message:nil sureHandler:nil cancelHandler:nil];
        }
    }];
}

//提示弹窗
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message sureHandler:(void (^)())sureHandler cancelHandler:(void (^)())cancelHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:sureHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:cancelHandler];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//绘制角图片
- (void)drawImageForImageView:(UIImageView *)imageView
{
    UIGraphicsBeginImageContext(imageView.bounds.size);
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条宽度
    CGContextSetLineWidth(context, 6.0f);
    //设置颜色
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    //路径
    CGContextBeginPath(context);
    //设置起点坐标
    CGContextMoveToPoint(context, 0, imageView.bounds.size.height);
    //设置下一个点坐标
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, imageView.bounds.size.width, 0);
    //渲染，连接起点和下一个坐标点
    CGContextStrokePath(context);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

//绘制线图片
- (void)drawLineForImageView:(UIImageView *)imageView
{
    CGSize size = imageView.bounds.size;
    UIGraphicsBeginImageContext(size);
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //创建一个颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //设置开始颜色
    const CGFloat *startColorComponents = CGColorGetComponents([[UIColor greenColor] CGColor]);
    //设置结束颜色
    const CGFloat *endColorComponents = CGColorGetComponents([[UIColor whiteColor] CGColor]);
    //颜色分量的强度值数组
    CGFloat components[8] = {startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]
    };
    //渐变系数数组
    CGFloat locations[] = {0.0, 1.0};
    //创建渐变对象
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    //绘制渐变
    CGContextDrawRadialGradient(context, gradient, CGPointMake(size.width * 0.5, size.height * 0.5), size.width * 0.25, CGPointMake(size.width * 0.5, size.height * 0.5), size.width * 0.5, kCGGradientDrawsBeforeStartLocation);
    //释放
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}



@end
