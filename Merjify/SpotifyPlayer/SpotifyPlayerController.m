//
//  SpotifyPlayerController.m
//  Mergify
//
//  Created by Abhishek Kumar on 09/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SpotifyPlayerController.h"

@implementation SpotifyPlayerController
/*
static  SpotifyPlayerController *sharedInstance = nil;

static dispatch_once_t onceToken;

+ (SpotifyPlayerController *) sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SpotifyPlayerController alloc] init];
    });
    
    return sharedInstance;
}

- (void)loginUsingSession {
    
    if (self.player == nil) {
        
        // Get the player instance
        self.player = [SPTAudioStreamingController sharedInstance];
        self.player.delegate = self;
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
        // Start the player (will start a thread)
        [self.player startWithClientId:S_CLIENT_ID error:nil];
        // Login SDK before we can start playback
        [self.player loginWithAccessToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"spotifySessionStr"]];
    } else {
        
        if (_isAudioStreamingLoggedin) {
            
            [self playSong];
        }
    }
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    
    _isAudioStreamingLoggedin = YES;
    
    [self playSong];
    
}

#pragma mark - Handle Player

- (void)playSong {
    
    if (_isAudioStreamingLoggedin) {
        
        NSURL *url = [NSURL URLWithString:_uri_Track];
        
        [self.player playURIs:@[url] withOptions:nil callback:^(NSError *error) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopSpinner" object:error==nil?@"":@"error"];
            
            if (error != nil) {
                NSLog(@"**********%@",[error localizedDescription]);
            }
        }];
        
    } else {
        
        NSLog(@"***************** Audio Streaming Logged Out *****************");
        
    }
    
}

- (void)playPause {
    
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
}

- (void)play {
    
    [self.player setIsPlaying:YES callback:nil];
}

- (void)pause {
    
    [self.player setIsPlaying:NO callback:nil];
}

#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri{
    NSLog(@"started to play track: %@", trackUri);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotifyStartPlayingTrack" object:nil];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    NSLog(@"failed to play track: %@", trackUri);
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
    
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"is playing = %d", isPlaying);
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri {
    
    //NSLog(@"****************** didStopPlayingTrack *******************");
    
    if (self.player.currentPlaybackPosition  < self.player.currentTrackDuration) {
        
        NSLog(@"****************** user changed track *******************");
        
    } else {
        
        NSLog(@"****************** spotify finished playing current song *******************");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"spotifyPlayerDidFinishPlaying" object:nil];
    }
    
}

- (void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    NSError *error = nil;
    if (![self.player stopWithError:&error]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error deinit" message:[error description] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    }
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didEncounterError:(NSError *)error {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopSpinner" object:error==nil?@"":@"error"];
    
    if (error != nil) {
        
        NSLog(@"*** Playback got error: %@", [error localizedDescription]);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Spotify" message:@"Session expired, Please login again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }
}

- (void)renewSession {
    
    NSLog(@"_session ----- %@",THIS.storeSpotifySession);
    
    if ([THIS.storeSpotifySession isValid]) {
        
        [[SPTAuth defaultInstance] renewSession:THIS.storeSpotifySession
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

@end
