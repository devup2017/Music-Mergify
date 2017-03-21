//
//  AccountsVC.m
//  Merjify
//
//  Created by Abhishek Kumar on 18/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "AccountsVC.h"
#import "AccountsCell.h"
#import <MediaPlayer/MediaPlayer.h>

#import <MessageUI/MessageUI.h>

@import StoreKit;

@interface AccountsVC ()<UIWebViewDelegate,MFMailComposeViewControllerDelegate>
{
    NSArray *tableData;
    
    NSMutableArray *arr_ConnectivityStatus;
    
    NSMutableArray *arr_iTunesSongsList;
    
    NSString *productID;
}
@end

//NSString *xtCookie;
//UIWebView *webView;
//int runCount = 0;
//NSMutableArray *mSongArr;
//NSString *passw;

@implementation AccountsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Accounts";
    
    productID = @"12345678";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(soundcloudLoggedIn) name:@"soundcloudLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyLoggedIn) name:@"spotifyLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deezerLoggedIn) name:@"deezerLoggedIn" object:nil];
    
    tableData = @[@"AccountsYouTube",@"AccountsSoundCloud",@"AccountsSpotify",@"AccountsItunes"];
    arr_ConnectivityStatus = [NSMutableArray arrayWithObjects:@"No",@"No",@"No",@"No", nil];
    
    self.soundCloud =[[SoundCloud alloc] init];
    
    self.spotifyController =[[SpotifyController alloc] init];
    
    [self.tableView setTableFooterView:[UIView new]];
    
    arr_iTunesSongsList = [NSMutableArray array];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] isEqualToString:@"1"]) {
        [arr_ConnectivityStatus replaceObjectAtIndex:0 withObject:@"Yes"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] isEqualToString:@"1"]) {
        [arr_ConnectivityStatus replaceObjectAtIndex:1 withObject:@"Yes"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] isEqualToString:@"1"]) {
        
        [arr_ConnectivityStatus replaceObjectAtIndex:2 withObject:@"Yes"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] count] > 0) {
        
        [arr_ConnectivityStatus replaceObjectAtIndex:3 withObject:@"Yes"];
    }
    
}

- (void)deezerLoggedIn {
    
    [arr_ConnectivityStatus replaceObjectAtIndex:0 withObject:@"Yes"];
    
    [self.tableView reloadData];
    
}

- (void)soundcloudLoggedIn {
        
    [arr_ConnectivityStatus replaceObjectAtIndex:1 withObject:@"Yes"];
    
    [self.tableView reloadData];
    
}

- (void)spotifyLoggedIn {
    
    [arr_ConnectivityStatus replaceObjectAtIndex:2 withObject:@"Yes"];
    
    [self.tableView reloadData];
    
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
    
    return tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    
    AccountsCell *cell = (AccountsCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AccountsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.img_CellBG setImage:[UIImage imageNamed:[tableData objectAtIndex:indexPath.row]]];
    
    if ([[arr_ConnectivityStatus objectAtIndex:indexPath.row] isEqualToString:@"Yes"]) {
        
        [cell.btn_LoginStatus setImage:[UIImage imageNamed:@"AccountsSelectred"] forState:UIControlStateNormal];
    } else {
        
        [cell.btn_LoginStatus setImage:[UIImage imageNamed:@"AccountsUnselected"] forState:UIControlStateNormal];
    }
    
    [cell.btn_LoginStatus setTag:indexPath.row];
    [cell.btn_LoginStatus addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    /*
    if ([self.soundCloud login] && indexPath.row==1) {
        
        [cell.btn_LoginStatus setImage:[UIImage imageNamed:@"AccountsSelectred"] forState:UIControlStateNormal];
        
    }
    */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
            
        case 0:{
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] isEqualToString:@"1"]) {
                
                [[SongPlayerController sharedInstance] deezer_pause];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"deezerTracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"deezerLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [arr_ConnectivityStatus replaceObjectAtIndex:0 withObject:@"No"];
                
                NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                NSArray *array2 =
                [array filteredArrayUsingPredicate:
                 [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
                    return ![[obj valueForKey:@"accountType"] isEqual:@"deezer"];
                }]];
                
                [[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"tracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[SongPlayerController sharedInstance] setArr_songList:array2];
                
            } else {
                
                [[SongPlayerController sharedInstance] deezerLogin];
            }
        }
            break;
        case 1:{
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] isEqualToString:@"1"]) {
                
                [[SongPlayerController sharedInstance] soundcloud_pause];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"soundcloudTracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"soundcloudLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [arr_ConnectivityStatus replaceObjectAtIndex:1 withObject:@"No"];
                
                
                NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                NSArray *array2 =
                [array filteredArrayUsingPredicate:
                 [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
                    return ![[obj valueForKey:@"accountType"] isEqual:@"soundcloud"];
                }]];
            
                [[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"tracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[SongPlayerController sharedInstance] setArr_songList:array2];
                
            } else {
                [self.soundCloud login];
                
            }
            
            
            //NSLog(@"%d",[self.soundCloud login]);
        }
            break;
        case 2:{
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] isEqualToString:@"1"]) {
                
                [[SongPlayerController sharedInstance] spotify_pause];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spotifyLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spotifySongList"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [arr_ConnectivityStatus replaceObjectAtIndex:2 withObject:@"No"];
                
                NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                NSArray *array2 =
                [array filteredArrayUsingPredicate:
                 [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
                    return ![[obj valueForKey:@"accountType"] isEqual:@"spotify"];
                }]];
                
                [[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"tracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[SongPlayerController sharedInstance] setArr_songList:array2];
                
            } else {
                
                //[[WebDataManager sharedInstance] startActivityIndicator];
                [_spotifyController logIn];
            }
        }
            break;
        case 3:{
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] != nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] count] > 0) {
                
                [[SongPlayerController sharedInstance] iTunes_pause];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"iTunesTracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                NSArray *array2 =
                [array filteredArrayUsingPredicate:
                 [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
                    return ![[obj valueForKey:@"accountType"] isEqual:@"iTunes"];
                }]];
                
                [[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"tracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[SongPlayerController sharedInstance] setArr_songList:array2];
                
                [arr_ConnectivityStatus replaceObjectAtIndex:3 withObject:@"No"];
                
            } else {
                
                [self didFetchLibrarySongs];
            }
            
            
        }
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (void)loginButtonTapped:(id)sender {
    
    switch ([sender tag]) {
        case 0:{
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] isEqualToString:@"1"]) {
                
                [[SongPlayerController sharedInstance] deezer_pause];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"deezerTracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"deezerLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [arr_ConnectivityStatus replaceObjectAtIndex:0 withObject:@"No"];
                
                NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                NSArray *array2 =
                [array filteredArrayUsingPredicate:
                 [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
                    return ![[obj valueForKey:@"accountType"] isEqual:@"deezer"];
                }]];
                
                [[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"tracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[SongPlayerController sharedInstance] setArr_songList:array2];
                
            } else {
                
                [[SongPlayerController sharedInstance] deezerLogin];
            }
        }
            break;
        case 1:{
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] isEqualToString:@"1"]) {
                
                [[SongPlayerController sharedInstance] soundcloud_pause];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"soundcloudTracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"soundcloudLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [arr_ConnectivityStatus replaceObjectAtIndex:1 withObject:@"No"];
                
                
                NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                NSArray *array2 =
                [array filteredArrayUsingPredicate:
                 [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
                    return ![[obj valueForKey:@"accountType"] isEqual:@"soundcloud"];
                }]];
                
                [[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"tracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            } else {
                [self.soundCloud login];
            }
        }
            break;
        case 2:{
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] isEqualToString:@"1"]) {
                
                [[SongPlayerController sharedInstance] spotify_pause];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spotifyLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spotifySongList"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [arr_ConnectivityStatus replaceObjectAtIndex:2 withObject:@"No"];
                
                NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                NSArray *array2 =
                [array filteredArrayUsingPredicate:
                 [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
                    return ![[obj valueForKey:@"accountType"] isEqual:@"spotify"];
                }]];
                
                [[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"tracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            } else {
                [_spotifyController logIn];
            }
        }
            break;
        case 3:{
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] != nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"iTunesTracks"] count] > 0) {
                
                [[SongPlayerController sharedInstance] iTunes_pause];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"iTunesTracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
                NSArray *array2 =
                [array filteredArrayUsingPredicate:
                 [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
                    return ![[obj valueForKey:@"accountType"] isEqual:@"iTunes"];
                }]];
                
                [[NSUserDefaults standardUserDefaults] setValue:array2 forKey:@"tracks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[SongPlayerController sharedInstance] setArr_songList:array2];
                
                [arr_ConnectivityStatus replaceObjectAtIndex:3 withObject:@"No"];
                
            } else {
                
                [self didFetchLibrarySongs];
            }
        }
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}


#pragma mark - iTunes Integration

- (void)didFetchLibrarySongs {
    
    [arr_iTunesSongsList removeAllObjects];
    
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
        switch (status) {
            case MPMediaLibraryAuthorizationStatusNotDetermined: {
                // not determined
                
                Displayalert(APPLICATION_NAME,@"Unable to fetch songs from device.", self,[NSArray arrayWithObject:@"OK"],1)
                
                break;
            }
            case MPMediaLibraryAuthorizationStatusRestricted: {
                // restricted
                
                Displayalert(APPLICATION_NAME,@"Unable to fetch songs from device.", self,[NSArray arrayWithObject:@"OK"],1)
                
                break;
            }
            case MPMediaLibraryAuthorizationStatusDenied: {
                // denied
                
                Displayalert(APPLICATION_NAME,@"Unable to fetch songs from device. Please enble from device's settings", self,[NSArray arrayWithObject:@"OK"],1)
                
                break;
            }
            case MPMediaLibraryAuthorizationStatusAuthorized: {
                // authorized
                
                [self performSelectorOnMainThread:@selector(getiTunesLocalSong) withObject:nil waitUntilDone:YES];
                
                break;
            }
            default: {
                break;
            }
        }
    }];
}

//- (NSString *)countryCodeWithIdentifier:(NSString *)identifier {
//    NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"CountryCodes" withExtension:@"plist"];
//    NSDictionary *countryCodeDictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
//    
//    return countryCodeDictionary[identifier];
//}

- (void)getiTunesLocalSong {
    
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    NSArray *playlists = [myPlaylistsQuery collections];
    
    for (MPMediaPlaylist *playlist in playlists) {
        //NSLog (@"%@", [playlist valueForProperty: MPMediaPlaylistPropertyName]);
        
        if (![[playlist valueForProperty: MPMediaPlaylistPropertyName] isEqualToString:@"Recently Added"]) {
            
            NSArray *songs = [playlist items];
            
            for (MPMediaItem *song in songs) {
                
                //NSURL *songURL = [song valueForProperty: MPMediaItemPropertyAssetURL];
                //NSLog (@" **************************************songURL %@", songURL);
                
                //if (songURL == nil) {
                //NSLog(@"url is nil");
                //}
                
                NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
                //NSLog (@" ************************************** %@", songTitle);
                
                NSString *songArtist = [song valueForProperty: MPMediaItemPropertyArtist];
                if ([songArtist isEqualToString:@""]) {
                    songArtist = @"Unknown";
                }
                //NSLog (@" ************************************** %@", songArtist);
                
                NSString *albumTitle = [song valueForProperty: MPMediaItemPropertyAlbumTitle];
                if ([albumTitle isEqualToString:@""]) {
                    albumTitle = @"Unknown";
                }
                //NSLog (@" ************************************** %@", albumTitle);
                
                id songDuration = [song valueForProperty: MPMediaItemPropertyPlaybackDuration];
                //NSLog (@" ************************************** %@", songDuration);
                
                //            NSString *songImage = [song valueForProperty: MPMediaItemPropertyArtwork];
                //            NSLog (@" ************************************** %@", songImage);
                
                UIImage *img = [[song valueForProperty: MPMediaItemPropertyArtwork] imageWithSize: CGSizeMake (120, 120)];
                NSData *imageData = UIImagePNGRepresentation(img);
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:@"iTunes" forKey:@"accountType"];
                [dic setValue:imageData!=nil?imageData:@"" forKey:@"artistImage"];
                [dic setValue:[songArtist isKindOfClass:[NSString class]]?songArtist:@"Unknown" forKey:@"artistName"];
                [dic setValue:[songDuration isKindOfClass:[NSNull class]]?@"":[NSString stringWithFormat:@"%@",songDuration] forKey:@"duration"];
                
                [dic setValue:@"" forKey:@"id"];
                
                [dic setValue:[songTitle isKindOfClass:[NSString class]]?songTitle:@"Unknown" forKey:@"title"];
                
                //[songURL.absoluteString isKindOfClass:[NSString class]]?songURL.absoluteString:@""
                [dic setValue:@"" forKey:@"uri"];
                
                [dic setValue:[albumTitle isKindOfClass:[NSString class]]?albumTitle:@"Unknown" forKey:@"albumName"];
                
                [arr_iTunesSongsList addObject:dic];
                
            }
        }
    }
    
    if (arr_iTunesSongsList && arr_iTunesSongsList.count>0) {
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        
        //});
        
        [arr_ConnectivityStatus replaceObjectAtIndex:3 withObject:@"Yes"];
        
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [arr_iTunesSongsList sortedArrayUsingDescriptors:sortDescriptors];
        
        [arr_iTunesSongsList removeAllObjects];
        [arr_iTunesSongsList addObjectsFromArray:sortedArray];
        
        [[NSUserDefaults standardUserDefaults] setValue:arr_iTunesSongsList forKey:@"tracks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setValue:arr_iTunesSongsList forKey:@"iTunesTracks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] isEqualToString:@"1"]) {
            
            [arr_iTunesSongsList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySongList"]];
            
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            NSArray *sortedArray = [arr_iTunesSongsList sortedArrayUsingDescriptors:sortDescriptors];
            
            [arr_iTunesSongsList removeAllObjects];
            [arr_iTunesSongsList addObjectsFromArray:sortedArray];
            
            [[NSUserDefaults standardUserDefaults] setValue:arr_iTunesSongsList forKey:@"tracks"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"] != nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"] count] > 0) {
            
            [arr_iTunesSongsList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudTracks"]];
            
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            NSArray *sortedArray = [arr_iTunesSongsList sortedArrayUsingDescriptors:sortDescriptors];
            
            [arr_iTunesSongsList removeAllObjects];
            [arr_iTunesSongsList addObjectsFromArray:sortedArray];
            
            [[NSUserDefaults standardUserDefaults] setValue:arr_iTunesSongsList forKey:@"tracks"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
         
        [self.tableView reloadData];
    } else {
        
        Displayalert(APPLICATION_NAME, @"No local songs found", self,[NSArray arrayWithObject:@"OK"],1)
        
    }
}


/*
 
 // Fetch songs list from Music library...
 
 MPMediaQuery *everything = [[MPMediaQuery alloc] init];
 //[everything addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
 
 NSArray *itemsFromGenericQuery = [everything items];
 
 //NSMutableArray *arr_SongList = [NSMutableArray array];
 
 for (MPMediaItem *song in itemsFromGenericQuery) {
 
 if (song.mediaType == MPMediaTypeMusic) {
 
 }
 }
 */

/*
 
 [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
 
 MPMediaQuery *mySongsQuery = [MPMediaQuery songsQuery];
 NSArray *songs = [mySongsQuery items];
 
 for (MPMediaItem *song in songs) {
 
 NSString *songTitle =
 [song valueForProperty: MPMediaItemPropertyTitle];
 NSLog (@" ******************** songTitle ****************** %@", songTitle);
 
 NSURL *songURL = [song valueForProperty: MPMediaItemPropertyAssetURL];
 NSLog (@" ********************* songURL ***************** %@", songURL);
 
 }
 
 }];
 
 return;
 
 [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
 SKCloudServiceController *cloudServiceController = [[SKCloudServiceController alloc] init];
 [cloudServiceController requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {
 
 NSLog(@"%lu",(unsigned long)capabilities);
 
 }];
 }];
 
 return;
 


//    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
//
////        CFUUIDRef udid = CFUUIDCreate(NULL);
////        NSString *udidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
//
//        //[[NSUUID UUID] UUIDString]
//
//
//         {
//         dateCreated = "2016-11-21 10:40:50 +0000";
//         descriptionInfo = "<null>";
//         externalVendorContainerTag = "470AFDB7-E945-4CE0-8017-D65199A29C35";
//         externalVendorDisplayName = Mergify;
//         externalVendorIdentifier = "";
//         name = "Recently Added";
//         playlistPersistentID = 15943417676809507682;
//         }
//
//
//
//
//        NSUUID *uuid = [NSUUID UUID];
//
//        [[MPMediaLibrary defaultMediaLibrary] getPlaylistWithUUID:uuid creationMetadata:[[MPMediaPlaylistCreationMetadata alloc] initWithName:@"Recently Added"] completionHandler:^(MPMediaPlaylist * _Nullable playlist, NSError * _Nullable error) {
//
//            NSLog(@"%@",playlist);
//
//        }];
//
//    }];
//
//
//    return;
 
*/



/*
- (void)didFetchCloudSongs:(NSString *)songID {
 
    NSLog(@"submitAppleMusic has been called for productID: %@", songID);
 
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        NSLog(@"status is %ld", (long)status);
        SKCloudServiceController *cloudServiceController;
        cloudServiceController = [[SKCloudServiceController alloc] init];
        [cloudServiceController requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {
            NSLog(@"%lu %@", (unsigned long)capabilities, error);
            
            if (capabilities >= SKCloudServiceCapabilityAddToCloudMusicLibrary)
            {
                NSLog(@"You CAN add to iCloud!");
                [[MPMediaLibrary defaultMediaLibrary] addItemWithProductID:songID completionHandler:^(NSArray<__kindof MPMediaEntity *> * _Nonnull           entities, NSError * _Nullable error)
                 {
                     NSLog(@"added id%@ entities: %@ and error is %@", songID, entities, error);
                     NSArray *tracksToPlay = [NSArray arrayWithObject:songID];
                     [[MPMusicPlayerController systemMusicPlayer] setQueueWithStoreIDs:tracksToPlay];
                     [[MPMusicPlayerController systemMusicPlayer] play];
                     
                     [self performSelectorOnMainThread:@selector(getInfoFromAddedAppleMusicTrack:) withObject:songID waitUntilDone:YES];
                 }];
            }
            else
            {
                NSLog(@"Blast! The ability to add Apple Music track is not there. sigh.");
            }
        }];
    }];
}

-(void) getInfoFromAddedAppleMusicTrack: (NSString *) ID
{
    NSLog(@"FYI - musicplayer duration is: %f", [[[MPMusicPlayerController systemMusicPlayer] nowPlayingItem] playbackDuration]);
    //need to check for both the nowPlaying item and if there is a reported playbackDuration, as there is a variable time between a storeMediaItema and a concreteMediaItem
    if (([[MPMusicPlayerController systemMusicPlayer] nowPlayingItem]) && ([[[MPMusicPlayerController systemMusicPlayer] nowPlayingItem] playbackDuration]))
    {
        NSLog(@"Media item is playing: %@",[[MPMusicPlayerController systemMusicPlayer] nowPlayingItem]);
        NSLog(@"appleProductIDURL: %@",ID);
        NSLog(@"Ending time: %d",[[[[MPMusicPlayerController systemMusicPlayer] nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue]);
        NSLog(@"Track Name: %@", [[[MPMusicPlayerController systemMusicPlayer] nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle]);
        NSLog(@"Artists Name: %@", [[[MPMusicPlayerController systemMusicPlayer] nowPlayingItem] valueForProperty:MPMediaItemPropertyArtist]);
        
    }
    else
    {
        NSLog(@"seems the track is not fully loaded so try again in 1 second");
        
        [self performSelector:@selector(getInfoFromAddedAppleMusicTrack:) withObject:ID afterDelay:1.0];
        
        // count loops and jump out if something is wrong - I've never seen more that 7 seconds needed
    }
}
*/

/*
- (void)hitAPIWithData:(NSArray *)arr {
    
    //NSError *err = nil;
    //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&err];
    //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *params1 = @{@"iTunesData":@"werwerwgryfsajkfgas js jhfkgaskf sfhj gsafgsh fhjsg fhkgas kfgsjf gjhsfjkhgsjhfkag skjhgf jsdgf jhksdg fjksdgfhfj gsdgf jhksgd fjkhgsdhdfj gsdjkgf jhdsgfhjg sddfg hjsdkgf hjksdgfhjkgsd gfahjkgas f hjkadfs jhkgads dfgk hjaksgf jhagds fjhewhjrwterywetyrtyuwetryuwteuyrqtrteuyi"};
    
    NSDictionary *params = @{@"opt":@"qwe", @"name":@"123", @"asdasdasdasd":params1};
    
    NSString *str = @"qwe";
    
    [[WebDataManager sharedInstance] executeWebServiceWithFunction:@"" andParamater:str withViewController:self withBlock:^(NSDictionary *items, NSError *error) {
        NSLog(@"%@",items);
    }];
    
//    [[WebDataManager sharedInstance] executePOSTWebServiceWithParamater:params withFunctionName:@"" withViewController:self withBlock:^(NSDictionary *items, NSError *error) {
//        
//        NSLog(@"%@",items);
//        
//    }];
    
}
*/

 
@end
