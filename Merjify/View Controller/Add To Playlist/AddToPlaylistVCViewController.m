//
//  AddToPlaylistVCViewController.m
//  Mergify
//
//  Created by Abhishek Kumar on 08/09/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "AddToPlaylistVCViewController.h"


@interface AddToPlaylistVCViewController ()

@end

@implementation AddToPlaylistVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return [[_playListData allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.textLabel.textAlignment  = NSTextAlignmentCenter;
    }
    
    cell.textLabel.text = [[_playListData allKeys] objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(selectedPlaylistTitle:)])
    {
        [self.delegate selectedPlaylistTitle:[[_playListData allKeys] objectAtIndex:indexPath.row]];
    }
    
}


- (IBAction)btn_Action_Cancel:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(cancelButtonTapped)])
    {
        [self.delegate cancelButtonTapped];
    }
    
}

- (IBAction)btn_Action_NewPlaylist:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(createNewPlaylistButtonTapped)])
    {
        [self.delegate createNewPlaylistButtonTapped];
    }
}


@end
