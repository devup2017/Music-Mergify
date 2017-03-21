//
//  PlayerCell.m
//  Mergify
//
//  Created by Abhishek Kumar on 03/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "PlayerCell.h"

@implementation PlayerCell

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
//    [self.lbl_SongProgress.layer setShadowColor:[UIColor whiteColor].CGColor];
//    [self.lbl_SongProgress.layer setShadowOpacity:0.8];
//    [self.lbl_SongProgress.layer setShadowRadius:20.0];
//    [self.lbl_SongProgress.layer setShadowOffset:CGSizeMake(10.0, 10.0)];
    
    self.lbl_SongProgress.backgroundColor = [UIColor clearColor];
    
    self.lbl_SongProgress.isEndDegreeUserInteractive = YES;
    self.lbl_SongProgress.isStartDegreeUserInteractive = NO;
    
    self.lbl_SongProgress.labelVCBlock = ^(KAProgressLabel *label) {
        self.lbl_SongProgress.startLabel.text = [NSString stringWithFormat:@"%.f",self.lbl_SongProgress.startDegree];
        self.lbl_SongProgress.endLabel.text = [NSString stringWithFormat:@"%.f",self.lbl_SongProgress.endDegree];
    };
    [self.lbl_SongProgress setTrackWidth: 5.0f];
    [self.lbl_SongProgress setProgressWidth: 5.0f];
    self.lbl_SongProgress.trackColor = [UIColor colorWithRed:68.0/255.0f green:51.0/255.0f blue:63.0/255.0f alpha:1.0];
    self.lbl_SongProgress.progressColor = [UIColor colorWithRed:227.0/255.0f green:32.0/255.0f blue:56.0/255.0f alpha:1.0];
    
    self.lbl_SongProgress.roundedCornersWidth = 15.0f;
    self.lbl_SongProgress.font = [UIFont fontWithName:@"Helvetica" size:30];
    
    self.songImageView.layer.cornerRadius = self.songImageView.frame.size.width/2;
    //self.lbl_GestureDetection.layer.cornerRadius = self.lbl_GestureDetection.frame.size.width/2;
}

@end
