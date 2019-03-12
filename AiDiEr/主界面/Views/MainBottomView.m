//
//  MainBottomView.m
//  AiDiEr
//
//  Created by Apple on 2019/2/12.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "MainBottomView.h"


@implementation MainBottomView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{
   
//     self.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"menubarBgc"]]];
    
//    self.backgroundColor = [UIColor redColor];
//    UIViewController *vc = [[UIViewController alloc]init];
    
    NSInteger number = [[dataDict objectForKey:@"menubarFun"]count];
    CGFloat width = 30.f; // 每个功能按钮之间的间隙
    CGFloat gap = 20.f; // 第一个与最后一个按钮距离屏幕的距离
    CGFloat space = (SCREEN_WIDTH - number * width - gap * 2) / (number - 1);
    for (NSInteger index = 0; index < number; index++) {
        CGRect frame = CGRectMake(index * (width + space) + gap, 10, width, width);
        SPButton *button = [[SPButton alloc]initWithImagePosition:SPButtonImagePositionTop];
        button.frame = frame;
        
         __weak typeof(self)weakSelf = self;
        [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [button setTitle:[NSString stringWithFormat:@"%@",[[dataDict objectForKey:@"menName"]objectAtIndex:index]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"menuTitleColorNormal"]]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"menuTitleColorSelect"]]] forState:UIControlStateSelected];
        [button sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[dataDict objectForKey:@"menuDefauinput"]objectAtIndex:index]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"home"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            button.imageView.image = [weakSelf ct_imageFromImage:image inRect:button.frame];
        }];;
        [button sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[dataDict objectForKey:@"menuSeleinput"]objectAtIndex:index]]] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(GetFunctionWithfunctionId:)
         forControlEvents:UIControlEventTouchUpInside];
        button.imageTitleSpace = 6;
//        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        button.imageView.clipsToBounds = YES;
        button.tag = [[[dataDict objectForKey:@"menubarFun"]objectAtIndex:index]integerValue];
        [self addSubview:button];
        
//        button.imagePosition = SPButtonImagePositionTop;
        //        [self.btnArray addObject:button];
        //        [self.tagArray addObject:@(button.tag)];
    }
}

-(void)GetFunctionWithfunctionId:(SPButton *)spButton{
    if (self.myBlock) {
        self.myBlock(spButton);
    }
}
-(UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    CGSize size=image.size;
    
    float a = rect.size.width/rect.size.height;
    float X = 0;
    float Y = 0;
    float W = 0;
    float H = 0;
    
    if (size.width>size.height) {
        
        H= size.height;
        W= H*a;
        Y=0;
        X=  (size.width - W)/2;
        
        if ((size.width - size.height*a)/2<0) {
            
            W = size.width;
            H = size.width/a;
            Y= (size.height-H)/2;
            X=0;
        }
        
    }else{
        
        W= size.width;
        H= W/a;
        X=0;
        Y=  (size.height - H)/2;
        
        if ((size.height - size.width/a)/2<0) {
            
            H= size.height;
            W = size.height*a;
            X= (size.width-W)/2;
            Y=0;
        }
        
    }
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    //    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect dianRect = CGRectMake(X, Y, W, H);//CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    CGImageRelease(sourceImageRef);
    
    
    return newImage;
    
}

@end
