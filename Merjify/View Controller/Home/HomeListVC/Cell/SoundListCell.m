//
//  SoundListCell.m
//  Merjify
//
//  Created by Abhishek Kumar on 18/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SoundListCell.h"

@implementation SoundListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutIfNeeded];
    // Initialization code
    
    //self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellBGBlack"]];
    
    self.img_Userprofile.layer.cornerRadius = 2.0f;
    self.img_Userprofile.layer.borderWidth = 0.5f;
    self.img_Userprofile.layer.borderColor = [UIColor redColor].CGColor;
    
    
    CGSize textSize = [[self.lbl_Username text] sizeWithAttributes:@{NSFontAttributeName:[self.lbl_Username font]}];
    
    CGFloat strikeWidth = textSize.width;
    
    CGRect thisRect = self.img_AcountType.frame;
    
    thisRect.origin.x = strikeWidth;
    
    [self.img_AcountType setFrame:thisRect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
