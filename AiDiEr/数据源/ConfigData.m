//
//  ConfigData.m
//  AiDiEr
//
//  Created by Apple on 2018/12/14.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "ConfigData.h"

@implementation ConfigData


+(NSDictionary *)getConfigDataFromDictionary{
    
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"config.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dict;
}

@end
