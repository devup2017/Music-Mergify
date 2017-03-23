//
//  SongPlayerController.m
//  Mergify
//
//  Created by mac on 22/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SongPlayerController.h"

@implementation SongPlayerController

static  SongPlayerController *sharedInstance = nil;

static dispatch_once_t onceToken;

+ (SongPlayerController *) sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SongPlayerController alloc] init];
    });
    
    return sharedInstance;
}

- (id)init;
{
    if (self = [super init])
    {
        _isFirstTime = YES;
        
        _iTunes_player = [MPMusicPlayerController applicationMusicPlayer];
        
        [self registerMediaPlayerNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesTrackChangedBeforEnd) name:@"iTunesTrackChangedBeforEnd" object:nil];
    }
    
    return self;
}

- (void)startPlayAudioWithIndex:(NSInteger )index {
    
    _currentPlayingTrackIndex = index;
    
    NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
    
    if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        [self spotify_pause];
        [self soundcloud_pause];
        [self iTunes_pause];
        [self deezer_pause];
        
        [self soundcloud_downloadDataAndPlaySong];
        
        if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
            [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:YES];
        }
        
        [THIS didUpdatingControlCenterPlayStatus:YES];

        
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        [self deezer_pause];
        [self soundcloud_pause];
        [self iTunes_pause];
        [_task cancel];
        
        [self spotify_playSong];
        
        if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
            [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:YES];
        }
        
        [THIS didUpdatingControlCenterPlayStatus:YES];

        
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        [self spotify_pause];
        [self soundcloud_pause];
        [self deezer_pause];
        
        [self iTunes_play];
        
        if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
            [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:YES];
        }
        
        [THIS didUpdatingControlCenterPlayStatus:YES];
        
        
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        [self spotify_pause];
        [self soundcloud_pause];
        [self iTunes_pause];
        [self deezer_pause];
        
        [self deezer_play];
        
        if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
            [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:YES];
        }
        
        [THIS didUpdatingControlCenterPlayStatus:YES];
        
        
    } else {
        
        //Unknown
    }
}

- (void)pauseSongWithIndex:(NSInteger )index {
    
    _currentPlayingTrackIndex = index;
    
    NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
    
    if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        [self soundcloud_pause];
        
        if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
            [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:NO];
        }
        
        [THIS didUpdatingControlCenterPlayStatus:NO];
        
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        [self spotify_pause];
        
        if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
            [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:NO];
        }
        
        [THIS didUpdatingControlCenterPlayStatus:NO];
        
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        [self iTunes_pause];
        
        if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
            [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:NO];
        }
        
        [THIS didUpdatingControlCenterPlayStatus:NO];
        
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        [self deezer_pause];
        
        if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
            [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:NO];
        }
        
        [THIS didUpdatingControlCenterPlayStatus:NO];
        
    } else {
        
        //Unknown
    }
    
}

- (void)playSongWithIndex:(NSInteger )index {
    
    _currentPlayingTrackIndex = index;
    
    NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
    
    if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        if (_soundcloud_player.currentTime == 0) {
            
            [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
            
        } else {
            
            [self soundcloud_play];
            
            if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
                [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
            }
            [THIS didUpdatingControlCenterPlayStatus:YES];

        }
        
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        if (_spotify_player.playbackState.position == 0) {
            
            [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
            
        } else {
            
            [self spotify_play];
            
            if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
                [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
            }
            
            [THIS didUpdatingControlCenterPlayStatus:YES];
        }
        
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        float time = [_iTunes_player currentPlaybackTime];
        
        //float time = CMTimeGetSeconds(currentTime);
        
        if (time == 0) {
            
            [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
            
        } else {
            
            [self iTunes_playIfPaused];
            
            if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
                [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
            }
            
            [THIS didUpdatingControlCenterPlayStatus:YES];
        }
    } else if ([[tempDic valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        if (_deezer_player.progress == 0) {
            
            [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
            
        } else {
            
            [self deezer_playIfPaused];
            
            if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
                [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
            }
            
            [THIS didUpdatingControlCenterPlayStatus:YES];
        }
        
    } else {
        
        //Unknown
    }
}

#pragma mark -----------------------------------------------
#pragma mark - Spotify Setup

- (void)loginUsingSession {
    
    if (self.spotify_player == nil) {
        
        NSError *error = nil;
        
        // Get the player instance
        self.spotify_player = [SPTAudioStreamingController sharedInstance];
        self.spotify_player.delegate = self;
        self.spotify_player.playbackDelegate = self;
        self.spotify_player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
        // Start the player (will start a thread)
        [self.spotify_player startWithClientId:S_CLIENT_ID error:&error];
        // Login SDK before we can start playback
        [self.spotify_player loginWithAccessToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"]];
    } else {
        
        [self spotify_playSong];
    }
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    
    [self spotify_playSong];
}

-(void)audioStreamingDidEncounterTemporaryConnectionError:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"************************************ audioStreamingDidEncounterTemporaryConnectionError");
}

-(void)audioStreamingDidDisconnect:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"************************************ audioStreamingDidDisconnect");
}

-(void)audioStreamingDidReconnect:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"************************************ audioStreamingDidReconnect");
}

#pragma mark - Handle Player

- (void)spotify_playSong {
    
    if (self.spotify_player != nil) {
        
        SPTAuth *auth = [SPTAuth defaultInstance];
        
        if ([auth.session isValid]) {
            // It's still valid, show the player.
            [self renewSession];
            return;
        }
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        
        NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
        
        //NSURL *url = [NSURL URLWithString:[tempDic valueForKey:@"uri"]];
        
        [self.spotify_player playSpotifyURI:[tempDic valueForKey:@"uri"] startingWithIndex:0 startingWithPosition:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"********** playSpotifyURI Error === %@",[error localizedDescription]);
            }
        }];
        
    } else {
        
        [self loginUsingSession];
        
    }
}

- (void)spotify_playPause {
    
    [self.spotify_player setIsPlaying:!self.spotify_player.playbackState.isPlaying callback:nil];
}

- (void)spotify_play {
    
    [self.spotify_player setIsPlaying:YES callback:nil];
}

- (void)spotify_pause {
    
    [self.spotify_player setIsPlaying:NO callback:nil];
}

- (BOOL)isSessionValid {
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@kSessionUserDefaultsKey] != nil) {
        
        id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:@kSessionUserDefaultsKey];
        self.session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
        
        if ([self.session isValid]) {
            
            return YES;
        } else {
            
            if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
                [self.delegate playerStoppedWithError];
            }
            
            [THIS didStopControlCenterPlayer];
            
            return NO;
        }
        
    }
    
    return NO;
    
}

#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri{
    
    NSLog(@"started to play track: %@", trackUri);
    
    if (_isPlayingiTunes) {
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        
        //[self performSelector:@selector(setSessionCategory) withObject:nil afterDelay:5.0f];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self setSessionCategory];
//        });
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            [self setSessionCategory];
            //[self performSelector:@selector(setSessionCategory) withObject:nil afterDelay:3.0f];
        });
        
        //[self performSelectorOnMainThread:@selector(setSessionCategory) withObject:nil waitUntilDone:YES];
        
    } else {
        if (self.arr_songList.count > 0)
        {
            NSLog(@"===========%@",self.arr_songList);
            [THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
        }else{

        }
        
    }
    
    
    if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
        
        [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
    }
    
    //[THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
    
    //[self performSelector:@selector(setControlCenter) withObject:nil afterDelay:10.0f];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri {
    
    NSLog(@"****************** spotify finished playing current song *******************");
    
    if (_currentPlayingTrackIndex == [_arr_songList count]-1) {
        [THIS didUpdatingControlCenterPlayStatus:NO];
        
        if ([self.delegate respondsToSelector:@selector(playListFinished)]) {
            [self.delegate playListFinished];
        }
        
        return;
    }
    
#warning suffle setup
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        _currentPlayingTrackIndex++;
        
    } else {
        
        _currentPlayingTrackIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_songList count]-1 andCurrentIndex:_currentPlayingTrackIndex];
    }
    
    [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
    
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    
    NSLog(@"failed to play track: %@", trackUri);
    
    if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
        [self.delegate playerStoppedWithError];
    }
    
    [THIS didStopControlCenterPlayer];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveError:(NSError *)error {
    
    NSLog(@"audioStreaming didReceiveError == %@",[error localizedDescription]);
    
    if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
        [self.delegate playerStoppedWithError];
    }
    
    [THIS didStopControlCenterPlayer];
    
    [self renewSession];
    
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Message from Spotify" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
}

- (void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    
    NSLog(@"*** audioStreamingDidLogout ");
    
    if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
        [self.delegate playerStoppedWithError];
    }
    
    [THIS didStopControlCenterPlayer];
    
    NSError *error = nil;
    if (![self.spotify_player stopWithError:&error]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error deinit" message:[error description] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    }
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didEncounterError:(NSError *)error {
    
    NSLog(@"*** Playback got error: %@", [error localizedDescription]);
    
    if (error != nil) {
        
        NSLog(@"*** Playback got error: %@", [error localizedDescription]);
        
        if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
            [self.delegate playerStoppedWithError];
        }
        
        [THIS didStopControlCenterPlayer];
        
        [self renewSession];
        
    }
}

#pragma mark - Webservices

- (void)renewSession {
    
    //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"]);
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyRefreshTokenStr"] == nil) {
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
             
             
             if (self.spotify_player == nil) {
                 
                 // Get the player instance
                 self.spotify_player = [SPTAudioStreamingController sharedInstance];
                 self.spotify_player.delegate = self;
                 self.spotify_player.playbackDelegate = self;
                 self.spotify_player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
                 
                 // Start the player (will start a thread)
                 [self.spotify_player startWithClientId:S_CLIENT_ID error:nil];
                 // Login SDK before we can start playback
                 [self.spotify_player loginWithAccessToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"]];
                 
             } else {
                 [self.spotify_player loginWithAccessToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"]];
             }
              
             //[self spotify_playSong];
             
              
             //[self.spotify_player loginWithAccessToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"]];
             
             
             NSLog(@"************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************* -------- Spotify session updated --------**************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************");
         }
         
     }];
}


/*
- (void)renewSession {
    
    id sessionData = nil;
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@kSessionUserDefaultsKey]) {
        
        sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:@kSessionUserDefaultsKey];
        
        NSLog(@"%@",[NSKeyedUnarchiver unarchiveObjectWithData:sessionData]);
        
        self.session = [NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
        
        [[SPTAuth defaultInstance] renewSession:self.session
                                       callback:^(NSError *error, SPTSession *session)
         {
             if (error == nil) {
                 
                 NSLog(@"*** Session renewed ***");
             } else {
                 
                 NSLog(@"*** renew Session got error: %@", [error localizedDescription]);
             }
         }];
        
    }
    
}
*/
#pragma mark -----------------------------------------------




#pragma mark -----------------------------------------------
#pragma mark - Soundcloud Setup


- (void)soundcloud_downloadDataAndPlaySong {
    
    NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/stream?client_id=%@", [tempDic valueForKey:@"uri"], CLIENT_ID];
    
    //NSString *urlString = [tempDic valueForKey:@"uri"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [_task cancel];
    
    if ([self.delegate respondsToSelector:@selector(updateViewForSelectedSongWithData:andPlayButtonStatus:)]) {
        [self.delegate updateViewForSelectedSongWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex] andPlayButtonStatus:YES];
    }
    
    _task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error == nil) {
            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
            [session setActive:YES error:nil];
            
            AVAudioPlayer *newAudioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
            
            [self.soundcloud_player stop];
            
            self.soundcloud_player = newAudioPlayer;
            
            [self.soundcloud_player setDelegate:self];
            [self.soundcloud_player prepareToPlay];
            [self.soundcloud_player setNumberOfLoops:0];
            [self.soundcloud_player play];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (_isPlayingiTunes) {
                    
                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
                    
                    [self performSelector:@selector(setSessionCategory) withObject:nil afterDelay:3.0f];
                    
                } else {
                    
                    [THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
                }
                
                if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
                    [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
                }
                
                
            });
            
        }
    }];
    
    [_task resume];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    NSLog(@"*******************audioPlayerDidFinishPlaying*******************");
    
    //NSLog(@"*******************_arr_songList******************* %@",_arr_songList);
    
    if (_currentPlayingTrackIndex == [_arr_songList count]-1) {
        [THIS didUpdatingControlCenterPlayStatus:NO];
        
        if ([self.delegate respondsToSelector:@selector(playListFinished)]) {
            [self.delegate playListFinished];
        }
        
        NSLog(@"******************* error *******************");
        
        return;
    }
    
#warning suffle setup
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        _currentPlayingTrackIndex++;
        
    } else {
        
        _currentPlayingTrackIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_songList count]-1 andCurrentIndex:_currentPlayingTrackIndex];
    }
    
    
    //_currentPlayingTrackIndex++;
    
    NSLog(@"******************* _currentPlayingTrackIndex ******************* %ld",_currentPlayingTrackIndex);
    
    [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    
    NSLog(@"*******************audioPlayerDecodeErrorDidOccur******************* error = %@",[error localizedDescription]);
    
    if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
        [self.delegate playerStoppedWithError];
    }
    [THIS didStopControlCenterPlayer];
}

- (void)soundcloud_play {
    
    [self.soundcloud_player play];
}

- (void)soundcloud_pause {
    
    [self.soundcloud_player pause];
}

- (void)cancelPreviousTask {
    
    [_task cancel];
    
}

- (BOOL)isPlayerPlayingSong {
    
    BOOL isPlayingPlayer;
    
    isPlayingPlayer = [self.soundcloud_player isPlaying];
    
    return isPlayingPlayer;
}

#pragma mark -----------------------------------------------

#pragma mark - iTunes

- (void)iTunes_play {
    
    SKCloudServiceController *controller = [SKCloudServiceController new];
    [controller requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {
        
        if (error != nil) {
            
            NSLog(@"Error getting SKCloudServiceController capabilities: %@", error);
            
        } else if (capabilities & SKCloudServiceCapabilityMusicCatalogPlayback) {
            // The user has an active subscription
            
            NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
            
            MPMediaPropertyPredicate *artistNamePredicate = [MPMediaPropertyPredicate predicateWithValue:[tempDic valueForKey:@"title"] forProperty: MPMediaItemPropertyTitle];
            
            MPMediaQuery *myArtistQuery = [MPMediaQuery albumsQuery];
            [myArtistQuery addFilterPredicate: artistNamePredicate];
            
            NSArray *songs = [myArtistQuery items];
            
            //NSArray *songs = [[MPMediaQuery songsQuery] items];
            //[songs objectAtIndex:_currentPlayingTrackIndex]
            
            NSLog(@"%lu",(unsigned long)[songs count]);
            
            [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
            AVAudioSession *session = [AVAudioSession sharedInstance];
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
            
            [session setActive:NO error:nil];
            //[[AVAudioSession sharedInstance] setCategory:nil error:nil];
        
            if (_iTunes_player == nil) {
                
                _iTunes_player.repeatMode = NO;
                _iTunes_player.shuffleMode = NO;
                
            }
            
            // assign a playback queue containing all media items on the device
            [_iTunes_player setQueueWithQuery:myArtistQuery];
            [_iTunes_player play];
            
            _isPlayingiTunes = YES;
            
            if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
                [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
            }
            
            [THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
            
        } else {
            // The user does *not* have an active subscription
            
            NSLog(@"The user does *not* have an active subscription");
            
        }
    }];
}

- (void)registerMediaPlayerNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self selector: @selector (handle_NowPlayingItemChanged:) name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification object: _iTunes_player];
    
    [notificationCenter addObserver: self selector: @selector (handle_PlaybackStateChanged:) name: MPMusicPlayerControllerPlaybackStateDidChangeNotification object: _iTunes_player];
    
    [_iTunes_player beginGeneratingPlaybackNotifications];
}

- (void)iTunes_playIfPaused {
    
    [_iTunes_player play];
}

- (void)iTunes_pause {
    
    [_iTunes_player pause];
}

- (void) handle_NowPlayingItemChanged: (NSNotification *) notification
{
    //[_iTunes_player endGeneratingPlaybackNotifications];
    
    NSLog(@"***************** notification.name = %@ ****************",notification.name);
    
    [self spotify_pause];
    [self soundcloud_pause];
    [self deezer_pause];
    
    //NSLog(@"-------------------- %f --------------------",_iTunes_player.currentPlaybackTime);
    //NSLog(@"-------------------- %f --------------------",_iTunes_player.currentPlaybackRate);
    
    float obj = _iTunes_player.currentPlaybackTime;
    
    if(_isFirstTime == NO){
        return;
    }
    
    NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
    
    if (isnan(obj) && _iTunes_player.currentPlaybackRate == 0 && [[tempDic valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        NSLog(@"-------------------------------************ NAN ************----------------------------------");
        
        if (_currentPlayingTrackIndex == [_arr_songList count]-1) {
            [THIS didUpdatingControlCenterPlayStatus:NO];
            
            if ([self.delegate respondsToSelector:@selector(playListFinished)]) {
                [self.delegate playListFinished];
            }
            
            return;
        }
        
#warning suffle setup
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
            
            _currentPlayingTrackIndex++;
            
        } else {
            
            _currentPlayingTrackIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_songList count]-1 andCurrentIndex:_currentPlayingTrackIndex];
        }
        
        [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
        
        
        _isFirstTime = NO;
        
        //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeValue) object:nil];
        
        [self performSelector:@selector(changeValue) withObject:nil afterDelay:3];
    }
}

- (void)changeValue {
    
    _isFirstTime = YES;
    
}

- (void)handle_PlaybackStateChanged: (NSNotification *) notification
{
    //NSLog(@"-------------------- %@ --------------------",notification.name);
    
    MPMusicPlaybackState playbackState = [_iTunes_player playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused) {
        
        NSLog(@"----------MPMusicPlaybackStatePaused---------- %f --------------------",_iTunes_player.currentPlaybackTime);
        NSLog(@"----------MPMusicPlaybackStatePaused---------- %f --------------------",_iTunes_player.currentPlaybackRate);
        
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        
        NSLog(@"---------MPMusicPlaybackStatePlaying----------- %f --------------------",_iTunes_player.currentPlaybackTime);
        NSLog(@"---------MPMusicPlaybackStatePlaying----------- %f --------------------",_iTunes_player.currentPlaybackRate);
        
    } else if (playbackState == MPMusicPlaybackStateSeekingForward) {
        
        NSLog(@"---------MPMusicPlaybackStateSeekingForward----------- %f --------------------",_iTunes_player.currentPlaybackTime);
        NSLog(@"---------MPMusicPlaybackStateSeekingForward----------- %f --------------------",_iTunes_player.currentPlaybackRate);
        
    } else if (playbackState == MPMusicPlaybackStateSeekingBackward) {
        
        NSLog(@"---------MPMusicPlaybackStateSeekingBackward----------- %f --------------------",_iTunes_player.currentPlaybackTime);
        NSLog(@"---------MPMusicPlaybackStateSeekingBackward----------- %f --------------------",_iTunes_player.currentPlaybackRate);
        
    } else if (playbackState == MPMusicPlaybackStateStopped) {
        
        NSLog(@"---------MPMusicPlaybackStateStopped----------- ");
        
        [_iTunes_player stop];
        
    } else if (playbackState == MPMusicPlaybackStateInterrupted) {
        
        //[_iTunes_player endGeneratingPlaybackNotifications];
        
        if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
            [self.delegate playerStoppedWithError];
        }
        
        [THIS didStopControlCenterPlayer];
        
    } else {
        
    }
}

- (void)iTunesTrackChangedBeforEnd {
    
    if (_iTunes_player == nil) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
        [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
    }
    
    [THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
}

#pragma mark -----------------------------------------------

#pragma mark - Deezer

- (void)checkConnection
{
    [[DeezerSession sharedSession] setConnectionDelegate:self];
}

- (void)deezerLogin {
    
    _isDeezerLoginTapped = YES;
    
    [self checkConnection];
    
    NSMutableArray* permissionsArray = [NSMutableArray array];
    [permissionsArray addObject:DeezerConnectPermissionBasicAccess];
    [[DeezerSession sharedSession] connectToDeezerWithPermissions:permissionsArray];
}

#pragma mark - DeezerItemConnectionDelegate

- (void)deezerSessionDidConnect {
    
    if (_isDeezerLoginTapped) {
        [self performSelector:@selector(setIsLoggedIn:) withObject:@YES afterDelay:0.3];
    } else {
        [self deezer_play];
    }
    
}

- (void)deezerSessionDidFailConnectionWithError:(NSError*)error {
    
    NSLog(@"error Deezer connection = %@",[error localizedDescription]);
    
}

- (void)deezerSessionDidDisconnect {
    [self setIsLoggedIn:NO];
}

- (void)setIsLoggedIn:(BOOL)isLoggedIn {
    
//    NSLog(@"Token : %@",[[[DeezerSession sharedSession] deezerConnect] accessToken]);
//    NSLog(@"Expiration Date : %@",[[[DeezerSession sharedSession] deezerConnect] expirationDate]);
    
    [self showUser];
}

- (void)stopHUD {
    
    [[WebDataManager sharedInstance] stopActivityIndicator];
    
}

- (void)showUser {
    
    [[WebDataManager sharedInstance] startActivityIndicator];
    
    [self performSelector:@selector(stopHUD) withObject:nil afterDelay:2.0];
    
    [DZRUser objectWithIdentifier:@"me" requestManager:[DZRRequestManager defaultManager] callback:^(DZRObject *obj, NSError *error) {
        
        if (error == nil) {
            
            [self performSelectorOnMainThread:@selector(fetchPlaylistMethod:) withObject:obj waitUntilDone:YES];
            
        } else {
            
            //NSString *str = [NSString stringWithFormat:@"error in fetching user detail = %@",[error localizedDescription]];
            
            //Displayalert(APPLICATION_NAME, str, _controller,[NSArray arrayWithObject:@"OK"],1)
            
            NSLog(@"error in fetching user detail = %@",[error localizedDescription]);
        }
    }];
}

- (void)fetchPlaylistMethod:(DZRObject *)object {
    
    //NSLog(@"supportedMethodKeys = %@",object.supportedMethodKeys);
    
    // Check if "playlists" is in supported methods...
    
    if ([object.supportedMethodKeys containsObject:@"playlists"]) {
        
        [object valueForKey:@"playlists" withRequestManager:[DZRRequestManager defaultManager] callback:^(id value, NSError *error) {
            
            if (error) {
                
                NSString *str = [NSString stringWithFormat:@"error in fetching playlist method = %@",[error localizedDescription]];
                
                NSLog(@"%@",str);
                
            } else if ([value isKindOfClass:[DZRObjectList class]]) {
                
                [self performSelectorOnMainThread:@selector(fetchPlaylists:) withObject:value waitUntilDone:YES];
                
            }
            else {
                
            }
        }];
        
    } else {
        
        //Displayalert(APPLICATION_NAME, @"Playlists is not in supported method", _controller,[NSArray arrayWithObject:@"OK"],1)
        
        NSLog(@"Playlists is not in supported method");
        
    }
}

- (void)fetchPlaylists:(DZRObjectList *)list {

    [list allObjectsWithManager:[DZRRequestManager defaultManager] callback:^(NSArray *objs, NSError *error) {
        
        [self performSelectorOnMainThread:@selector(fetchTracksMethod:) withObject:objs waitUntilDone:YES];
        
    }];
}


- (void)fetchTracksMethod:(NSArray *)arrPlaylists {
    self.playlistDict = [[NSMutableDictionary alloc]init];
    _arr_DeezerList  = [NSMutableArray array];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("com.netforce.Merjify.queue", DISPATCH_QUEUE_SERIAL);
    
    for (int i = 0; i<[arrPlaylists count]; i++) {
        
        dispatch_sync(serialQueue, ^{
            
            DZRObject *object = [arrPlaylists objectAtIndex:i];
            self.playlistTitle = [object valueForKey:@"title"];
            if ([object.supportedMethodKeys containsObject:@"tracks"]) {
                
                dispatch_sync( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [object valueForKey:@"tracks" withRequestManager:[DZRRequestManager defaultManager] callback:^(id value, NSError *error) {
                        
                        if (error) {
                            
                            NSString *str = [NSString stringWithFormat:@"error in fetching tracks method = %@",[error localizedDescription]];
                            
                            //Displayalert(APPLICATION_NAME, str, _controller,[NSArray arrayWithObject:@"OK"],1)
                            
                            NSLog(@"%@",str);
                            
                        } else if ([value isKindOfClass:[DZRObjectList class]] && [object isPlayable]) {
                            
                            //self.playable = (id<DZRPlayable>)object;
                            NSLog(@"====deezer value : %@",value);
                            
                            dispatch_sync( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                self.playlistTitle = [object valueForKey:@"title"];
                                [self performSelectorOnMainThread:@selector(fetchTracksOfAPlaylist:) withObject:value waitUntilDone:YES];
                                
                                //NSLog(@"-------------------------- loop count -------------- %d ------------",i);
                                
                                if (i == [arrPlaylists count]-1) {
                                    
                                    NSLog(@"************************************* all songs fetched");
                                    //NSLog(@"songs count playlist : %lu",(unsigned long)[_arr_DeezerList count]);
                                    
                                    [[WebDataManager sharedInstance] stopActivityIndicator];
                                    
                                    [self performSelectorOnMainThread:@selector(updateData) withObject:nil waitUntilDone:YES];
                                }
                            });
                        }
                        else {
                            
                        }
                    }];
                });
                
            } else {
                
                NSLog(@"Tracks is not in supported method");
                
                //Displayalert(APPLICATION_NAME, @"Tracks is not in supported method", _controller,[NSArray arrayWithObject:@"OK"],1)
            }
        });
    }
}

- (void)fetchTracksOfAPlaylist:(DZRObjectList *)list {

    NSMutableArray *tempPlaylistsArr = [[NSMutableArray array] init];
    [list allObjectsWithManager:[DZRRequestManager defaultManager] callback:^(NSArray *objs, NSError *error) {
        
        if (error) {
            
            NSString *str = [NSString stringWithFormat:@"error in fetching tracks of a playlist = %@",[error localizedDescription]];
            
            //Displayalert(APPLICATION_NAME, str, _controller,[NSArray arrayWithObject:@"OK"],1)
            
            NSLog(@"%@",str);
            
        }  else {
            
            //NSLog(@"%@",objs);
            
            
            for (int i = 0; i < [objs count]; i++) {
                
                NSLog(@"=====objs: %@", [objs objectAtIndex:i]);
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
                    
                    [tempDic setValue:[songDic valueForKey:@"duration"] forKey:@"duration"];
                    
                    [tempDic setValue:[songDic valueForKey:@"id"] forKey:@"id"];
                    
                    [tempDic setValue:@"" forKey:@"uri"];
                    
                    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.playable];
                    
                    //[[NSUserDefaults standardUserDefaults] saveCustomObject:self.playable key:@"playable"];
                    
                    //[tempDic setValue:data forKey:@"playable"];
                    
                    [_arr_DeezerList addObject:tempDic];
                    [tempPlaylistsArr addObject:tempDic];
                    
                }
                
            }
        }
    }];

    if(self.playlistTitle.length > 0){
        [self.playlistDict setObject:tempPlaylistsArr forKey:self.playlistTitle];
        NSLog(@"=====playlistDict%@",self.playlistDict);
    }
}

- (void)updateData {
    
    if ([_arr_DeezerList count] > 0) {
        
        [[NSUserDefaults standardUserDefaults] setValue:_arr_DeezerList forKey:@"deezerSongList"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"deezerLogin"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deezerLoggedIn" object:nil];
        
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [_arr_DeezerList sortedArrayUsingDescriptors:sortDescriptors];
        
        [_arr_DeezerList removeAllObjects];
        [_arr_DeezerList addObjectsFromArray:sortedArray];
        
        [[NSUserDefaults standardUserDefaults] setValue:_arr_DeezerList forKey:@"tracks"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setValue:_arr_DeezerList forKey:@"deezerTracks"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.playlistDict forKey:@"Playlist"];
        
    }
}

#pragma mark --------------------------------------------------------------
// fetch playable for playlist....

- (void)deezer_play {
    
    [self.trackRequest cancel];
    [self.deezer_player pause];
    
    _deezer_player = [[DZRPlayer alloc] initWithConnection:[DeezerSession sharedSession].deezerConnect];
    _deezer_player.delegate = self;
    _deezer_player.shouldUpdateNowPlayingInfo = YES;
    
    NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
    
    NSLog(@"tempDic = %@",tempDic);
    
    self.trackRequest = [DZRTrack objectWithIdentifier:[tempDic valueForKey:@"id"] requestManager:[DZRRequestManager defaultManager] callback:^(DZRTrack *track, NSError *error) {
        
        if (error == nil) {
            
            [_deezer_player play:track];
            
        } else {
            
            _isDeezerLoginTapped = NO;
            
            NSLog(@"error in playing deezer track : %@",[error localizedDescription]);
            
            [self checkConnection];
            
            NSMutableArray* permissionsArray = [NSMutableArray array];
            [permissionsArray addObject:DeezerConnectPermissionBasicAccess];
            [[DeezerSession sharedSession] connectToDeezerWithPermissions:permissionsArray];
        }
    }];
}

- (void)deezer_playIfPaused {
    [_deezer_player play];
}

- (void)deezer_pause {
    [_deezer_player pause];
}

#pragma mark DZRPlayerDelegate

- (void)player:(DZRPlayer *)player didEncounterError:(NSError *)error
{
    NSLog(@"error player = %@",[error localizedDescription]);
    
    if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
        [self.delegate playerStoppedWithError];
    }
    
    [THIS didStopControlCenterPlayer];
}

- (void)player:(DZRPlayer *)player didPlay:(long long)playedBytes outOf:(long long)totalBytes
{
    float progress = (double)playedBytes / (double)totalBytes;
    
    //NSLog(@"progress didPlay = %f",progress);
    
    _deezerProgress = progress;
    
}

- (void)player:(DZRPlayer *)player didStartPlayingTrack:(DZRTrack *)track
{
    NSLog(@"didStartPlayingTrack ****** DEEZER");
    
    if (track == nil && _deezer_player.progress == 0) {
        
        if (_currentPlayingTrackIndex == [_arr_songList count]-1) {
            [THIS didUpdatingControlCenterPlayStatus:NO];
            
            if ([self.delegate respondsToSelector:@selector(playListFinished)]) {
                [self.delegate playListFinished];
            }
            
            NSLog(@"******************* error *******************");
            
            return;
        }
        
#warning suffle setup
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
            
            _currentPlayingTrackIndex++;
            
        } else {
            
            _currentPlayingTrackIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_songList count]-1 andCurrentIndex:_currentPlayingTrackIndex];
        }
        
        
        //_currentPlayingTrackIndex++;
        
        NSLog(@"******************* _currentPlayingTrackIndex ******************* %ld",_currentPlayingTrackIndex);
        
        [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
        
    } else {
        
        if (_isPlayingiTunes) {
            
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
            
            [self performSelector:@selector(setSessionCategory) withObject:nil afterDelay:3.0f];
            
        } else {
            
            [THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
        }
        
        if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
            [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
        }
    }
}

#pragma mark - Set Session

- (void)setSessionCategory {
    
    _isPlayingiTunes = NO;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:nil error:nil];
    [session setActive:YES error:nil];
    
    [THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
}

/*
- (void)iTunes_play {
    
    NSDictionary *tempDic = [self.arr_songList objectAtIndex:_currentPlayingTrackIndex];
    
    NSURL *url = [NSURL URLWithString:[tempDic valueForKey:@"uri"]];
    
    if ([[tempDic valueForKey:@"uri"] isKindOfClass:[NSString class]] && ([[tempDic valueForKey:@"uri"] length]==0 || [[tempDic valueForKey:@"uri"] isEqualToString:@""])) {
        return;
    }
    
    NSError *sessionError = nil;
    //[[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    AVAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    //Get the track object from the asset object - we'll need to trackID to tell the
    //AVPlayer that it needs to modify the volume of this track
    AVAssetTrack* track = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    //Build the AVPlayerItem - this is where you modify the volume, etc. Not the AVPlayer itself
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithAsset: asset]; //initWithURL:url];
    //self.currentItem = playerItem;
    
    
    //Set up some audio mix parameters to tell the AVPlayer what to do with this AVPlayerItem
    AVMutableAudioMixInputParameters* audioParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat volume = audioSession.outputVolume;
    
    [audioParams setVolume:volume atTime:kCMTimeZero];  //replace 0.5 with your volume
    [audioParams setTrackID: track.trackID];  //here's the track id
    
    //Set up the actual AVAudioMix object, which aggregates effects
    AVMutableAudioMix* audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters: [NSArray arrayWithObject: audioParams]];
    
    //apply your AVAudioMix object to the AVPlayerItem
    [playerItem setAudioMix:audioMix];
    
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesPlayerStoppedWithError:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesPlayerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesPlayerStoppedWithError:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesPlayerStoppedWithError:) name:AVPlayerItemNewErrorLogEntryNotification object:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesPlayerStoppedWithError:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:playerItem];
    
    //refresh the AVPlayer object, and play the track
    
    _iTunes_player = [[AVPlayer alloc] init];
    
    [_iTunes_player replaceCurrentItemWithPlayerItem: playerItem];
    [_iTunes_player play];
    
    if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
        [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
    }
    
    [THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
}

- (void)iTunes_playIfPaused {
    
    [_iTunes_player play];
}

- (void)iTunes_pause {
    
    [_iTunes_player pause];
}

- (void)iTunesTrackChangedBeforEnd {
    
    if (_iTunes_player == nil) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerStartPlayingTrackWithData:)]) {
        [self.delegate playerStartPlayingTrackWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
    }
    
    [THIS didUpdateControlSetupWithData:[self.arr_songList objectAtIndex:_currentPlayingTrackIndex]];
}

- (void)iTunesPlayerDidFinishPlaying:(NSNotification *) notification {
    
    NSLog(@"***************** %@ ****************",notification.name);
    
    if (_currentPlayingTrackIndex == [_arr_songList count]-1) {
        [THIS didUpdatingControlCenterPlayStatus:NO];
        
        if ([self.delegate respondsToSelector:@selector(playListFinished)]) {
            [self.delegate playListFinished];
        }
        
        return;
    }
    
#warning suffle setup
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        _currentPlayingTrackIndex++;
        
    } else {
        
        _currentPlayingTrackIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_songList count]-1 andCurrentIndex:_currentPlayingTrackIndex];
    }
    
    [self startPlayAudioWithIndex:_currentPlayingTrackIndex];
}

- (void)iTunesPlayerStoppedWithError:(NSNotification *) notification {
    
    NSLog(@"***************** %@ ****************",notification.name);
    
    if ([self.delegate respondsToSelector:@selector(playerStoppedWithError)]) {
        [self.delegate playerStoppedWithError];
    }
    
    [THIS didStopControlCenterPlayer];
}
*/
@end

