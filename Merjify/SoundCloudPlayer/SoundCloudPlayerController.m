//
//  SoundCloudPlayerController.m
//  Mergify
//
//  Created by Abhishek Kumar on 08/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SoundCloudPlayerController.h"

@implementation SoundCloudPlayerController
/*
static  SoundCloudPlayerController *sharedInstance = nil;

static dispatch_once_t onceToken;

+ (SoundCloudPlayerController *) sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SoundCloudPlayerController alloc] init];
    });
    
    return sharedInstance;
}

- (void)downloadSongAndPlayWithIndex:(NSInteger )index {
    
    //NSLog(@"playing song index ------------ %ld",index);
    
    NSArray *tempArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
    
    //NSLog(@"%@",[tempArr objectAtIndex:index]);
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/stream?client_id=%@", [[tempArr objectAtIndex:index] valueForKey:@"uri"], CLIENT_ID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [_task cancel];
    
    _task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error == nil) {
            
            self.player = nil;
            
            self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
            [self.player setDelegate:self];
            [self.player play];
            
            [[NSNotificationCenter defaultCenter] removeObserver:@"stopSpinner"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopSpinner" object:nil];
        }
        
    }];
    
    [_task resume];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    NSLog(@"*******************audioPlayerDidFinishPlaying*******************");
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"audioPlayerDidFinishPlaying" object:nil];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    
    NSLog(@"*******************audioPlayerDecodeErrorDidOccur******************* error = %@",[error localizedDescription]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"audioPlayerDecodeErrorDidOccur" object:nil];
}

- (void)playSong {
    
    [self.player play];
}

- (void)pauseSong {
    
    [self.player pause];
}

- (void)cancelPreviousTask {
    
    [_task cancel];
    
}

- (BOOL)isPlayerPlayingSong {
    
    BOOL isPlayingPlayer;
    
    isPlayingPlayer = [self.player isPlaying];
    
    return isPlayingPlayer;
}
*/
@end
