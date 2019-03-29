//
//  MainBottomView.h
//  AiDiEr
//
//  Created by Apple on 2019/2/12.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MainBottomViewDelegate <NSObject>

-(void)loadSendButtonTag:(NSInteger)tag;

@end

@interface MainBottomView : UIView

@property(nonatomic,strong)NSDictionary *MainBottomdataDict;

/**********定义block************/
@property (nonatomic,copy) void (^Block)(NSInteger buttonTag);

@property(nonatomic,weak)id<MainBottomViewDelegate>delegate;



@end

NS_ASSUME_NONNULL_END
