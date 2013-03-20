//
//  KRSettingViewController.m
//  WenxueCityNews
//
//  Created by haihxiao on 3/20/13.
//  Copyright (c) 2013 Haihua Xiao. All rights reserved.
//

#import "KRSettingViewController.h"

#define PAGE_SIZE 40
#define OPETION_COUNT 5

@implementation KRSettingViewController

- (id)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        
        [n setTitle:NSLocalizedString(@"设置", @"appConfig")];
        
        numbOfItems = PAGE_SIZE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // self.clearsSelectionOnViewWillAppear = NO;
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAnimated:)];
    self.navigationItem.leftBarButtonItem = doneButton;
}

- (IBAction)dismissAnimated:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return OPETION_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    int index = [indexPath row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    int itemCount = (index+1) * PAGE_SIZE;
    [[cell textLabel] setText: [NSString stringWithFormat:@"离线存储 %d 条新闻", itemCount]];
    [cell setSelectionStyle: UITableViewCellSelectionStyleBlue];
    [cell setTag:itemCount];	
    if(itemCount == numbOfItems) {
        [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    int index = (numbOfItems / PAGE_SIZE) - 1;
    UITableViewCell* oldCell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:index inSection:0]];
    [oldCell setAccessoryType:UITableViewCellAccessoryNone];
    
    numbOfItems = [cell tag];
}

@end
