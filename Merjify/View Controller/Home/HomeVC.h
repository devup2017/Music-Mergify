//
//  HomeVC.h
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>

@interface HomeVC : UIViewController<SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) BOOL disableInteractivePlayerTransitioning;

@end
