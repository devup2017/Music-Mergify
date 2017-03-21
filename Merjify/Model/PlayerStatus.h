//
//  PlayerStatus.h
//  Mergify
//
//  Created by Abhishek Kumar on 11/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerStatus : NSObject

@property (nonatomic) NSInteger songIndex;
@property (nonatomic) NSInteger currentPlayedSongDuration;
@property (nonatomic) BOOL isSongPlaying;

@end
