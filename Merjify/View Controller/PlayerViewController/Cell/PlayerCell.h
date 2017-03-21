//
//  PlayerCell.h
//  Mergify
//
//  Created by Abhishek Kumar on 03/08/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"

@interface PlayerCell : UIView

@property (weak, nonatomic) IBOutlet KAProgressLabel *lbl_SongProgress;

@property (strong, nonatomic) IBOutlet UIImageView *songImageView;

@property (weak, nonatomic) IBOutlet UILabel *lbl_GestureDetection;

@end
