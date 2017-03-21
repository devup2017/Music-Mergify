//
//  SearchCell.m
//  Mergify
//
//  Created by Abhishek Kumar on 07/12/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SearchCell.h"

@implementation SearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
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
