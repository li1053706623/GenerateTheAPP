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

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** headerIcon */
@property (nonatomic, weak) UIImageView *headerIcon;
/** data */
@property (nonatomic, strong) NSMutableArray *data;
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
//    self.headerIcon.frame = CGRectMake(self.tableView.frame.size.width / 2 - 36, 39, 72, 72);
}

- (void)setupUI {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.scrollEnabled = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.frame = CGRectMake(0, 0, 0, 50);
    self.tableView.tableHeaderView = headerView;
    
//    /** 头像图片 */
//    UIImageView *headerIcon = [[UIImageView alloc] init];
//    headerIcon.image = [UIImage imageNamed:@"avatar_login"];
//    headerIcon.frame = CGRectMake(0, 39, 72, 72);
//    headerIcon.layer.cornerRadius = 36;
//    headerIcon.clipsToBounds = YES;
//    [headerView addSubview:headerIcon];
//    self.headerIcon = headerIcon;
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
    cell.item = self.data[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JYJCommenItem *item = self.data[indexPath.row];
    if (item.destClass == 0) return;
    
    for (UIView* next = [self.view superview]; next; next = next.superview) {
        
        UIResponder *nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[JYJAnimateViewController class]]) {
            JYJAnimateViewController *vc = (JYJAnimateViewController *)nextResponder;
            [vc closeAnimation];
            
            
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
//    NSLog(@"---%ld",functionID);
    SPButton *button;
    [self GetFunctionWithfunctionSender:button WithfunctionId:functionID];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
