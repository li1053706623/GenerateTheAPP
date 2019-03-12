//
//  UIImage+InsetEdge.h
//  AiDiEr
//
//  Created by Apple on 2019/3/1.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (InsetEdge)

- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
