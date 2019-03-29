//
//  RefreshLoadingView.m
//  AiDiEr
//
//  Created by Apple on 2019/3/7.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "RefreshLoadingView.h"

@interface RefreshLoadingView ()



@property(nonatomic,strong)UILabel *loadingLabel;

@end

@implementation RefreshLoadingView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self loadSetting];
    }
    return self;
}

-(void)loadSetting{
    
    [self addSubview:self.circleView];
    [self addSubview:self.loadingLabel];
    
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.circleView.mas_bottom).mas_offset(10);
      
    }];
    
     [self rotateImageView];
}

-(void)rotateImageView{
    // 一秒钟旋转几圈
    CGFloat circleByOneSecond = 3.f;
    // 执行动画
    [UIView animateWithDuration:1.f / circleByOneSecond
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.circleView.transform =  CGAffineTransformRotate(self.circleView.transform, M_PI_2);
                         
                         
                     } completion:^(BOOL finished) {
                         [self rotateImageView];
        }];
}



#pragma mark---setting

-(UIImageView *)circleView{
    if (!_circleView) {
        _circleView                 = [[UIImageView alloc] init];
//        _circleView.image           = [UIImage imageNamed:@"loading"];
//        _circleView.center          = self.center;
    }
    return _circleView;
}

-(UILabel *)loadingLabel{
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc]init];
        _loadingLabel.text = @"正在玩命加载中,请稍等...";
        _loadingLabel.textColor = [UIColor whiteColor];
        _loadingLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return _loadingLabel;
}
@end
