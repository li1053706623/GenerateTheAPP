//
//  LeftViewController.m
//  AiDiEr
//
//  Created by Apple on 2018/12/11.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "LeftViewController.h"
#import "JYJCommenItem.h"

#import "JYJProfileCell.h"
#import "JYJAnimateViewController.h"
#import "MainViewController.h"
#import <MessageUI/MessageUI.h>

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource,TencentSessionDelegate,MFMessageComposeViewControllerDelegate>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** headerIcon */
@property (nonatomic, weak) UIImageView *headerIcon;
/** data */
@property (nonatomic, strong) NSMutableArray *data;

@property(nonatomic,strong)PopMenu *popMenu;

@property(nonatomic,strong)TencentOAuth *tencentOAuth;

@end

@implementation LeftViewController

- (NSMutableArray *)data {
    if (!_data) {
        self.data = [NSMutableArray array];
    }
    return _data;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
    [self setupData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.frame = self.view.bounds;
    self.headerIcon.frame = CGRectMake(self.tableView.frame.size.width / 2 - 36, 39, 72, 72);
}

- (void)setupUI {
    
   self.view.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"slideBgc"]]];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.scrollEnabled = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"slideBgc"]]];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"slideBgc"]]];
    headerView.frame = CGRectMake(0, 0, 0, 150);
    self.tableView.tableHeaderView = headerView;
    
    /** 头像图片 */
    UIImageView *headerIcon = [[UIImageView alloc] init];
    headerIcon.image = [UIImage imageNamed:@"appIcon"];
    headerIcon.frame = CGRectMake(0, 39, 72, 72);
    headerIcon.layer.cornerRadius = 36;
    headerIcon.clipsToBounds = YES;
    [headerView addSubview:headerIcon];
    self.headerIcon = headerIcon;
}


- (void)setupData {
    NSArray *icon = [dataDict objectForKey:@"slideIcon"];
    NSArray *titleArray = [dataDict objectForKey:@"slibarName"];
    NSArray *classVCArray = [dataDict objectForKey:@"slidefun"];
    for (NSInteger index = 0; index < icon.count; index++) {
        JYJCommenItem *Item = [JYJCommenItem itemWithIcon:[NSString stringWithFormat:@"%@",icon[index]] title:[NSString stringWithFormat:@"%@",titleArray[index]] subtitle:nil destVcClass:[classVCArray[index]integerValue]];
        [self.data addObject:Item];
        [self.tableView reloadData];
    }
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 创建cell
    JYJProfileCell *cell = [JYJProfileCell cellWithTableView:tableView];
    cell.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@""]];
    cell.item = self.data[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 35;
    
    return [XHWebImageAutoSize imageHeightForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"slideIcon"][indexPath.row]]] layoutWidth:40 estimateHeight:40];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JYJCommenItem *item = self.data[indexPath.row];
    if (item.destClass == 0) return;
    if (item.destClass != 1) {
        for (UIView* next = [self.view superview]; next; next = next.superview) {
            
            UIResponder *nextResponder = [next nextResponder];
            
            if ([nextResponder isKindOfClass:[JYJAnimateViewController class]]) {
                JYJAnimateViewController *vc = (JYJAnimateViewController *)nextResponder;
                [vc closeAnimation];
                
                
            }
        }
    }
    
    [self ExecutivefunctionForfunctionID:item.destClass];
    
    
//    [vc closeAnimation];
//    JYJPushBaseViewController *vc = [[item.destVcClass alloc] init];
//    vc.title = item.title;
//    vc.animateViewController = (JYJAnimateViewController *)self.parentViewController;
//    [self.parentViewController.navigationController pushViewController:vc animated:YES];
}

-(void)ExecutivefunctionForfunctionID:(NSInteger)functionID{

    switch (functionID) {
        case 1:
        {
            [self loadShare];
        }
            break;
        case 5:
        {
            [self dialPhoneNumber];
        }
            break;
        case 8:
        {
            [self aboutus];
        }
            break;
        case 9:
        {
            [self folderSize];
        }
            break;
        case 11:
        {
            DIYScanViewController *scanvc = [[DIYScanViewController alloc] init];
            [self.navigationController pushViewController:scanvc animated:YES];
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
-(void)loadShare{
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
        
        [weakSelf LeftYBJShareViewDidSelecteBtnWithBtnText:selectedItem.title];
    };
    
    [_popMenu showMenuAtView:self.view startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, SCREEN_HEIGHT)];
}

- (void)LeftYBJShareViewDidSelecteBtnWithBtnText:(NSString *)btText{
    
    
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
                [self presentViewController:messsageVC animated:YES completion:nil];
            }
            
        }else{
            [YJProgressHUD showMessage:@"该设备不支持短信分享" inView:self.view afterDelayTime:1];
        }
        
        
    }
}

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


@end
