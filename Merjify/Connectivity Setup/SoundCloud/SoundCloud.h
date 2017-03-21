//
//  SoundCloud.h
//  Stofkat.org
//
// First basic version of my custom SoundCloud library
// The one from SoundCloud has 5 dependancy projects just
// for some very basic funtionality. This project only uses
// JSONKit as an aditional library and should be much easier
// to implement in your own projects
// if you have any questions you can mail me at stofkat@gmail.com
//  Created by Stofkat on 08-05-14.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundCloud : NSObject

@property (strong, nonatomic)  NSMutableArray *scTrackResultList;
@property (nonatomic,retain) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic)  NSString *scToken;
@property (strong, nonatomic)  NSString *scCode;


//-(NSMutableArray *) searchForTracksWithQuery: (NSString *) query;
//-(NSData *) downloadTrackData :(NSString *)songURL;
//-(NSMutableArray *) getUserTracks;

- (void)doOauthWithCode:(NSString *)code;

-(BOOL) login;

@end
