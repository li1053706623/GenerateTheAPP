//
//  WeakWebViewScriptMessageDelegate.h
//  AiDiEr
//
//  Created by Apple on 2019/4/3.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>

//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

NS_ASSUME_NONNULL_END
