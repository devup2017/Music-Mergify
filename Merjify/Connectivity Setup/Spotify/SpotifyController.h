//
//  SpotifyController.h
//  Merjify
//
//  Created by Abhishek Kumar on 21/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>

@interface SpotifyController : NSObject

@property (nonatomic, readwrite, copy) NSArray *scopes;
@property (nonatomic, readwrite, copy) NSArray *scopeDisplayNames;
@property (nonatomic, readwrite, strong) NSMutableArray *selectedScopes;

- (void)logIn;

//+ (void)fetchAllUserPlaylistsWithSession:(SPTSession *)session callback:(void (^)(NSError *, NSArray *))callback;

@end
