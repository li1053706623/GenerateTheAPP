//
//  MainNavigationBarView.m
//  AiDiEr
//
//  Created by Apple on 2019/3/7.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "MainNavigationBarView.h"

@interface MainNavigationBarView()

/**********title************/
@property (nonatomic,strong) UILabel *VCtitlelabel;

@end
@implementation MainNavigationBarView
-(SPButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [[SPButton alloc]init];
//        _leftButton.imageView.clipsToBounds = YES;
        _leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_leftButton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navbarLIco"]]] forState:UIControlStateNormal];
        _leftButton.tag = [[dataDict objectForKey:@"navbarSelect"]integerValue];
        
        
        
    }
    return _leftButton;
}
-(SPButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [[SPButton alloc]init];
//        _rightButton.imageView.clipsToBounds = YES;
        _rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_rightButton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navRIcon"]]] forState:UIControlStateNormal];
        _rightButton.tag = [[dataDict objectForKey:@"navbarRsele"]integerValue];
    
    }
    return _rightButton;
}

-(UILabel *)VCtitlelabel{
    if (!_VCtitlelabel) {
        _VCtitlelabel = [[UILabel alloc]init];
        _VCtitlelabel.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navbarTitle"]];
        _VCtitlelabel.textColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"navbarFcolor"]]];
        _VCtitlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        
    }
    return _VCtitlelabel;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self loadSetting];
        
    }
    return self;
}


-(void)loadSetting{
    
    
    [self addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY).mas_offset(10);
        make.leading.mas_equalTo(self.mas_leading).mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY).mas_offset(10);
        make.trailing.mas_equalTo(self.mas_trailing).mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self addSubview:self.VCtitlelabel];
    [self.VCtitlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.leftButton.mas_centerY);
    }];
    
}
@end
