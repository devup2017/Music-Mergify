//
//  AppDelegate.m
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "AppDelegate.h"

#import <MediaPlayer/MediaPlayer.h>

#import "Reachability.h"

#import "ViewController.h"
#import "SideMenuVC.h"
#import "SearchMusicVC.h"
#import "HomeVC.h"

#if DEBUG

@import Firebase;

@interface AppDelegate ()

@end

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end

#endif

@interface AppDelegate ()

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.viewController];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:NAVIGATION_BAR_COLOR];
    
    // set status bar background color...
    [CommonUtils setStatusBarBackgroundColor:NAVIGATION_BAR_COLOR];
    
    // set navigation bar title color...
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:FONT_NAME size:16.0f]}];
    
    // Use Firebase library to configure APIs
    [FIRApp configure];
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-1409082372034038~9509683509"];
    
    // set status bar light content...
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    /*
    [MPRemoteCommandCenter sharedCommandCenter].playCommand.enabled = YES;
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTarget:self action:@selector(remotePlay)];
    
    [MPRemoteCommandCenter sharedCommandCenter].pauseCommand.enabled = YES;
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTarget:self action:@selector(remoteStop)];
    
    [MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand.enabled = YES;
    [[MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand addTarget:self action:@selector(loadPreviousSong)];
    
    [MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand.enabled = YES;
    [[MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand addTarget:self action:@selector(loadNextSong)];
    */
     
    /*
    MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    remoteCommandCenter.previousTrackCommand.enabled = YES;
    remoteCommandCenter.nextTrackCommand.enabled = YES;
    remoteCommandCenter.playCommand.enabled = YES;
    remoteCommandCenter.pauseCommand.enabled = YES;
    
    
    [remoteCommandCenter.previousTrackCommand addTarget:self action:@selector(actionDoNothing:)];
    [remoteCommandCenter.nextTrackCommand addTarget:self action:@selector(actionDoNothing:)];
    [remoteCommandCenter.playCommand addTarget:self action:@selector(actionDoNothing:)];
    [remoteCommandCenter.pauseCommand addTarget:self action:@selector(actionDoNothing:)];
    */
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:nil error:nil];
    
    [self didReceiveRemoteNotification];
    
    //[self configureAudioSession];
    
    
    // Sound cloud setup...
    self.soundCloud =[[SoundCloud alloc] init];
    
    // Reachability setup..
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSString *remoteHostName = @"www.apple.com";
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    
    return YES;
}

- (void)didReceiveRemoteNotification {
    
    // Control center setup...
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
}
/*
-(void) actionDoNothing:(id)sender {
    NSLog(@"actionDoNothing ----------------");
}

-(void) remotePlay {
    
}
-(void) remoteStop {
    
}
-(void) loadNextSong {
    
}
-(void) loadPreviousSong {
    
}
*/
#pragma mark - Navigation Controller

- (UIViewController *)viewController {
    
    if (_viewController != nil) {
        return _viewController;
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] == nil) {
        
        ViewController *loginController = (ViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
        
        _viewController=navigationController;
        
        return _viewController;
    }
    
    _sidePanelController = [[JASidePanelController alloc] init];
    _sidePanelController.shouldDelegateAutorotateToVisiblePanel = NO;
    _sidePanelController.rightFixedWidth = 260;
    
    //Left Panel
    SideMenuVC *sideMenuController = (SideMenuVC*)[mainStoryboard instantiateViewControllerWithIdentifier:@"SideMenuVC"];
    [_sidePanelController setLeftPanel:sideMenuController];
    
    //Center Panel
    HomeVC *homeController = (HomeVC*)[mainStoryboard instantiateViewControllerWithIdentifier:@"HomeVC"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
    [_sidePanelController setCenterPanel:navigationController];
    
    //Right Panel
    SearchMusicVC *searchController = (SearchMusicVC*)[mainStoryboard instantiateViewControllerWithIdentifier:@"SearchMusicVC"];
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchController];
    [_sidePanelController setRightPanel:searchNavigationController];
    
    _viewController=_sidePanelController;
    
    return _viewController;
}

- (void)updateApplicationState {
    
    [self setViewController:nil];
    [self.window setRootViewController:[self viewController]];
}

static AppDelegate *temp;
+(AppDelegate *)classinstance
{
    if (temp == nil)
    {
        temp = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    return temp;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [self.window endEditing:YES];
    
    /*
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    */
     
    
    UIBackgroundTaskIdentifier bgTask1 = 0;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask1 = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask1];
    }];
    
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SC_TOKEN];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [self.window endEditing:YES];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
- (void)configureAudioSession
{
    //This will make the audio played even if the sound of the device is on mute.
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}
*/

#pragma mark - ---------------
#pragma mark - Soundcloud

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if (!url) {
        return NO;
    }
    
    if( [url.absoluteString rangeOfString:REDIRECT_URI].location!=NSNotFound)
    {
        [self checkForSoundCloudLogin:url.absoluteString];
        //do your other custom url handling here
        
    } else {
        
        // Spotify setup.....
        
        [[WebDataManager sharedInstance] startActivityIndicator];
        
        SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
            // This is the callback that'll be triggered when auth is completed (or fails).
            if (error != nil) {
                
                [[WebDataManager sharedInstance] stopActivityIndicator];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Authentication Failed" message:[NSString stringWithFormat:@"%@\n\n Are you sure your token swap service is set up correctly?", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
                
                return;
            }
            
            _storeSpotifySession = session;
            
            NSData *spotifySession = [NSKeyedArchiver archivedDataWithRootObject:session];
            [[NSUserDefaults standardUserDefaults] setObject:spotifySession forKey:@kSessionUserDefaultsKey];
            
            [self performTestCallWithSession:session];
        };
        
        if ([[SPTAuth defaultInstance] canHandleURL:url]) {
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
            return YES;
        }
        
    }
    
    return YES;
    
}
/*
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url) {
        return NO;
    }
    
    if( [url.absoluteString rangeOfString:REDIRECT_URI].location!=NSNotFound)
    {
        [self checkForSoundCloudLogin:url.absoluteString];
        //do your other custom url handling here
        
    } else {
        
        // Spotify setup.....
        
        SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
            // This is the callback that'll be triggered when auth is completed (or fails).
            if (error != nil) {
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" message:[NSString stringWithFormat:@"%@\n\n Are you sure your token swap service is set up correctly?", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [view show];
                return;
            }
            
            _storeSpotifySession = session;
            
            NSData *spotifySession = [NSKeyedArchiver archivedDataWithRootObject:session];
            [[NSUserDefaults standardUserDefaults] setObject:spotifySession forKey:@kSessionUserDefaultsKey];
            
            [self performTestCallWithSession:session];
        };
        
        if ([[SPTAuth defaultInstance] canHandleURL:url]) {
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
            return YES;
        }
        
    }
    
    return YES;
}
*/
- (void)checkForSoundCloudLogin :(NSString *) url
{
    if( [url rangeOfString:REDIRECT_URI].location!=NSNotFound)
    {
        //NSLog(@"Found oauth");
        //NSArray *tokenArray =[url componentsSeparatedByString:@"token"];
        NSArray *codeArray =[url componentsSeparatedByString:@"code="];
        //NSLog(@"If logging in does not work, please look for this log message and check if the code is being stored correctly");
        
        if(codeArray.count>1) {
            NSString *code = codeArray[1];
            if([code hasSuffix:@"#"])code = [code substringToIndex:code.length-1];
            //NSLog(@"Found login code for SoundCloud");
            [[NSUserDefaults standardUserDefaults] setObject:code forKey:SC_CODE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.soundCloud login];
            
            
//            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"soundcloudLogin"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"soundcloudLoggedIn" object:nil];
        }
    }
}

#pragma mark - ---------------


#pragma mark - ---------------
#pragma mark - Spotify

- (void)performTestCallWithSession:(SPTSession *)session {
    
    NSMutableArray *arr_SpotifyList  = [NSMutableArray array];
    
    [SPTPlaylistList playlistsForUser:session.canonicalUsername withAccessToken:session.accessToken callback:^(NSError *error, id object) {
        
        if (error == nil) {
            
            NSLog(@"%@",session.accessToken);
            
            [[NSUserDefaults standardUserDefaults] setValue:session.accessToken forKey:@"spotifySessionStr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setValue:session.encryptedRefreshToken forKey:@"spotifyRefreshTokenStr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setValue:session.canonicalUsername forKey:@"spotifyUserName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            SPTPlaylistList *playlistAlbum = (SPTPlaylistList *)object;
            NSLog(@"===========spotify%@",playlistAlbum.items);
            for (int i = 0; i < playlistAlbum.items.count; i++) {
                
                SPTPartialPlaylist *partialPlaylist = [playlistAlbum.items objectAtIndex:i];
                
                [SPTPlaylistSnapshot playlistWithURI:partialPlaylist.uri accessToken:session.accessToken callback:^(NSError *error, SPTPlaylistSnapshot *object) {
                    
                    for (int j = 0; j < [object.firstTrackPage tracksForPlayback].count; j++) {
                        
                        SPTPlaylistTrack *playlist = [[object.firstTrackPage tracksForPlayback] objectAtIndex:j];
                        
                        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                        [tempDic setValue:@"spotify" forKey:@"accountType"];
                        
                        [tempDic setValue:[NSString stringWithFormat:@"%@",partialPlaylist.uri] forKey:@"playlistURL"];
                        
                        [tempDic setValue:object.snapshotId forKey:@"snapshotId"];
                        
                        [tempDic setValue:[NSString stringWithFormat:@"%@",[[playlist.album.covers objectAtIndex:2] imageURL]] forKey:@"artistImage"];
                        
                        SPTPartialArtist *artist = [playlist.artists objectAtIndex:0];
                        // album name key is for Artist
                        [tempDic setValue:artist.name forKey:@"artistName"];
                        
                        [tempDic setValue:playlist.album.name forKey:@"albumName"];
                        
                        [tempDic setValue:[NSString stringWithFormat:@"%@",[playlist.album.largestCover imageURL]] forKey:@"albumImage"];
                        
                        [tempDic setValue:playlist.name forKey:@"title"];
                        [tempDic setValue:[NSString stringWithFormat:@"%f",playlist.duration] forKey:@"duration"];
                        [tempDic setValue:playlist.identifier forKey:@"id"];
                        [tempDic setValue:[NSString stringWithFormat:@"%@",playlist.playableUri] forKey:@"uri"];
                        
                        [arr_SpotifyList addObject:tempDic];
                        
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setValue:arr_SpotifyList forKey:@"spotifySongList"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    //NSLog(@"-----------%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"spotify"]);
                    
                    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"spotifyLogin"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"     " object:nil];
                    
                }];
            }
        }
        
        [[WebDataManager sharedInstance] stopActivityIndicator];
        
    }];
}
/*
- (void)fetchAllUserPlaylistsWithSession:(SPTSession *)session callback:(void (^)(NSError *, NSArray *))callback
{
    
    [SPTPlaylistList playlistsForUserWithSession:session callback:^(NSError *error, id object) {
        
        if (error != nil) {
            callback(error, nil);
            
            return;
        }
        
        SPTPlaylistList *_playlists = (SPTPlaylistList *)object;
        int resultsCount = (int)_playlists.items.count;
        
        NSLog(@"resultsCount ----->>>>> %d",resultsCount);
        
        [self didFetchListPageForSession:session finalCallback:callback error:error object:object allItems:[NSMutableArray array]];
        
    }];
}

- (void)didFetchListPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError*, NSArray*))finalCallback error:(NSError *)error object:(id)object allItems:(NSMutableArray *)allItems
{
    if (error != nil) {
        finalCallback(error, nil);
    } else {
        
        if ([object isKindOfClass:[SPTPlaylistList class]]) { // playlists
            
            SPTPlaylistList *playlistList = (SPTPlaylistList *)object;
            for (SPTPartialPlaylist *playlist in playlistList.items) {
                [allItems addObject:playlist];
            }
            
            if (playlistList.hasNextPage) { // has next
                
                [playlistList requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [self didFetchListPageForSession:session
                                                    finalCallback:finalCallback
                                                            error:error
                                                           object:object
                                                         allItems:allItems];
                }];
                
            } else { // ended
                
                finalCallback(nil, [allItems copy]);
            }
        }
        else if ([object isKindOfClass:[SPTListPage class]]) { // page of items
            SPTListPage*listPage = (SPTListPage*)object;
            for (SPTSavedTrack *track in listPage.items) {
                [allItems addObject:track];
            }
            if (listPage.hasNextPage) { // has next
                [listPage requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [self didFetchListPageForSession:session
                                                    finalCallback:finalCallback
                                                            error:error
                                                           object:object
                                                         allItems:allItems];
                }];
            }  else { // ended
                
                finalCallback(nil, [allItems copy]);
            }
        }
        else if ([object isKindOfClass:[SPTPlaylistSnapshot class]]) { // page of items
            
            SPTPlaylistSnapshot*listPage = (SPTPlaylistSnapshot*)object;
            SPTListPage *page = listPage.firstTrackPage;
            for (SPTSavedTrack *track in page.items) {
                [allItems addObject:track];
            }
            if (page.hasNextPage) { // has next
                [page requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [self didFetchListPageForSession:session
                                                    finalCallback:finalCallback
                                                            error:error
                                                           object:object
                                                         allItems:allItems];
                }];
            }  else { // ended
                
                finalCallback(nil, [allItems copy]);
            }
        }
        
    }
}

- (void) loadTracksForPlaylistForSession:(SPTSession *)session playlist:(SPTPlaylistSnapshot*)playlist completionHandler:(void (^)(id results, NSError* error))completion {
    
    [self didFetchTracksForSession:session playlistPage:playlist.firstTrackPage
                              finalCallback:^(NSError *error, SPTListPage *finalPage) {
                                  if (completion) {
                                      completion(finalPage, error);
                                  }
                              }];
}

-  (void)didFetchTracksForSession:(SPTSession *)session playlistPage:(SPTListPage *)listPage finalCallback:(void (^)(NSError*error, SPTListPage*finalPage))finalCallback {
    if (listPage.hasNextPage && !listPage.isComplete) {
        [listPage requestNextPageWithSession:session
                                    callback:^(NSError *error, id object) {
                                        if (error) {
                                            if (finalCallback) {
                                                finalCallback(error, nil);
                                            }
                                            return;
                                        }
                                        [self didFetchTracksForSession:session playlistPage:[listPage pageByAppendingPage:object]
                                                                  finalCallback:finalCallback];
                                        
                                    }];
        return;
    }
    if (finalCallback) {
        finalCallback(nil, listPage);
    }
}
*/

#pragma mark - ---------------
#pragma mark - Control Center Setup

//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (_data_ControlSetup == nil) {
        return;
    }
    
    NSString *eventTypeStr = @"";
    
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay)
        {
            eventTypeStr = @"Play";
            
            [self didUpdatingControlCenterPlayStatus:YES];
            
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPause)
        {
            eventTypeStr = @"Pause";
                        
            [self didUpdatingControlCenterPlayStatus:NO];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack)
        {
            eventTypeStr = @"Previous";
            
        }
        else if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
        {
            eventTypeStr = @"Next";
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ControlCenterAction" object:eventTypeStr];
    }
}

- (void)didUpdateControlSetupWithData:(NSDictionary *)data {
    
    _data_ControlSetup = data;
    
    float duration;
    
    if ([[data valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        duration = [[data valueForKey:@"duration"] floatValue]/1000;
        
    } else if ([[data valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        duration = [[data valueForKey:@"duration"] floatValue];
        
    } else if ([[data valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        duration = [[data valueForKey:@"duration"] floatValue];
        
    } else if ([[data valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        duration = [[data valueForKey:@"duration"] floatValue];
        
    } else {
        
        //Unknown
    }
    
//    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:artImage]; MPMediaItemPropertyArtwork:artwork
    
    //[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    
    NSDictionary *nowPlaying = @{ MPMediaItemPropertyArtist:[data valueForKey:@"artistName"], MPMediaItemPropertyAlbumTitle:[data valueForKey:@"title"], MPMediaItemPropertyPlaybackDuration:@(duration), MPNowPlayingInfoPropertyPlaybackRate:@1.0f };
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
    
}

- (void)didUpdatingControlCenterPlayStatus:(BOOL)status {
    
    if (_data_ControlSetup == nil) {
        return;
    }
    
    float duration;
    
    if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        duration = [[_data_ControlSetup valueForKey:@"duration"] floatValue]/1000;
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        duration = [[_data_ControlSetup valueForKey:@"duration"] floatValue];
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        duration = [[_data_ControlSetup valueForKey:@"duration"] floatValue];
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        duration = [[_data_ControlSetup valueForKey:@"duration"] floatValue];
        
    } else {
        
        //Unknown
    }
    
    float playbackTime;
    
    if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        playbackTime = (float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position];
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        playbackTime = [[SongPlayerController sharedInstance] soundcloud_player].currentTime;
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        playbackTime = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackTime];
        
        //playbackTime = CMTimeGetSeconds(currentTime);
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        playbackTime = [[[SongPlayerController sharedInstance] deezer_player] progress];
        
    } else {
        
        //Unknown
    }
    
    NSDictionary *nowPlaying = @{ MPMediaItemPropertyArtist:[_data_ControlSetup valueForKey:@"artistName"], MPMediaItemPropertyAlbumTitle:[_data_ControlSetup valueForKey:@"title"], MPMediaItemPropertyPlaybackDuration:@(duration), MPNowPlayingInfoPropertyPlaybackRate:status==YES?@1.0f:@0.0f,MPNowPlayingInfoPropertyElapsedPlaybackTime:@(playbackTime) };
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
    
}

- (void)didSeekControlCenterPlayerSongProgressWithTime:(NSInteger)time {
    
    if (_data_ControlSetup == nil) {
        return;
    }
    
    float duration;
    
    if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        duration = [[_data_ControlSetup valueForKey:@"duration"] floatValue]/1000;
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        duration = [[_data_ControlSetup valueForKey:@"duration"] floatValue];
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        duration = [[_data_ControlSetup valueForKey:@"duration"] floatValue];
        
    } else if ([[_data_ControlSetup valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        duration = [[_data_ControlSetup valueForKey:@"duration"] floatValue];
        
    } else {
        
        //Unknown
    }
    
    NSDictionary *nowPlaying = @{ MPMediaItemPropertyArtist:[_data_ControlSetup valueForKey:@"artistName"], MPMediaItemPropertyAlbumTitle:[_data_ControlSetup valueForKey:@"title"], MPMediaItemPropertyPlaybackDuration:@(duration), MPNowPlayingInfoPropertyPlaybackRate:@1.0f,MPNowPlayingInfoPropertyElapsedPlaybackTime:@(time) };
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
    
}

- (void)didStopControlCenterPlayer {
    
//    if (_data_ControlSetup == nil) {
//        return;
//    }
    
    NSDictionary *nowPlaying = @{ MPMediaItemPropertyArtist:@"", MPMediaItemPropertyAlbumTitle:@"", MPMediaItemPropertyPlaybackDuration:@0.0f, MPNowPlayingInfoPropertyPlaybackRate:@0.0f,MPNowPlayingInfoPropertyElapsedPlaybackTime:@0.0f };
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
    
}


#pragma mark - ---------------
#pragma mark - Reachablity

// Checking reachablity in app
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    Reachability *reachability1= [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability1 currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //my web-dependent code
        self.IsReachable=true;
    }
    else {
        self.IsReachable=false;
    }
}

@end
