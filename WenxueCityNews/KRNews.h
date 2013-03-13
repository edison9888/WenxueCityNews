//
//  KRNews.h
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-13.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface KRNews : NSManagedObject

@property (nonatomic) NSInteger newsId;
@property (nonatomic) BOOL read;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic) NSTimeInterval dateCreated;

@end
