//
//  KRNewsStore.m
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-13.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import "KRNewsStore.h"
#import "KRNews.h"
#import "Base64.h"
#import "AFJSONRequestOperation.h"

@implementation KRNewsStore

+ (KRNewsStore *)sharedStore
{
    static KRNewsStore *sharedStore = nil;
    if(!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if(self) {
        // Read in WenxueCityNews.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        // NSLog(@"model = %@", model);
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Where does the SQLite file go?
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
        
        [self loadAllItems];
    }
    return self;
}

- (void)loadAllItems
{
    if (!allItems) {
        keyedItems = [[NSMutableDictionary alloc] init];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"KRNews"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor
                                sortDescriptorWithKey:@"newsId"
                                ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            NSLog(@"Fetch failed: %@", [error localizedDescription]);
            allItems = [NSMutableArray arrayWithCapacity:50];
        } else {
            allItems = [[NSMutableArray alloc] initWithArray:result];           
        }
        for(id item in allItems) {
            NSString *key = [NSString stringWithFormat:@"%d", [item newsId]];
            [keyedItems setObject:item forKey: key];
        }
    }
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"news.data"];
}

- (void)saveItems:(int)itemCount
{
    int totalCount = [allItems count];
    
    if(totalCount > itemCount) {
        NSLog(@"Will remove: %d items", totalCount - itemCount);
       for(int i=totalCount - 1;i>=itemCount;i--) {
            KRNews *news = [allItems objectAtIndex:i];
            [self removeItem: news];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"storeUpdated" object:self];
    }
    
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
}

-(int) unread
{
    int r = 0;
    for (id news in allItems)
    {
        if(![news read]) r ++;
    }
    return r;
}

-(int) total
{
    return [allItems count];
}

-(int) maxNewsId
{
    int count = [allItems count];
    if(count > 0) return [[allItems objectAtIndex:0] newsId];
    return 0;
}

-(int) minNewsId
{
    int count = [allItems count];
    if(count > 0) return [[allItems objectAtIndex:(count-1)] newsId];
    return 0;
}

- (void)removeItem:(KRNews *)news
{
    [context deleteObject:news];
    [allItems removeObjectIdenticalTo:news];
}

- (void)addItem:(KRNews *)news
{
    [context insertObject:news];
    [allItems addObject:news];
}

- (void)insertItem:(KRNews *)news atIndex:(int)atIndex
{
    [context insertObject:news];
    [allItems insertObject:news atIndex:atIndex];
}

- (NSArray *)allItems
{
    return allItems;
}

- (KRNews *)nextItem:(NSInteger)newsId
{
    return nil;
}

- (KRNews *)prevItem:(NSInteger)newsId
{
    return nil;
}

- (KRNews *)itemAt:(NSInteger)index
{
    return [allItems objectAtIndex:index];
}


- (void) loadNews: (int)from to:(int)to max:(int)max appendToTop:(BOOL)appendToTop force:(BOOL)force withHandler:(void (^)(NSArray *newsArray, NSError *error))handler
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if(force == NO) {
        if(now - dateFetched < FETCH_INTERVAL) {
            return;
        }
    }
    if(loading) return;
    loading = YES;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString * url = [[NSString alloc] initWithFormat:BASE_URL_PATTERN, from, to, max];
    NSURL* targetUrl = [[NSURL alloc] initWithString: url];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetUrl];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *jsonNewsArray = [JSON mutableArrayValueForKey:@"newsList"];
        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity: [jsonNewsArray count]];
        NSLog(@"%d news fetched", [jsonNewsArray count]);
        int index = 0;
        for (id jsonNews in jsonNewsArray)
        {
            NSString *newsId = [jsonNews valueForKeyPath:@"id"];
            id oldKey = [keyedItems objectForKey:newsId];
            if(!oldKey) {
                KRNews *news = [NSEntityDescription insertNewObjectForEntityForName:@"KRNews"
                                                             inManagedObjectContext:context];
                NSString *title = [jsonNews valueForKeyPath:@"title"];
                NSString *content = [jsonNews valueForKeyPath:@"content"];
                NSString *dateCreated = [jsonNews valueForKeyPath:@"dateCreated"];

                [news setNewsId: [newsId intValue]];
                [news setTitle:[title base64DecodedString]];
                [news setContent:[content base64DecodedString]];
                [news setDateCreated:(NSTimeInterval)[dateCreated longLongValue] / 1000];
                [news setRead:NO];
                if(appendToTop == NO) {
                    [self addItem:news];
                } else {
                    [self insertItem:news atIndex:index ++];
                }
                [ret addObject:news];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        loading = NO;
        dateFetched = now;
        handler(ret, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        loading = NO;        
    }];
    
    [operation start];
}

@end