//
//  KRNewsStore.h
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-13.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@class KRNews;

@interface KRNewsStore : NSObject
{
    NSMutableArray *allItems;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (KRNewsStore *)sharedStore;

- (void)removeItem:(KRNews *)news;

- (NSArray *)allItems;

- (void)addItem:(KRNews *)news;

- (NSString *)itemArchivePath;

- (BOOL)saveChanges;

- (void)loadAllItems;

- (void) loadNews: (int)from to:(int)to max:(int)max withHandler:(void (^)(KRNews *news, NSError *error))handler;

@end
