//
//  KRAppDelegate.h
//  WenxueCityNews
//
//  Created by Haihua Xiao on 13-3-9.
//  Copyright (c) 2013年 Haihua Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_COLOR [UIColor colorWithRed:75/255.0f  green:101/255.0f  blue:157/255.0f alpha:1.0f]

@class KRNewsListController;

@interface KRAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>
{
    UINavigationController *navigationController;
    KRNewsListController *listController;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
