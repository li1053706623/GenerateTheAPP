//
//  SZKNetWorkUtils.h
//  AiDiEr
//
//  Created by Apple on 2019/3/12.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^netStateBlock)(NSInteger netState);

@interface SZKNetWorkUtils : NSObject

@interface SZKNetWorkUtils : NSObject

/**
 *  网络监测
 *
 *  @param block 判断结果回调
 *
 *  @return 网络监测
 */
+(void)netWorkState:(netStateBlock)block;

@end

NS_ASSUME_NONNULL_END
