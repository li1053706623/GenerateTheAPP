//
//  AboutUSViewController.m
//  AiDiEr
//
//  Created by Apple on 2018/12/11.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "AboutUSViewController.h"


@interface AboutUSViewController ()

@property(nonatomic,strong)UILabel *label;

@property(nonatomic,strong)UILabel *namelabel;

@property(nonatomic,strong)UIImageView *imageview;

@property(nonatomic,strong)MainBottomView *bottomView;



@end

@implementation AboutUSViewController

-(UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc]init];
        _label.font = [UIFont systemFontOfSize:13];
       
        
    }
    return _label;
}
-(UILabel *)namelabel{
    if (!_namelabel) {
        _namelabel = [[UILabel alloc]init];
        _namelabel.font = [UIFont systemFontOfSize:13];
        _namelabel.numberOfLines = 0;
        _namelabel.text = @"艾迪儿\n\n V2.0";
    }
    return _namelabel;
}
-(UIImageView *)imageview{
    if (!_imageview) {
        _imageview = [[UIImageView alloc]init];
        [_imageview setBackgroundColor:[UIColor yellowColor]];
    }
    return _imageview;
}

-(MainBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[MainBottomView alloc]init];
    }
    return _bottomView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
   
    
    [self.navigationController.navigationBar navBarBackGroundColor:[UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navbarBgc"]]] image:nil isOpaque:YES];
    [self.navigationController.navigationBar navBarMyLayerHeight:64 isOpaque:YES];
    //    [self.navigationController.navigationBar navBarBottomLineHidden:YES];
    [self.navigationController.navigationBar navBarAlpha:1 isOpaque:YES];
    

    [self GoBackWithString:@"navigation_back_normal"];
    

    NSMutableAttributedString *promiseLabelText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"aboutUsTarea"]]] ;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.headIndent = 0.0;
    style.firstLineHeadIndent = 13*2;
    [promiseLabelText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, promiseLabelText.length)];
    _label.attributedText = promiseLabelText;
    _label.numberOfLines = 0;
    [self setTitle:@"关于我们"];
    
    [self.view addSubview:self.label];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(10);
        make.trailing.equalTo(self.view).offset(-10);
        make.centerY.equalTo(self.view);
    }];
    
    [self.view addSubview:self.namelabel];
    
    [self.namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.label.mas_top).offset(-30);
        make.centerX.equalTo(self.view);
    }];
    
    [self.view addSubview:self.imageview];
    [self.imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.namelabel.mas_top).offset(-10);
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(100, 100)));
    }];
    
    __weak typeof(self)weakSelf = self;
    
    [self.view addSlideWithSwipeGestureRecognizerDirection:UISwipeGestureRecognizerDirectionRight EventBlock:^(id  _Nonnull obj) {
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    }];
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
