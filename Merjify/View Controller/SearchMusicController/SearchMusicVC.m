//
//  SearchMusicVC.m
//  Mergify
//
//  Created by Abhishek Kumar on 07/12/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SearchMusicVC.h"
#import "SearchCell.h"
#import "UIImageView+WebCache.h"
#import "JSONKit.h"

@interface SearchMusicVC ()
{
    NSInteger selectedIndex;
    
    NSInteger selectedButtonTag;
    
    NSInteger lastSelectedType;
    
    NSArray *arr_TableData;
    
    NSArray *arr_Local;
    NSArray *arr_Spotify;
    NSArray *arr_Soundcloud;
    NSArray *arr_Deezer;
    
    //NSMutableArray *arr_iTunesSongsList;
}


@end

@implementation SearchMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.tableView setTableFooterView:[UIView new]];
    
    //arr_iTunesSongsList = [NSMutableArray array];
    
    //NSLog(@"self.searchedString = %@",self.searchedString);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiofySearchController:) name:@"notiofySearchController" object:nil];
    
    [self.tableView setTableFooterView:_tableFooterView];
}

- (void)notiofySearchController:(NSNotification *)obj {
    
    selectedIndex = -1;
    lastSelectedType = -1;
    selectedButtonTag = 1;
    
    arr_Local = @[];
    arr_Spotify = @[];
    arr_Soundcloud = @[];
    arr_Deezer = @[];
    
    [self resetSegment];
    
    _searchedString = obj.object;

    [self didFetchLocalSongs];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self didSearchSongFromSpotify];
    });
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self didSearchSongFromSoundcloud];
    });
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self didSearchSongFromDeezer];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return (NSInteger)arr_TableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    SearchCell *cell = (SearchCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (selectedIndex == indexPath.row && lastSelectedType == selectedButtonTag) {
        [cell.img_CellBG setImage:[UIImage imageNamed:@"cellBGRed"]];
        [cell.lbl_Title setTextColor:[UIColor whiteColor]];
        
    }else{
        [cell.img_CellBG setImage:[UIImage imageNamed:@"CellBG"]];
    }
    
    [cell.lbl_Counting setText:[NSString stringWithFormat:@"%ld.",(long)indexPath.row+1]];
    
    cell.btn_More.tag = indexPath.row;
    [cell.btn_More addTarget:self action:@selector(btn_Action_AddToPlayList:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.lbl_Title setText:[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"title"]];
    
    [cell.lbl_Username setText:[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"artistName"]];
    
    CGSize textSize = [[cell.lbl_Username text] sizeWithAttributes:@{NSFontAttributeName:[cell.lbl_Username font]}];
    CGFloat strikeWidth = textSize.width + cell.lbl_Username.frame.origin.x;
    if (strikeWidth < 200) {
        cell.con_accountImageLead.constant = strikeWidth - 70;
    }
    
    if ([[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_spotify.png"]];
        
    } else if ([[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_Itunes.png"]];
        
    } else if ([[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"Deezer_Icon"]];
        
    } else {
        
        [cell.img_AcountType setImage:[UIImage imageNamed:@"icon_soundcloud.png"]];
    }
    
    if ([[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        NSData *data = [[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"artistImage"]:nil;
        
        if (data) {
            [cell.img_Userprofile setImage:[CommonUtils convertDataintoImage:data]];
        } else {
            [cell.img_Userprofile setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        }

        
    } else {
        
        [cell.img_Userprofile sd_setImageWithURL:[NSURL URLWithString:[[arr_TableData objectAtIndex:indexPath.row] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (selectedButtonTag) {
        case 1:
            break;
        case 2:{
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyLogin"] isEqualToString:@"1"]) {
                
            } else {
                Displayalert(APPLICATION_NAME,@"Please login with Spotify in Accounts to play songs." , self,[NSArray arrayWithObject:@"OK"],1)
                return;
            }
        }
            break;
        case 3:{
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundcloudLogin"] isEqualToString:@"1"]) {
                
            } else {
                Displayalert(APPLICATION_NAME,@"Please login with Soundcloud in Accounts to play songs." , self,[NSArray arrayWithObject:@"OK"],1)
                return;
            }
        }
            break;
        case 4:{
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"deezerLogin"] isEqualToString:@"1"]) {
                
            } else {
                Displayalert(APPLICATION_NAME,@"Please login with Deezer in Accounts to play songs." , self,[NSArray arrayWithObject:@"OK"],1)
                return;
            }
        }
            break;
        default:
            return;
            break;
    }
    
    SearchCell *cell = (SearchCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.lbl_Title setTextColor:[UIColor whiteColor]];
    
    lastSelectedType = selectedButtonTag;
    selectedIndex = indexPath.row;
    
    if ([[SongPlayerController sharedInstance] soundcloud_player].isPlaying) {
        
        [[SongPlayerController sharedInstance] soundcloud_pause];
    }
    
    [[SongPlayerController sharedInstance] setIsPlayingAlbum:NO];
    [[SongPlayerController sharedInstance] setIsPlayingPlaylist:NO];
    [[SongPlayerController sharedInstance] setArr_songList:@[[arr_TableData objectAtIndex:indexPath.row]]];
    [[SongPlayerController sharedInstance] startPlayAudioWithIndex:0];
    
    [self.tableView reloadData];
    
}

#pragma mark - Cell Button Action

- (void)btn_Action_AddToPlayList:(UIButton*)sender {
    
    NSLog(@"%ld",(long)[sender tag]);
    
}

#pragma mark - IBAction

- (void)resetSegment {
    [_view_LocalBG setBackgroundColor:[UIColor clearColor]];
    [_view_SpotifyBG setBackgroundColor:[UIColor clearColor]];
    [_view_SoundcloudBG setBackgroundColor:[UIColor clearColor]];
    [_view_DeezerBG setBackgroundColor:[UIColor clearColor]];
    
    [_btn_Local setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btn_Spotify setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btn_Soundcloud setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btn_Deezer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)btn_Action:(id)sender {
    
    if (selectedButtonTag == [sender tag]) {
        return;
    }
    
    [self resetSegment];
    
    selectedButtonTag = [sender tag];
    
    switch ([sender tag]) {
        case 1:{
            [_view_LocalBG setBackgroundColor:[CommonUtils colorFromHexString:H_RED_COLOR]];
            [_btn_Local setTitleColor:[CommonUtils colorFromHexString:H_RED_COLOR] forState:UIControlStateNormal];
            
            arr_TableData = arr_Local;
            
            [self setTableFooter];
            
            [self.tableView reloadData];
            
        }
            break;
        case 2:{
            [_view_SpotifyBG setBackgroundColor:[CommonUtils colorFromHexString:H_RED_COLOR]];
            [_btn_Spotify setTitleColor:[CommonUtils colorFromHexString:H_RED_COLOR] forState:UIControlStateNormal];
            
            arr_TableData = arr_Spotify;
            
            [self setTableFooter];
            
            [self.tableView reloadData];
            
        }
            break;
        case 3:{
            [_view_SoundcloudBG setBackgroundColor:[CommonUtils colorFromHexString:H_RED_COLOR]];
            [_btn_Soundcloud setTitleColor:[CommonUtils colorFromHexString:H_RED_COLOR] forState:UIControlStateNormal];
            
            arr_TableData = arr_Soundcloud;
            
            [self setTableFooter];
            
            [self.tableView reloadData];
        }
            break;
        case 4:{
            [_view_DeezerBG setBackgroundColor:[CommonUtils colorFromHexString:H_RED_COLOR]];
            [_btn_Deezer setTitleColor:[CommonUtils colorFromHexString:H_RED_COLOR] forState:UIControlStateNormal];
            
            arr_TableData = arr_Deezer;
            
            [self setTableFooter];
            
            [self.tableView reloadData];
            
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - Local Search

- (void)didFetchLocalSongs {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[WebDataManager sharedInstance] startActivityIndicator];
        
    });
    
    NSArray *arr_LocalSongs = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", _searchedString];
    
    arr_Local = [arr_LocalSongs filteredArrayUsingPredicate:resultPredicate];
    
    arr_TableData = arr_Local;
    
    [self setTableFooter];
    
    [self.tableView reloadData];
    
    [_view_LocalBG setBackgroundColor:[CommonUtils colorFromHexString:H_RED_COLOR]];
    [_btn_Local setTitleColor:[CommonUtils colorFromHexString:H_RED_COLOR] forState:UIControlStateNormal];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[WebDataManager sharedInstance] startActivityIndicator];
        
    });
    
    
    /*
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
    */
}
/*
- (void)getiTunesLocalSong {
    
    if (_searchedString == nil) {
        return;
    }
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    
    for (MPMediaItem *song in itemsFromGenericQuery) {
        
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        
        NSString *songArtist = [song valueForProperty: MPMediaItemPropertyArtist];
        if ([songArtist isEqualToString:@""]) {
            songArtist = @"Unknown";
        }
        
        NSString *albumTitle = [song valueForProperty: MPMediaItemPropertyAlbumTitle];
        if ([albumTitle isEqualToString:@""]) {
            albumTitle = @"Unknown";
        }
        
        id songDuration = [song valueForProperty: MPMediaItemPropertyPlaybackDuration];
        
        UIImage *img = [[song valueForProperty: MPMediaItemPropertyArtwork] imageWithSize: CGSizeMake (120, 120)];
        NSData *imageData = UIImagePNGRepresentation(img);
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"iTunes" forKey:@"accountType"];
        [dic setValue:imageData!=nil?imageData:@"" forKey:@"artistImage"];
        [dic setValue:[songArtist isKindOfClass:[NSString class]]?songArtist:@"Unknown" forKey:@"artistName"];
        [dic setValue:[songDuration isKindOfClass:[NSNull class]]?@"":[NSString stringWithFormat:@"%@",songDuration] forKey:@"duration"];
        
        [dic setValue:@"" forKey:@"id"];
        
        [dic setValue:[songTitle isKindOfClass:[NSString class]]?songTitle:@"Unknown" forKey:@"title"];
        
        [dic setValue:@"" forKey:@"uri"];
        
        [dic setValue:[albumTitle isKindOfClass:[NSString class]]?albumTitle:@"Unknown" forKey:@"albumName"];
        
        [arr_iTunesSongsList addObject:dic];
        
    }
    
    if ([arr_iTunesSongsList count] > 0) {
        
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", _searchedString];
        
        searchResults = [arr_iTunesSongsList filteredArrayUsingPredicate:resultPredicate];
        
        [self.tableView reloadData];
        
        [_view_LocalBG setBackgroundColor:[CommonUtils colorFromHexString:H_RED_COLOR]];
        [_btn_Local setTitleColor:[CommonUtils colorFromHexString:H_RED_COLOR] forState:UIControlStateNormal];
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            searchResults = arr_iTunesSongsList;
            
            [self.tableView reloadData];
            [_view_LocalBG setBackgroundColor:[CommonUtils colorFromHexString:H_RED_COLOR]];
            [_btn_Local setTitleColor:[CommonUtils colorFromHexString:H_RED_COLOR] forState:UIControlStateNormal];
        });
    }
}
*/
#pragma mark - Spotify Search

- (void)didSearchSongFromSpotify {
    
    if (_searchedString == nil) {
        return;
    }
    
    if ([[[SongPlayerController sharedInstance] session] isValid]) {
                
        [self searchSong];
        
    } else {
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyRefreshTokenStr"] == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                arr_Spotify = @[];
                
                Displayalert(APPLICATION_NAME,@"Unable to fetch data from \"Spotify\". Please login." , self,[NSArray arrayWithObject:@"OK"],1)
            });
            
            return;
        }
        
        NSDictionary *params = @{@"refresh_token":[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyRefreshTokenStr"]};
        
        //NSLog(@"params ----- %@",params);
        
        [[WebDataManager sharedInstance] renewSession:params withBlock:^(NSDictionary *items, NSError *error)
         {
             NSLog(@"%@",items);
             
             if ([items isKindOfClass:[NSDictionary class]])
             {
                 
                 [[NSUserDefaults standardUserDefaults] setValue:[items objectForKey:@"access_token"] forKey:@"spotifySessionStr"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [self searchSong];
                 
             }
         }];
    }
    
}

- (void)searchSong {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[WebDataManager sharedInstance] startActivityIndicator];
        
    });
    
    NSMutableArray *arr_SpotifyList  = [NSMutableArray array];
    
    //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"]);
    
    [SPTSearch performSearchWithQuery:_searchedString queryType:SPTQueryTypeTrack accessToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"] callback:^(NSError *error, id object) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                arr_Spotify = arr_SpotifyList;
                
            });
            [[WebDataManager sharedInstance] stopActivityIndicator];
            
            Displayalert(APPLICATION_NAME,[error localizedDescription] , self,[NSArray arrayWithObject:@"OK"],1)
            
            return;
        }
        
        SPTListPage *list = (SPTListPage *)object;
        
        for (SPTPartialTrack *track in list.items) {
            
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
            [tempDic setValue:@"spotify" forKey:@"accountType"];
            
            [tempDic setValue:[NSString stringWithFormat:@"%@",track.uri] forKey:@"playlistURL"];
            
            //[tempDic setValue:object.snapshotId forKey:@"snapshotId"];
            
            [tempDic setValue:[NSString stringWithFormat:@"%@",[[track.album.covers objectAtIndex:2] imageURL]] forKey:@"artistImage"];
            
            SPTPartialArtist *artist = [track.artists objectAtIndex:0];
            // album name key is for Artist
            [tempDic setValue:artist.name forKey:@"artistName"];
            
            [tempDic setValue:track.album.name forKey:@"albumName"];
            
            [tempDic setValue:[NSString stringWithFormat:@"%@",[track.album.largestCover imageURL]] forKey:@"albumImage"];
            
            [tempDic setValue:track.name forKey:@"title"];
            [tempDic setValue:[NSString stringWithFormat:@"%f",track.duration] forKey:@"duration"];
            [tempDic setValue:track.identifier forKey:@"id"];
            [tempDic setValue:[NSString stringWithFormat:@"%@",track.playableUri] forKey:@"uri"];
            
            [arr_SpotifyList addObject:tempDic];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[WebDataManager sharedInstance] stopActivityIndicator];
            
            arr_Spotify = arr_SpotifyList;
            
        });
        
    }];
}

#pragma mark - Soundcloud Search

- (void)didSearchSongFromSoundcloud {
    
    if (_searchedString == nil) {
        return;
    }
    
    if(![[NSUserDefaults standardUserDefaults] valueForKey:SC_TOKEN])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            arr_Soundcloud = @[];
            
            Displayalert(APPLICATION_NAME,@"Unable to fetch data from \"Soundcloud\". Please login." , self,[NSArray arrayWithObject:@"OK"],1)
        });
        
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[WebDataManager sharedInstance] startActivityIndicator];
        
    });
    
    NSString *query = nil;
    
    if(_searchedString >0) {
        query = [_searchedString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
    
    NSString *jsonString =[NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/tracks.json?oauth_token=%@&client_id=%@&q=%@",SC_API_URL,[[NSUserDefaults standardUserDefaults] valueForKey:SC_TOKEN],CLIENT_ID,query]] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@",jsonString);
    
    NSMutableArray *musicArray = [jsonString objectFromJSONString];
    
    NSMutableArray *arr_SoundcloudList = [[NSMutableArray alloc]init];
    
    for(int i=0; i< musicArray.count;i++)
    {
        NSMutableDictionary *result = [musicArray objectAtIndex:i];
        if([[result objectForKey:@"kind" ] isEqualToString:@"track"])
        {
            
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
            
            [tempDic setValue:[result valueForKey:@"title"] forKey:@"title"];
            
            NSString *tempImageURL = [result valueForKey:@"artwork_url"];
            [tempDic setValue:[tempImageURL isKindOfClass:[NSString class]]?tempImageURL:@"" forKey:@"artistImage"];
            if (![[tempDic valueForKey:@"artistImage"] isEqualToString:@""]) {
                
                NSString *str = [result valueForKey:@"artwork_url"];
                
                str = [str stringByReplacingOccurrencesOfString:@"large.jpg" withString:@"t500x500.jpg"];
                [tempDic setValue:str forKey:@"artistImage"];
            }
            
            [tempDic setValue:@"soundcloud" forKey:@"accountType"];
            
            [tempDic setValue:[[result valueForKey:@"user"] valueForKey:@"username"] forKey:@"artistName"];
            
            [tempDic setValue:[result valueForKey:@"duration"] forKey:@"duration"];
            
            [tempDic setValue:[result valueForKey:@"id"] forKey:@"id"];
            
            [tempDic setValue:[result valueForKey:@"uri"] forKey:@"uri"];
            
            [arr_SoundcloudList addObject:tempDic];
            
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[WebDataManager sharedInstance] stopActivityIndicator];
        
        arr_Soundcloud = arr_SoundcloudList;
        
    });
    
}

#pragma mark - Deezer Search

- (void)didSearchSongFromDeezer {
    
    if (_searchedString == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[WebDataManager sharedInstance] startActivityIndicator];
        
    });
    
    
    NSMutableArray *arr_DeezerList  = [NSMutableArray array];
    
    [DZRObject searchFor:DZRSearchTypeTrack withQuery:_searchedString requestManager:[DZRRequestManager defaultManager] callback:^(DZRObjectList *results, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                arr_Deezer = arr_DeezerList;
                
            });
            [[WebDataManager sharedInstance] stopActivityIndicator];
            
            Displayalert(APPLICATION_NAME,[error localizedDescription] , self,[NSArray arrayWithObject:@"OK"],1)
            
            return;
        }
        
        [results allObjectsWithManager:[[DZRRequestManager defaultManager] subManager] callback:^(NSArray *objs, NSError *error) {
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    arr_Deezer = arr_DeezerList;
                    
                });
                [[WebDataManager sharedInstance] stopActivityIndicator];
                
                Displayalert(APPLICATION_NAME,[error localizedDescription] , self,[NSArray arrayWithObject:@"OK"],1)
                
                return;
            }
            
            NSInteger count = ([objs count]>20)?20:[objs count];
            
            for (int i = 0; i < count; i++) {
                
                NSDictionary *songDic = [objs objectAtIndex:i];
                
                NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                
                if (![[songDic valueForKey:@"stream"] isKindOfClass:[NSString class]] && ![[songDic valueForKey:@"readable"] boolValue]) {
                    
                } else {
                    
                    [tempDic setValue:@"deezer" forKey:@"accountType"];
                    
                    [tempDic setValue:[[songDic valueForKey:@"artist"] valueForKey:@"picture_medium"] forKey:@"artistImage"];
                    
                    [tempDic setValue:[[songDic valueForKey:@"artist"] valueForKey:@"name"] forKey:@"artistName"];
                    
                    [tempDic setValue:[[songDic valueForKey:@"album"] valueForKey:@"title"] forKey:@"albumName"];
                    
                    [tempDic setValue:[[songDic valueForKey:@"album"] valueForKey:@"cover_medium"] forKey:@"albumImage"];
                    
                    [tempDic setValue:[songDic valueForKey:@"title"] forKey:@"title"];
                    
                    [tempDic setValue:[NSString stringWithFormat:@"%@",[songDic valueForKey:@"duration"]] forKey:@"duration"];
                    
                    [tempDic setValue:[NSString stringWithFormat:@"%@",[songDic valueForKey:@"id"]] forKey:@"id"];
                    
                    [tempDic setValue:@"" forKey:@"uri"];
                    
                    [arr_DeezerList addObject:tempDic];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[WebDataManager sharedInstance] stopActivityIndicator];
                
                arr_Deezer = arr_DeezerList;
                
            });
        }];
    }];
    
}

#pragma mark - Private Methods

- (void)setTableFooter {
    
    if ((NSInteger)arr_TableData.count > 0) {
        
        [self.tableView setTableFooterView:nil];
    } else {
        
        [self.tableView setTableFooterView:_tableFooterView];
    }
    
}

@end
