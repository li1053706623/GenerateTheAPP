//
//  SZKNetWorkUtils.m
//  AiDiEr
//
//  Created by Apple on 2019/3/12.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "SZKNetWorkUtils.h"

@implementation SZKNetWorkUtils

#pragma mark----网络检测
+(void)netWorkState:(netStateBlock)block{
     AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 提示：要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
//      __weak typeof(self)weakSelf = self;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        block(status);
//        if (status == 0 || status == 1) {
//
//            block(status);
//        }
    }];
}
@end
