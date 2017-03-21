//
//  PlayerViewController.h
//  Mergify
//
//  Created by Abhishek Kumar on 02/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

#import "HomeVC.h"

@interface PlayerViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@property (nonatomic, weak) HomeVC *rootViewController;

@property (weak, nonatomic) IBOutlet UILabel *lbl_SongTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ArtistTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_SeekTimer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_AccountType;

@property (weak, nonatomic) IBOutlet UIImageView *img_AccountType;

@property (weak, nonatomic) IBOutlet UIButton *btn_PlayAndPause;
@property (weak, nonatomic) IBOutlet UIButton *btn_Suffle;

@property (nonatomic) NSInteger carouselCurrentIndex;

@property (nonatomic) BOOL isNotCommingFromSongsList;


@property (nonatomic, strong) NSArray *arr_Tracks;


- (IBAction)btn_Close:(id)sender;
- (IBAction)btn_PlayAndPause:(id)sender;
- (IBAction)btn_Previous:(id)sender;
- (IBAction)btn_Next:(id)sender;
- (IBAction)btn_Suffle:(id)sender;

@end
