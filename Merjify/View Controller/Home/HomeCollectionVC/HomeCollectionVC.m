//
//  HomeCollectionVC.m
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "HomeCollectionVC.h"

#import "UIImageView+WebCache.h"

#import "SongsListVC.h"


@interface HomeCollectionVC ()<SearchTextViewDelegate>
{
    NSMutableArray *arr_Tracks;
    
    NSMutableArray *arr_Filterd;
    
    NSDictionary *playListData;
    
    NSArray *arr_Artist;
    NSArray *arr_Album;
    NSArray *arr_Playlist;
}

@end

@implementation HomeCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arr_Tracks = [NSMutableArray array];
    arr_Tracks = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.title isEqualToString:@"Artist"]) {
        
        [self parseDataForArtist];
        
    } else if ([self.title isEqualToString:@"Album"]) {
        
        [self parseDataForAlbum];
        
    } else if ([self.title isEqualToString:@"Playlist"]) {
        
        [self parseDataForPlaylist];
        
    } else {
        
        // Unknown
    }
}

- (void)parseDataForArtist {
    
    if ([arr_Artist count] > 0) {
        
        arr_Filterd = [arr_Artist mutableCopy];
        [self.collectionView reloadData];
        
        return;
    }
    
    NSMutableSet *keysSet = [[NSMutableSet alloc] init];
    arr_Filterd = [[NSMutableArray alloc]init];
    for (NSDictionary *msg in arr_Tracks) {
        NSString *key = [NSString stringWithFormat:@"%@", msg[@"artistName"]];
        if (![keysSet containsObject:key]) {
            [arr_Filterd addObject:msg];
            [keysSet addObject:key];
        }
    }
    
    arr_Artist = arr_Filterd;
    
    //NSLog(@"parseDataForArtist %@",arr_Filterd);
    
    [self.collectionView reloadData];
    
}

- (void)parseDataForAlbum {
    
    if ([arr_Album count] > 0) {
        
        arr_Filterd = [arr_Album mutableCopy];
        [self.collectionView reloadData];
        
        return;
    }
    
    NSMutableSet *keysSet = [[NSMutableSet alloc] init];
    arr_Filterd = [[NSMutableArray alloc]init];
    for (NSDictionary *msg in arr_Tracks) {
        
        if ([[msg valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
            
            NSString *key = [NSString stringWithFormat:@"%@", msg[@"artistName"]];
            if (![keysSet containsObject:key]) {
                [arr_Filterd addObject:msg];
                [keysSet addObject:key];
            }
            
        } else if ([[msg valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
            
            NSString *key = [NSString stringWithFormat:@"%@", msg[@"albumName"]];
            if (![keysSet containsObject:key]) {
                [arr_Filterd addObject:msg];
                [keysSet addObject:key];
            }
            
        } else {
            
            NSString *key = [NSString stringWithFormat:@"%@", msg[@"albumName"]];
            if (![keysSet containsObject:key]) {
                [arr_Filterd addObject:msg];
                [keysSet addObject:key];
            }
        }
    }
    
    arr_Album = arr_Filterd;
    
    //NSLog(@"parseDataForAlbum %@",arr_Filterd);
    
    [self.collectionView reloadData];
}

- (void)parseDataForPlaylist {
    
    NSLog(@"=--------------%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"]);
    
    if ([arr_Playlist count] > 0) {
        
        arr_Filterd = [arr_Playlist mutableCopy];
        [self.collectionView reloadData];
        
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"] != nil) {
        
        playListData = [[NSUserDefaults standardUserDefaults] valueForKey:@"Playlist"];
        
        arr_Playlist = arr_Filterd;
        
        NSLog(@"=--------------%@",playListData);
        
        [self.collectionView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([self.title isEqualToString:@"Playlist"]) {
        
        return [[playListData allKeys] count];
    }
    
    return [arr_Filterd count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *songsImageView = (UIImageView *)[cell viewWithTag:101];
    UILabel *songTitle = (UILabel *)[cell viewWithTag:102];
    
    if ([self.title isEqualToString:@"Artist"]) {
        
        [songsImageView sd_setImageWithURL:[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"artistImage"] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        
        songTitle.text = [NSString stringWithFormat:@"%@",[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"artistName"]];
        
    } else if ([self.title isEqualToString:@"Album"]) {
        
        if ([[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
            
            [songsImageView sd_setImageWithURL:[NSURL URLWithString:[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            
            songTitle.text = [NSString stringWithFormat:@"%@",[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"artistName"]];
            
        } else if ([[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
            
            NSData *data = [[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"artistImage"]:nil;
            
            if (data) {
                [songsImageView setImage:[CommonUtils convertDataintoImage:data]];
            } else {
                [songsImageView setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            }
            
//            [songsImageView sd_setImageWithURL:[NSURL URLWithString:[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            
            songTitle.text = [NSString stringWithFormat:@"%@",[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"albumName"]];
            
        } else {
            
            [songsImageView sd_setImageWithURL:[NSURL URLWithString:[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"albumImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
            
            songTitle.text = [NSString stringWithFormat:@"%@",[[arr_Filterd objectAtIndex:indexPath.row] valueForKey:@"albumName"]];
        }
        
    } else if ([self.title isEqualToString:@"Playlist"]) {
        
        songTitle.text = [NSString stringWithFormat:@"%@",[[playListData allKeys] objectAtIndex:indexPath.row]];
        
        if ([[playListData valueForKey:songTitle.text] count] > 0) {
            
            if ([[[[playListData valueForKey:songTitle.text] objectAtIndex:0] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
                
                [songsImageView sd_setImageWithURL:[NSURL URLWithString:[[[playListData valueForKey:songTitle.text] objectAtIndex:0] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
                
            } else if ([[[[playListData valueForKey:songTitle.text] objectAtIndex:0] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
                
                NSData *data = [[[[playListData valueForKey:songTitle.text] objectAtIndex:0] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[[playListData valueForKey:songTitle.text] objectAtIndex:0] valueForKey:@"artistImage"]:nil;
                
                if (data) {
                    [songsImageView setImage:[CommonUtils convertDataintoImage:data]];
                } else {
                    [songsImageView setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
                }
                
                //                [songsImageView sd_setImageWithURL:[NSURL URLWithString:[[[playListData valueForKey:songTitle.text] objectAtIndex:0] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
                
            } else {
                
                [songsImageView sd_setImageWithURL:[NSURL URLWithString:[[[playListData valueForKey:songTitle.text] objectAtIndex:0] valueForKey:@"albumImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
                
            }
        }
        
    } else {
        
        // Unknown
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SongsListVC *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SongsListVC"];
    
    if ([self.title isEqualToString:@"Playlist"]) {
        
        UICollectionViewCell *cell =[collectionView cellForItemAtIndexPath:indexPath];
        UILabel *songTitle = (UILabel *)[cell viewWithTag:102];
        
        viewController.arr_Tracks = [playListData valueForKey:songTitle.text];
        viewController.str_PlaylistTitle = songTitle.text;
        
        [[SongPlayerController sharedInstance] setPlaylistTitle:songTitle.text];
        
    } else {
        
        viewController.arr_Tracks = [self getAllSongsForIndex:indexPath.row];
        
    }
    
    [self presentViewController:viewController animated:YES completion:nil];
    
}

- (NSArray *)getAllSongsForIndex:(NSInteger)index {
    
    NSPredicate *p;
    
    if ([self.title isEqualToString:@"Artist"]) {
        
        p = [NSPredicate predicateWithFormat:@"SELF['artistName'] CONTAINS %@",[[arr_Filterd objectAtIndex:index] valueForKey:@"artistName"]];
        
    } else if ([self.title isEqualToString:@"Album"]) {
        
        if ([[[arr_Filterd objectAtIndex:index] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
            
            p = [NSPredicate predicateWithFormat:@"SELF['artistName'] CONTAINS %@",[[arr_Filterd objectAtIndex:index] valueForKey:@"artistName"]];
        } else {
            
            p = [NSPredicate predicateWithFormat:@"SELF['albumName'] CONTAINS %@",[[arr_Filterd objectAtIndex:index] valueForKey:@"albumName"]];
        }
        
    } else if ([self.title isEqualToString:@"Playlist"]) {
        
        
        
    } else {
        
        // Unknown
    }
    
    
    NSArray *res = [arr_Tracks filteredArrayUsingPredicate:p];
    
    return res;
}

@end
