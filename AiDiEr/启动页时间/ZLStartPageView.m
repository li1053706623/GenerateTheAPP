//
//  ZLStartPageView.m
//  AiDiEr
//
//  Created by Apple on 2019/3/28.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "ZLStartPageView.h"
#import "ZLDrawCircleProgressBtn.h"

@interface ZLStartPageView ()

// 启动页图
@property (nonatomic,strong) UIImageView *imageView;

// 跳过按钮
@property (nonatomic, strong) ZLDrawCircleProgressBtn *drawCircleBtn;

@end


@implementation ZLStartPageView

- (instancetype)initWithFrame:(CGRect)frame WithLaunchImageString:(NSString *)launchImageString{
    
    if (self = [super initWithFrame:frame]) {
        
        // 1.启动页图片
        _imageView = [[UIImageView alloc]initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:launchImageString]];
        [self addSubview:self.imageView];
        
        
        // 2.跳过按钮
        ZLDrawCircleProgressBtn *drawCircleBtn = [[ZLDrawCircleProgressBtn alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 55, 30, 40, 40)];
        drawCircleBtn.lineWidth = 2;
        [drawCircleBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [drawCircleBtn setTitleColor:[UIColor  colorWithRed:197/255.0 green:159/255.0 blue:82/255.0 alpha:1] forState:UIControlStateNormal];
        drawCircleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [drawCircleBtn addTarget:self action:@selector(removeProgress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:drawCircleBtn];
        self.drawCircleBtn = drawCircleBtn;
        
    }
    return self;
}

-(void)showWithStartAnimationDuration:(CGFloat)startAnimationDuration{
    
     __weak typeof(self)weakSelf = self;
    [weakSelf.drawCircleBtn startAnimationDuration:startAnimationDuration withBlock:^{
        [weakSelf removeProgress];
    }];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
}

// 移除启动页面
- (void)removeProgress{
    self.imageView.transform = CGAffineTransformMakeScale(1, 1);
    self.imageView.alpha = 1;
    
    [UIView animateWithDuration:0.1 animations:^{
       
        self.drawCircleBtn.hidden = NO;
        self.imageView.alpha = 0.05;
        self.imageView.transform = CGAffineTransformMakeScale(5,5);
        
    }completion:^(BOOL finished) {
     
        self.drawCircleBtn.hidden = YES;
        [self  removeFromSuperview];
        
        if (self.showGuidePage) {
            self.showGuidePage();
        }
        
    }];
}
@end
