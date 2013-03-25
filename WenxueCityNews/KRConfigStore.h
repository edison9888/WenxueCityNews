//
//  KRConfigStore.h
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-20.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KR_PAGE_SIZE 50
#define KR_OPTION_COUNT 4
#define KR_FONT_COUNT 4

@interface KRConfigStore : NSObject
{
    NSArray *nameArray;
}
@property(nonatomic, copy) NSNumber* pageSize;
@property(nonatomic, copy) NSNumber* fontSize;

+ (KRConfigStore *)sharedStore;
- (void)save;
-(NSString*)sizeName:(int)size;
-(int)textSize;
@end
