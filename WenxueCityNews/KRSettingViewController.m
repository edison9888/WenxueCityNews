//
//  KRSettingViewController.m
//  WenxueCityNews
//
//  Created by haihxiao on 3/20/13.
//  Copyright (c) 2013 Haihua Xiao. All rights reserved.
//

#import "KRSettingViewController.h"
#import "KRConfigStore.h"
#import "KRAppDelegate.h"

@implementation KRSettingViewController

- (id)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        
        [n setTitle:NSLocalizedString(@"设置", @"appConfig")];
        
        numbOfItems = [[[KRConfigStore sharedStore] pageSize] intValue];
        fontSize = [[[KRConfigStore sharedStore] fontSize] intValue];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = YES;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAnimated:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem.tintColor = APP_COLOR;
}

- (IBAction)dismissAnimated:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0: return KR_OPTION_COUNT;
        case 1: return KR_FONT_COUNT;
        default: return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    static NSString *CellIdentifier2 = @"UITableViewCell2";
    
    int section = [indexPath section];
    int index = [indexPath row];

    if(section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier];
        }
        int itemCount = (index+1) * KR_PAGE_SIZE;
        [[cell textLabel] setText: [NSString stringWithFormat:@"%d 条新闻", itemCount]];
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell setTag:itemCount];
        if(itemCount == numbOfItems) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
        }
        return cell;
    } else if(section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier];
        }
        [[cell textLabel] setText: [[KRConfigStore sharedStore] sizeName: index]];
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell setTag:index];
       if(index == fontSize) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
        }
       return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (!cell) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:CellIdentifier2];
        }
        [[cell textLabel] setText: @"版本"];
        [[cell detailTextLabel] setText: @"1.0.0"];
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        return cell;        
    }
}


#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0: return @"缓存数目";
        case 1: return @"字体大小";
        default: return @"关于";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if(section > 1) return;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    switch(section)
    {
        case 0:
        {
            int index = (numbOfItems / KR_PAGE_SIZE) - 1;
            UITableViewCell* oldCell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:index inSection:section]];
            [oldCell setAccessoryType:UITableViewCellAccessoryNone];
            
            numbOfItems = [cell tag];            
            [[KRConfigStore sharedStore] setPageSize: [NSNumber numberWithInt:numbOfItems]];
            break;
        }
        case 1:
        {
            int index = fontSize;
            UITableViewCell* oldCell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:index inSection:section]];
            [oldCell setAccessoryType:UITableViewCellAccessoryNone];
            
            fontSize = [cell tag];
            [[KRConfigStore sharedStore] setFontSize: [NSNumber numberWithInt:fontSize]];
            break;
            
        }
    }
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];        
}

@end
