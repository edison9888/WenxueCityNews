//
//  KRAppDelegate.h
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-9.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
