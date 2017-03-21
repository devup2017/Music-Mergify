//
//  AppDelegate.h
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

//https://developers.deezer.com/api
//dmitriplay19@gmail.com
//deezer

//Username: sulla.ron@gmail.com
//Password: soundcloud

//Username: havingfun12
//Password: spotify1

// Ad Mob
//App ID: ca-app-pub-1409082372034038~9509683509
//Ad unit ID: ca-app-pub-1409082372034038/4939883106



#import <UIKit/UIKit.h>

#import "SoundCloud.h"
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import "DIPWindow.h"

#import "JASidePanelController.h"
#import "DZRModel.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIBackgroundTaskIdentifier	bgTask;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@property (strong, nonatomic) JASidePanelController *sidePanelController;

@property (nonatomic, retain) SoundCloud *soundCloud;

@property (strong, nonatomic)  NSString *scCode;

+ (AppDelegate *)classinstance;

- (void)updateApplicationState;

@property (nonatomic) BOOL IsReachable;

@property (nonatomic, strong) SPTSession *storeSpotifySession;

@property (nonatomic, strong) NSDictionary *currentDataBottomBar;

@property (nonatomic) NSInteger arr_Count;

// store status of song list is currently playing...
@property (nonatomic) BOOL isPlayingMainSongList;

// Control setup...

- (void)didReceiveRemoteNotification;

@property (nonatomic, strong) NSDictionary *data_ControlSetup;

- (void)didUpdateControlSetupWithData:(NSDictionary *)data;
- (void)didUpdatingControlCenterPlayStatus:(BOOL)status;
- (void)didSeekControlCenterPlayerSongProgressWithTime:(NSInteger)time;
- (void)didStopControlCenterPlayer;

@end

/****************	Category Dictionary	****************/

