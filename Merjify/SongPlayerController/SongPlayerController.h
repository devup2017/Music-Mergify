//
//  SongPlayerController.h
//  Mergify
//
//  Created by mac on 22/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <MediaPlayer/MediaPlayer.h>

//Deezer
#import "DeezerSession.h"
#import "DZRModel.h"
#import "DZRRequestManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DZRPlayer.h"

@import StoreKit;


@protocol SongPlayerControllerDelegate <NSObject>

@optional
- (void)updateViewForSelectedSongWithData:(NSDictionary *)data andPlayButtonStatus:(BOOL)playerStatus;
- (void)playerStartPlayingTrackWithData:(NSDictionary *)data;
- (void)playerStoppedWithError;
- (void)playListFinished;

@end


@interface SongPlayerController : NSObject<SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate,AVAudioPlayerDelegate,DeezerSessionConnectionDelegate,DZRPlayerDelegate>

+ (SongPlayerController *) sharedInstance;

@property (nonatomic, weak) id <SongPlayerControllerDelegate> delegate;

@property (nonatomic) NSInteger currentPlayingTrackIndex;

@property (nonatomic) NSInteger counter;

@property (nonatomic, strong) NSArray *arr_songList;

@property (strong, nonatomic) NSMutableDictionary *playlistDict;

@property (nonatomic) BOOL isPlayingAlbum;

@property (nonatomic) BOOL isFirstTime;

@property (nonatomic) BOOL isSessionUpdated;

@property (nonatomic) BOOL isPlayingPlaylist;
@property (nonatomic, strong) NSString *playlistTitle;

@property (nonatomic) BOOL isPlayingiTunes;

- (void)startPlayAudioWithIndex:(NSInteger )index;

- (void)pauseSongWithIndex:(NSInteger )index;

- (void)playSongWithIndex:(NSInteger )index;

// ******************************************************************//
// Spotify setup...

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *spotify_player;

- (void)spotify_playSong;
- (void)spotify_playPause;
- (void)spotify_play;
- (void)spotify_pause;
- (BOOL)isSessionValid;

// ******************************************************************//


// ******************************************************************//
// Soundcloud setup...

@property (nonatomic, strong) AVAudioPlayer *soundcloud_player;

@property (nonatomic, strong) NSURLSessionTask *task;

- (void)soundcloud_downloadDataAndPlaySong;
- (void)soundcloud_play;
- (void)soundcloud_pause;
- (BOOL)isPlayerPlayingSong;

// ******************************************************************//


// ******************************************************************//
// Apple Music setup...

@property (nonatomic, strong) MPMusicPlayerController *iTunes_player;

- (void)iTunes_play;
- (void)iTunes_playIfPaused;
- (void)iTunes_pause;

// ******************************************************************//


// ******************************************************************//
// Deezer setup...

@property (nonatomic, strong) DZRPlayer *deezer_player;
@property (nonatomic, strong) id<DZRPlayable> playable;

@property (nonatomic, strong) DZRRequestManager *manager;
@property (nonatomic, strong) id<DZRCancelable> trackRequest;

@property (nonatomic, strong) NSMutableArray *arr_DeezerList;

@property (nonatomic) BOOL isDeezerLoginTapped;

@property (nonatomic) double deezerProgress;

- (void)deezerLogin;

- (void)deezer_play;
- (void)deezer_playIfPaused;
- (void)deezer_pause;

// ******************************************************************//


@end



