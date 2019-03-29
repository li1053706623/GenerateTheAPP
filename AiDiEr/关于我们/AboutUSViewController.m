//
//  AboutUSViewController.m
//  AiDiEr
//
//  Created by Apple on 2018/12/11.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "AboutUSViewController.h"


@interface AboutUSViewController ()

@property(nonatomic,strong)UILabel *aboutUsTareaLabel;

@property(nonatomic,strong)UILabel *namelabel;

@property(nonatomic,strong)UIImageView *imageview;

@property(nonatomic,strong)MainBottomView *bottomView;



@end

@implementation AboutUSViewController

-(UILabel *)aboutUsTareaLabel{
    if (!_aboutUsTareaLabel) {
        _aboutUsTareaLabel = [[UILabel alloc]init];
        _aboutUsTareaLabel.font = [UIFont systemFontOfSize:13];
        _aboutUsTareaLabel.textColor = [UIColor blackColor];
       _aboutUsTareaLabel.backgroundColor = [UIColor lightTextColor];
        _aboutUsTareaLabel.numberOfLines = 0;
    }
    return _aboutUsTareaLabel;
}
-(UILabel *)namelabel{
    if (!_namelabel) {
        _namelabel = [[UILabel alloc]init];
        _namelabel.font = [UIFont systemFontOfSize:13];
        _namelabel.numberOfLines = 0;
        _namelabel.text = [NSString stringWithFormat:@"%@V%@",[[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleDisplayName"],[[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    }
    return _namelabel;
}
-(UIImageView *)imageview{
    if (!_imageview) {
        _imageview = [[UIImageView alloc]init];
        [_imageview setImage:[UIImage imageNamed:@"appIcon"]];
        _imageview.contentMode = UIViewContentModeScaleAspectFit;
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
    

//    NSLog(@"---%@",[dataDict objectForKey:@"aboutUsTarea"]);
    NSMutableAttributedString *promiseLabelText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"aboutUsTarea"]]] ;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.headIndent = 0.0;
    style.firstLineHeadIndent = 13*2;
    [promiseLabelText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, promiseLabelText.length)];
    self.aboutUsTareaLabel.attributedText = promiseLabelText;
    
    [self setTitle:@"关于我们"];
    
    [self.view addSubview:self.aboutUsTareaLabel];
    
    [self.aboutUsTareaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).mas_offset(10);
        make.trailing.mas_equalTo(self.view).mas_offset(-10);
        make.top.mas_equalTo(self.view.mas_centerY).mas_offset(5);
    }];
    
    [self.view addSubview:self.namelabel];

    [self.namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.aboutUsTareaLabel.mas_top).offset(-30);
        make.centerX.equalTo(self.view);
    }];

    [self.view addSubview:self.imageview];
    [self.imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.namelabel.mas_top).offset(-10);
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(120, 120)));
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


@end
