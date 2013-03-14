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
        NSLog(@"model = %@", model);
        
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
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        allItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                        NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"news.data"];
}

- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
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

- (NSArray *)allItems
{
    return allItems;
}

- (void) loadNews: (int)from to:(int)to max:(int)max withHandler:(void (^)(NSArray *retrievedData, NSError *error))handler
{
    NSString * url = [[NSString alloc] initWithFormat:@"http://wenxuecity.cloudfoundry.com/news/mobilelist?from=%d&to=%d&max=%d", from, to, max];
    NSURL* targetUrl = [[NSURL alloc] initWithString: url];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetUrl];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *jsonNewsArray = [JSON mutableArrayValueForKey:@"newsList"];
        NSLog(@"%d news fetched", [jsonNewsArray count]);
        for (id jsonNews in jsonNewsArray)
        {
            NSString *newsId = [jsonNews valueForKeyPath:@"id"];
            NSString *title = [jsonNews valueForKeyPath:@"title"];
            NSString *content = [jsonNews valueForKeyPath:@"content"];
            
            KRNews *news = [NSEntityDescription insertNewObjectForEntityForName:@"KRNews"
                                                      inManagedObjectContext:context];
            [news setNewsId: [newsId intValue]];
            [news setTitle:[title base64DecodedString]];
            [news setContent:[content base64DecodedString]];
            [self addItem:news];
        }
    } failure:nil];
    
    [operation start];
}

@end