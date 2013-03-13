//
//  KRNewsService.h
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-10.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRNewsService : NSObject
- (void) loadNews: (int)from to:(int)to max:(int)max withHandler:(void (^)(NSArray *newsArray, NSError *error))handler;

@end
