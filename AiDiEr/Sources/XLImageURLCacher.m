//
//  XLImageURLCacher.m
//  AiDiEr
//
//  Created by Apple on 2019/3/29.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "XLImageURLCacher.h"
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import <SDImageCache.h>
#import <UIKit/UIKit.h>

@implementation XLImageURLCacher

static XLImageURLCacher *instance = nil;

+ (XLImageURLCacher *)sharedImageURLCacher {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
    
}

- (void)xl_setCacheWithImageView:(UIImageView *)imageView imageURL:(NSString *)imageURL imageKey:(NSString *)imageKey{
    
}
@end
