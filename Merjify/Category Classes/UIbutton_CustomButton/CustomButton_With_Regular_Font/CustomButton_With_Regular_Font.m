//
//  CustomButton_With_BoldFOnt.m
//  OCC CRM
//
//  Created by shivamt on 1/15/16.
//  Copyright © 2016 Shivam. All rights reserved.
//

#import "CustomButton_With_Regular_Font.h"

@implementation CustomButton_With_Regular_Font

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self.titleLabel setFont:Font_OpenSans_Regular(self.titleLabel.font.pointSize)];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        //[self.titleLabel setFont:Font_OpenSans_Regular(self.titleLabel.font.pointSize)];
    }
    return self;
}

@end
