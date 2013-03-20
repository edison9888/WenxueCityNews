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
    NSMutableDictionary *keyedItems;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    BOOL loading;
}

+ (KRNewsStore *)sharedStore;

- (void)removeItem:(KRNews *)news;

- (NSArray *)allItems;

- (void)addItem:(KRNews *)news;

- (NSString *)itemArchivePath;

- (BOOL)saveChanges;

- (void)loadAllItems;

- (int) unread;

- (int) maxNewsId;

- (int) minNewsId;

- (void) loadNews: (int)from to:(int)to max:(int)max appendToTop:(BOOL)appendToTop withHandler:(void (^)(NSArray *newsArray, NSError *error))handler;

@end
