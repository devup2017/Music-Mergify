//
//  PlayerViewController.m
//  Mergify
//
//  Created by Abhishek Kumar on 02/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "PlayerViewController.h"

#import "UIImageView+WebCache.h"

#import "PlayerCell.h"

@interface PlayerViewController ()<KAProgressLabelDelegate,SongPlayerControllerDelegate>
{
    
    PlayerCell *playerCell;
    
    float progressValue;
    
    UIActivityIndicatorView *spinner;
    
    NSTimer *timerToPlaySongWithDelay;
    
    BOOL isPlayerViewDisplaying;
    
}

@property (nonatomic, assign) BOOL wrap;


@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //configure carousel
    self.carousel.type = iCarouselTypeRotary;
    self.carousel.pagingEnabled = YES;
    self.wrap = NO;
    
    [_lbl_SeekTimer setHidden:YES];
    
    // Control Center...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleControlCenterAction:) name:@"ControlCenterAction" object:nil];
    
    //.................
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner setFrame:CGRectMake(SCREEN_WIDTH/2-10, SCREEN_HEIGHT/2-10, 20, 20)];
    [spinner setHidesWhenStopped:YES];
    [self.view addSubview:spinner];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    isPlayerViewDisplaying = YES;
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        [_btn_Suffle setSelected:NO];
        
    } else {
        
        [_btn_Suffle setSelected:YES];
    }
    
    [[SongPlayerController sharedInstance] setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    
    /*
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        _arr_Tracks = [SongPlayerController sharedInstance].arr_songList;
        
    } else {
        
        _arr_Tracks = [[NSUserDefaults standardUserDefaults] valueForKey:@"tracks"];
    }
    */
    
    _arr_Tracks = [SongPlayerController sharedInstance].arr_songList;
    
    [self.carousel reloadData];
    
    _carouselCurrentIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
    
    [self updateViewWithIndex:_carouselCurrentIndex];
    
    if (_arr_Tracks && _carouselCurrentIndex > 0) {
        
        [self.carousel scrollToItemAtIndex:_carouselCurrentIndex animated:NO];
        
    } else {
        
        if ([[SongPlayerController sharedInstance] soundcloud_player].isPlaying) {
            
            [_btn_PlayAndPause setSelected:YES];
            
            progressValue = [[SongPlayerController sharedInstance] soundcloud_player].currentTime;
            
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
        } else if ([[[[SongPlayerController sharedInstance] spotify_player] playbackState] isPlaying]) {
            
            [_btn_PlayAndPause setSelected:YES];
            
            progressValue = (float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position];
            
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
        } else if ([[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackRate] != 0) {
            
            [_btn_PlayAndPause setSelected:YES];
            
            float time = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackTime];
            //float time = CMTimeGetSeconds(currentTime);
            
            progressValue = time;
            
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
            //CMTime currentTime = [_iTunes_player currentTime];
            
            //
            
        } else {
            
            progressValue = 0;
            [_btn_PlayAndPause setSelected:NO];
        }
        
        //[self.carousel scrollToItemAtIndex:_carouselCurrentIndex animated:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    isPlayerViewDisplaying = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
}

#pragma mark -
#pragma mark iCarousel methods


- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return self.wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.0f;
        }
        case iCarouselOptionFadeMax:
        {
            if (self.carousel.type == iCarouselTypeRotary)
            {
                //set opacity based on distance from camera
                return value*1.5f;
            }
            return value;
        }
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
            return value;
    }
}

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel
{
    return [_arr_Tracks count];
    
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
    PlayerCell *custom;
    //    if (view == nil)
    //    {
    custom = [[[NSBundle mainBundle] loadNibNamed:@"PlayerCell" owner:nil options:nil]firstObject];
    //    }
    
    
    if ([[[_arr_Tracks objectAtIndex:index] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        //[[arr_Tracks objectAtIndex:indexPath.row] valueForKey:@"artistImage"]
        //[CommonUtils convertDataintoImage:[NSData data]]
        
        NSData *data = [[[_arr_Tracks objectAtIndex:index] valueForKey:@"artistImage"] isKindOfClass:[NSData class]]?[[_arr_Tracks objectAtIndex:index] valueForKey:@"artistImage"]:nil;
        
        if (data) {
            [custom.songImageView setImage:[CommonUtils convertDataintoImage:data]];
        } else {
            [custom.songImageView setImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        }
        
    } else {
        
        [custom.songImageView sd_setImageWithURL:[NSURL URLWithString:[[_arr_Tracks objectAtIndex:index] valueForKey:@"artistImage"]] placeholderImage:[UIImage imageNamed:@"profileplaceholder.jpg"]];
        
    }
    
    custom.lbl_SongProgress.delegate = self;
    
    if (_carouselCurrentIndex == index) {
        
        [custom.lbl_SongProgress setHidden:NO];
        
        if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"spotify"] && (float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position] > 0) {
            
            [custom.lbl_SongProgress setEndDegree:360/[[SongPlayerController sharedInstance] spotify_player].metadata.currentTrack.duration*(float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position]];
            
        } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"] && [[SongPlayerController sharedInstance] soundcloud_player].currentTime) {
            
            [custom.lbl_SongProgress setEndDegree:360/[[SongPlayerController sharedInstance] soundcloud_player].duration*[[SongPlayerController sharedInstance] soundcloud_player].currentTime];
            
        } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"] && [[SongPlayerController sharedInstance] iTunes_player].currentPlaybackRate) {
            
            float duration = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] floatValue];
            float time = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackTime];
            
            [custom.lbl_SongProgress setEndDegree:360/duration*time];
            
        } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"deezer"] && [[SongPlayerController sharedInstance] deezerProgress] > 0) {
            
            [custom.lbl_SongProgress setEndDegree:[[SongPlayerController sharedInstance] deezerProgress]*360];
            
        } else {
            
            ////////
        }
        
    }else{
        [custom.lbl_SongProgress setHidden:YES];
        [custom.lbl_SongProgress setEndDegree:0];
    }
    
    view = custom;
    
    return view;
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel
{

    if (_carouselCurrentIndex < 0) {
        return;
    }
    
    if (_carouselCurrentIndex == 0 && ((float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position] == 0 && [[SongPlayerController sharedInstance] soundcloud_player].currentTime == 0 && [[SongPlayerController sharedInstance] iTunes_player].currentPlaybackRate == 0 && [[SongPlayerController sharedInstance] deezerProgress] == 0)) {
        
        return;
    }
    
    _carouselCurrentIndex = carousel.currentItemIndex;
    
    //NSLog(@"carouselCurrentItemIndexDidChange -------- >>>>>>> %ld",(long)_carouselCurrentIndex);
    
    playerCell = (PlayerCell *)[carousel itemViewAtIndex:_carouselCurrentIndex];
    [playerCell.lbl_SongProgress setHidden:YES];
    
    progressValue = 0;
    [self.carousel reloadData];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateCarousalWithDelay) object:nil];
    [self performSelector:@selector(updateCarousalWithDelay) withObject:nil afterDelay:0.6];
}

- (void)updateCarousalWithDelay {
    
    if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        if ([[[[SongPlayerController sharedInstance] spotify_player] playbackState] isPlaying] && (float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position] > 0 && [SongPlayerController sharedInstance].currentPlayingTrackIndex == _carouselCurrentIndex) {
            
            [_btn_PlayAndPause setSelected:YES];
            
            progressValue = (float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position];
            
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
        } else if ((float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position] > 0 && [SongPlayerController sharedInstance].currentPlayingTrackIndex == _carouselCurrentIndex) {
            
            progressValue = (float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position];
            
            [_carousel reloadItemAtIndex:_carouselCurrentIndex animated:NO];
            
        } else {
            
            progressValue = 0;
            [self.carousel reloadData];
            
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerProgress) object:nil];
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
        }
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        if ([[SongPlayerController sharedInstance] soundcloud_player].isPlaying && ([[SongPlayerController sharedInstance] soundcloud_player].currentTime > 0 && [SongPlayerController sharedInstance].currentPlayingTrackIndex == _carouselCurrentIndex)) {
            
            [_btn_PlayAndPause setSelected:YES];
            
            progressValue = [[SongPlayerController sharedInstance] soundcloud_player].currentTime;
            
            if (_carouselCurrentIndex != 0) {
                
                // call method to play song..
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            }
            
        } else if ([[SongPlayerController sharedInstance] soundcloud_player].currentTime > 0 && [SongPlayerController sharedInstance].currentPlayingTrackIndex == _carouselCurrentIndex) {
            
            progressValue = [[SongPlayerController sharedInstance] soundcloud_player].currentTime;
            
            [_carousel reloadItemAtIndex:_carouselCurrentIndex animated:NO];
            
        } else {
            
            progressValue = 0;
            [self.carousel reloadData];
            [_btn_PlayAndPause setSelected:NO];
                        
            [[SongPlayerController sharedInstance] pauseSongWithIndex:_carouselCurrentIndex];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerProgress) object:nil];
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
            
            if (_carouselCurrentIndex >= 0) {
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
                
            }
            
        }
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        float time = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackTime];
        //float time = CMTimeGetSeconds(currentTime);
        
        if ([[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackRate] != 0 && [SongPlayerController sharedInstance].currentPlayingTrackIndex == _carouselCurrentIndex) {
            
            [_btn_PlayAndPause setSelected:YES];
            
            progressValue = time;
            
            if (_carouselCurrentIndex != 0) {
                
                // call method to play song..
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            }
            
        } else if ([[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackRate] != 0  && [SongPlayerController sharedInstance].currentPlayingTrackIndex == _carouselCurrentIndex) {
            
            progressValue = time;
            
            [_carousel reloadItemAtIndex:_carouselCurrentIndex animated:NO];
            
        } else {
            
            progressValue = 0;
            [self.carousel reloadData];
            [_btn_PlayAndPause setSelected:NO];
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:_carouselCurrentIndex];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerProgress) object:nil];
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
            
            if (_carouselCurrentIndex >= 0) {
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
                
            }
            
        }
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        if ([[[SongPlayerController sharedInstance] deezer_player] isPlaying] && [[SongPlayerController sharedInstance] deezerProgress] > 0 && [SongPlayerController sharedInstance].currentPlayingTrackIndex == _carouselCurrentIndex) {
            
            [_btn_PlayAndPause setSelected:YES];
            
            progressValue = [[SongPlayerController sharedInstance] deezerProgress];
            
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
        } else if ([[SongPlayerController sharedInstance] deezerProgress] > 0 && [SongPlayerController sharedInstance].currentPlayingTrackIndex == _carouselCurrentIndex) {
            
            progressValue = [[SongPlayerController sharedInstance] deezerProgress];
            
            [_carousel reloadItemAtIndex:_carouselCurrentIndex animated:NO];
            
        } else {
            
            progressValue = 0;
            [self.carousel reloadData];
            
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerProgress) object:nil];
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
        }
        
    } else {
        
        ////////
    }
    
    [self updateViewWithIndex:_carouselCurrentIndex];
    
}


#pragma mark -
#pragma mark - IBAction

- (IBAction)btn_PlayAndPause:(id)sender {
    
    if (_arr_Tracks == nil || [_arr_Tracks count] == 0) {
        return;
    }
    
    if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        if ([_btn_PlayAndPause isSelected]) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            
            [_btn_PlayAndPause setSelected:NO];
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:_carouselCurrentIndex];
            
        } else {
            
            if ([[[[SongPlayerController sharedInstance] spotify_player] playbackState] isPlaying] || (float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position] > 0) {
                
                [_btn_PlayAndPause setSelected:YES];
                
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
                
                progressValue = (float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position];
                
                [[SongPlayerController sharedInstance] playSongWithIndex:_carouselCurrentIndex];
                
            } else {
                
                progressValue = 0;
                
                [_btn_PlayAndPause setSelected:NO];
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
                
            }
        }
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        if ([_btn_PlayAndPause isSelected]) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            
            [_btn_PlayAndPause setSelected:NO];
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:_carouselCurrentIndex];
            
        } else {
            
            if ([[SongPlayerController sharedInstance] soundcloud_player].isPlaying || [[SongPlayerController sharedInstance] soundcloud_player].currentTime > 0) {
                
                [_btn_PlayAndPause setSelected:YES];
                
                progressValue = [[SongPlayerController sharedInstance] soundcloud_player].currentTime;
                
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
                
                [[SongPlayerController sharedInstance] playSongWithIndex:_carouselCurrentIndex];
                
            } else {
                
                progressValue = 0;
                
                [_btn_PlayAndPause setSelected:NO];
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
                
            }
        }
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        if ([_btn_PlayAndPause isSelected]) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            
            [_btn_PlayAndPause setSelected:NO];
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:_carouselCurrentIndex];
            
        } else {
            
            float time = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackTime];
            //float time = CMTimeGetSeconds(currentTime);
            
            if ([[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackRate] != 0 || time > 0) {
                
                [_btn_PlayAndPause setSelected:YES];
                
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
                
                progressValue = time;
                
                [[SongPlayerController sharedInstance] playSongWithIndex:_carouselCurrentIndex];
                
            } else {
                
                progressValue = 0;
                
                [_btn_PlayAndPause setSelected:NO];
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
                
            }
        }
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        if ([_btn_PlayAndPause isSelected]) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            
            [_btn_PlayAndPause setSelected:NO];
            
            [[SongPlayerController sharedInstance] pauseSongWithIndex:_carouselCurrentIndex];
            
        } else {
            
            if ([[[SongPlayerController sharedInstance] deezer_player] isPlaying] || [[SongPlayerController sharedInstance] deezerProgress] > 0) {
                
                [_btn_PlayAndPause setSelected:YES];
                
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
                
                progressValue = [[SongPlayerController sharedInstance] deezerProgress];
                
                [[SongPlayerController sharedInstance] playSongWithIndex:_carouselCurrentIndex];
                
            } else {
                
                progressValue = 0;
                
                [_btn_PlayAndPause setSelected:NO];
                
                [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
                
            }
        }
        
    } else {
        
        ////////
    }
    
    //_btn_PlayAndPause.selected = !_btn_PlayAndPause.selected;
}

- (IBAction)btn_Close:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    self.rootViewController.disableInteractivePlayerTransitioning = YES;
//    __weak typeof(self) weakSelf = self;
//    [self dismissViewControllerAnimated:YES completion:^{
//        //weakSelf.rootViewController.disableInteractivePlayerTransitioning = NO;
//    }];
    
}

- (IBAction)btn_Previous:(id)sender {
    
    if (_arr_Tracks == nil || [_arr_Tracks count] == 0) {
        return;
    }
    
    if (_carouselCurrentIndex == 0) return;
    
    [self.carousel reloadData];
    
    progressValue = 0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    
#warning suffle setup
    
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        _carouselCurrentIndex--;
        
    } else {
        
        _carouselCurrentIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_Tracks count]-1 andCurrentIndex:_carouselCurrentIndex];
    }
    
    
    [SongPlayerController sharedInstance].currentPlayingTrackIndex = _carouselCurrentIndex;
    
    [self.carousel scrollToItemAtIndex:_carouselCurrentIndex animated:YES];
    
    [self updateViewWithIndex:_carouselCurrentIndex];
    
    
}

- (IBAction)btn_Next:(id)sender {
    
    if (_arr_Tracks == nil || [_arr_Tracks count] == 0) {
        return;
    }
    
    if (_carouselCurrentIndex == [_arr_Tracks count]-1) return;
    
    [self.carousel reloadData];
    
    progressValue = 0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    
#warning suffle setup
    
    
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
        
        _carouselCurrentIndex++;
        
    } else {
        
        _carouselCurrentIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_Tracks count]-1 andCurrentIndex:_carouselCurrentIndex];
    }
    
    [self.carousel scrollToItemAtIndex:_carouselCurrentIndex animated:YES];
    [self updateViewWithIndex:_carouselCurrentIndex];
    
}

- (IBAction)btn_Suffle:(id)sender {
    
    if (_arr_Tracks == nil || [_arr_Tracks count] == 0) {
        return;
    }
    
    
    if ([_btn_Suffle isSelected]) {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"No" forKey:@"suffleStatus"];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:@"suffleStatus"];
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _btn_Suffle.selected = !_btn_Suffle.selected;
    
    /*
    if ([_btn_Suffle isSelected]) {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"No" forKey:@"suffleStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"originalArray"] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:@"originalArray"] count]>0) {
            
            NSArray *tempArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"originalArray"];
            
            [[NSUserDefaults standardUserDefaults] setValue:tempArr forKey:@"tracks"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[SongPlayerController sharedInstance] setArr_songList:tempArr];
            
            //_arr_Tracks = tempArr;
        }
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:@"suffleStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setValue:_arr_Tracks forKey:@"originalArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSArray *tempArr = [CommonUtils shuffleArray:_arr_Tracks];
        
        [[NSUserDefaults standardUserDefaults] setValue:tempArr forKey:@"tracks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[SongPlayerController sharedInstance] setArr_songList:tempArr];
        
        //_arr_Tracks = tempArr;
    }
    
    _btn_Suffle.selected = !_btn_Suffle.selected;
    */
}

#pragma mark -
#pragma mark - SongPlayerControllerDelegate

- (void)updateViewForSelectedSongWithData:(NSDictionary *)data andPlayButtonStatus:(BOOL)pStatus {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        pStatus == YES?[spinner startAnimating]:[spinner stopAnimating];
        
    });
    
    [self.carousel reloadData];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if ([[SongPlayerController sharedInstance] soundcloud_player].currentTime > 0) {
        
        
    } else {
        
        progressValue = 0;
        
        [_carousel reloadItemAtIndex:_carouselCurrentIndex animated:NO];
    }
    
    if ([[data valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
        });
    }
    
    [_btn_PlayAndPause setSelected:NO];
    
    [self updateViewWithIndex:_carouselCurrentIndex];
}

- (void)playerStartPlayingTrackWithData:(NSDictionary *)data {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [spinner stopAnimating];
        
        [self.carousel reloadData];
        
        if ((float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position] == 0 ||[[SongPlayerController sharedInstance] soundcloud_player].currentTime == 0 ||[[SongPlayerController sharedInstance] iTunes_player].currentPlaybackRate == 0 || [[SongPlayerController sharedInstance] deezer_player].progress == 0) {
            
            [_btn_PlayAndPause setSelected:YES];
            
            [self.carousel scrollToItemAtIndex:[[SongPlayerController sharedInstance] currentPlayingTrackIndex] animated:YES];
            
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
        }
        
    });
    
}

- (void)playerStoppedWithError {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
    });
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    progressValue = 0;
    
    [_carousel reloadItemAtIndex:_carouselCurrentIndex animated:NO];
        
    [_btn_PlayAndPause setSelected:NO];
    
}

- (void)playListFinished {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
    });
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    progressValue = 0;
    
    [_btn_PlayAndPause setSelected:NO];
    
}

#pragma mark -
#pragma mark - Private Methods

- (void)updateViewWithIndex:(NSInteger)index {
    
    [_lbl_SongTitle setText:[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"title"]];
    [_lbl_ArtistTitle setText:[NSString stringWithFormat:@"Artist : %@",[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"artistName"]]];
    //[_lbl_AlbumTitle setText:[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:index] valueForKey:@"artistName"]];
    
    if ([[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        [_img_AccountType setImage:[UIImage imageNamed:@"Soundcloud_Icon"]];
        [_lbl_AccountType setText:@"Soundcloud"];
        
    } else if ([[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        [_img_AccountType setImage:[UIImage imageNamed:@"iTunes"]];
        [_lbl_AccountType setText:@"iTunes"];
        
    } else if ([[[[SongPlayerController sharedInstance].arr_songList objectAtIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        [_img_AccountType setImage:[UIImage imageNamed:@"Deezer_Icon"]];
        [_lbl_AccountType setText:@"Deezer"];
        
    } else {
        
        [_img_AccountType setImage:[UIImage imageNamed:@"Spotify_Icon"]];
        [_lbl_AccountType setText:@"Spotify"];
        
    }
    
}

#pragma mark -
#pragma mark - Player Methods

- (void)playerProgress {
    
    float time = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackTime];
    
    //float time = CMTimeGetSeconds(currentTime);
    
    if ((float)[[[[SongPlayerController sharedInstance] spotify_player] playbackState] position] <= [[SongPlayerController sharedInstance] spotify_player].metadata.currentTrack.duration || time > 0) {
        
        //progressValue++;
        
        [_carousel reloadItemAtIndex:_carouselCurrentIndex animated:NO];
        
        [self performSelector:@selector(playerProgress) withObject:nil afterDelay:1];
        
    }else{
        progressValue = 0;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerProgress) object:nil];
    }
}

#pragma mark -
#pragma mark - KAProgressLabelDelegate Touch Methods

- (void)progressBarGestureStateRecognizer:(UIPanGestureRecognizer *)recognizer andEndDegree:(CGFloat)endDegree {
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        
        [_lbl_SeekTimer setHidden:NO];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerProgress) object:nil];
        
        if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
            
            [[[SongPlayerController sharedInstance] iTunes_player] beginSeekingForward];
            [[[SongPlayerController sharedInstance] iTunes_player] beginSeekingBackward];
        }
        
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        
        [_lbl_SeekTimer setHidden:YES];
        
        if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
            
            //float sec = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] integerValue];
            
            progressValue = [[SongPlayerController sharedInstance] spotify_player].metadata.currentTrack.duration/360*endDegree;
            
            [[[SongPlayerController sharedInstance] spotify_player] seekTo:progressValue callback:nil];
            
            //[[[SongPlayerController sharedInstance] spotify_player] seekTo:[[SongPlayerController sharedInstance] spotify_player].currentTrackDuration/360*endDegree callback:nil];
            
            if ([_btn_PlayAndPause isSelected]) {
                
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            }
            
            [THIS didSeekControlCenterPlayerSongProgressWithTime:[[SongPlayerController sharedInstance] spotify_player].metadata.currentTrack.duration/360*endDegree];
            
        } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
            
            //float sec = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] integerValue]/1000;
            
                        
            progressValue = [[SongPlayerController sharedInstance] soundcloud_player].duration/360*endDegree;
            
            NSTimeInterval time = [[SongPlayerController sharedInstance] soundcloud_player].duration/360*endDegree;
            
            //NSLog(@"%f",time);
            
            //[[[SongPlayerController sharedInstance] soundcloud_player] playAtTime:time];
            
            [[SongPlayerController sharedInstance] soundcloud_player].currentTime = time;
            
            if ([_btn_PlayAndPause isSelected]) {
                
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            }
            
            [THIS didSeekControlCenterPlayerSongProgressWithTime:time];
            
        } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
            
            
            float duration = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] floatValue];
            
            [[[SongPlayerController sharedInstance] iTunes_player] endSeeking];
            
            progressValue = duration/360*endDegree;
            
            [[[SongPlayerController sharedInstance] iTunes_player] setCurrentPlaybackTime:progressValue];
            
            float time = [[[SongPlayerController sharedInstance] iTunes_player] currentPlaybackTime];
            
            //float time = CMTimeGetSeconds(currentTime);
            
            //NSTimeInterval seekToTime = duration/360*endDegree;
            
            //CMTime seekToTime = CMTimeMake(duration/360*endDegree, 1);
            
            if ([_btn_PlayAndPause isSelected]) {
                
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            }
            
            [THIS didSeekControlCenterPlayerSongProgressWithTime:time/360*endDegree];
            
        } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
            
            //float sec = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] integerValue];
            
            progressValue = endDegree/360;
            
            CGFloat progress = endDegree/360;
            
            //NSLog(@"------------------------------ progress = %f",progress);
            
            [[SongPlayerController sharedInstance] deezer_player].progress = progress;
            
            if ([_btn_PlayAndPause isSelected]) {
                
                [self performSelector:@selector(playerProgress) withObject:nil afterDelay:1];
            }
            
            [THIS didSeekControlCenterPlayerSongProgressWithTime:[[SongPlayerController sharedInstance] deezerProgress]];
            
        } else {
            
            ////////
        }
        
    } else {
        
        // nothing to do...
    }
}

- (void)progressBarEndDegree:(CGFloat)endDegree {
    
    if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"spotify"]) {
        
        float sec = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] integerValue];
        
        [_lbl_SeekTimer setText:[NSString stringWithFormat:@"%@",[CommonUtils timeFormatted:sec/360*endDegree]]];
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"soundcloud"]) {
        
        float sec = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] integerValue]/1000;
        
        [_lbl_SeekTimer setText:[NSString stringWithFormat:@"%@",[CommonUtils timeFormatted:sec/360*endDegree]]];
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"iTunes"]) {
        
        float sec = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] integerValue];
        
        [_lbl_SeekTimer setText:[NSString stringWithFormat:@"%@",[CommonUtils timeFormatted:sec/360*endDegree]]];
        
    } else if ([[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"accountType"] isEqualToString:@"deezer"]) {
        
        float sec = [[[_arr_Tracks objectAtIndex:_carouselCurrentIndex] valueForKey:@"duration"] integerValue];
        
        [_lbl_SeekTimer setText:[NSString stringWithFormat:@"%@",[CommonUtils timeFormatted:sec/360*endDegree]]];
        
    } else {
        
        ////////
    }
    
}


#pragma mark -
#pragma mark - Notification Methods
 
// Control center action method...

- (void)handleControlCenterAction:(NSNotification *)obj {
    
    if (isPlayerViewDisplaying) {
        
        _carouselCurrentIndex = [SongPlayerController sharedInstance].currentPlayingTrackIndex;
        
        NSString *tempStr = obj.object;
        
        if ([tempStr isEqualToString:@"Play"]) {
            
            [_btn_PlayAndPause setSelected:YES];
            [[SongPlayerController sharedInstance] playSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            
            [self performSelector:@selector(playerProgress) withObject:nil afterDelay:0.1];
            
        } else if ([tempStr isEqualToString:@"Pause"]) {
            
            [_btn_PlayAndPause setSelected:NO];
            [[SongPlayerController sharedInstance] pauseSongWithIndex:[SongPlayerController sharedInstance].currentPlayingTrackIndex];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerProgress) object:nil];
            
            
        } else if ([tempStr isEqualToString:@"Previous"]) {
            
            NSLog(@"playingSongTrackIndex ------------ %ld",(long)_carouselCurrentIndex);
            
            if (_carouselCurrentIndex == 0) {
                return;
            }
            
            
            
#warning suffle setup
            
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
                
                _carouselCurrentIndex--;
                
            } else {
                
                _carouselCurrentIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_Tracks count]-1 andCurrentIndex:_carouselCurrentIndex];
            }
            
             
             
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
            
            [self.carousel scrollToItemAtIndex:_carouselCurrentIndex animated:YES];
            
            [self updateViewWithIndex:_carouselCurrentIndex];
            
        } else if ([tempStr isEqualToString:@"Next"]) {
            
            
            if (_carouselCurrentIndex == [_arr_Tracks count]-1) {
                return;
            }
            
            
            
#warning suffle setup
            
            
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"suffleStatus"] isEqualToString:@"No"]) {
                
                _carouselCurrentIndex++;
                
            } else {
                
                _carouselCurrentIndex = [CommonUtils didCreateRandomNumberIfSuffleSelectedWithMaxValue:[_arr_Tracks count]-1 andCurrentIndex:_carouselCurrentIndex];
            }
            
             
            [[SongPlayerController sharedInstance] startPlayAudioWithIndex:_carouselCurrentIndex];
            
            [self.carousel scrollToItemAtIndex:_carouselCurrentIndex animated:YES];
            
            [self updateViewWithIndex:_carouselCurrentIndex];
            
        } else {
            
            NSLog(@"****************** Control center unknown state ******************");
        }
    }    
    
}


@end
