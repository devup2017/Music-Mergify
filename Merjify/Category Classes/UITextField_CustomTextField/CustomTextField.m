//
//  CustomTextField.m
//  OCC CRM
//
//  Created by shivamt on 1/14/16.
//  Copyright © 2016 Shivam. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFont:Font_Futura_Medium(self.font.pointSize)];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if(self)
    {
         [self setFont:Font_Futura_Medium(self.font.pointSize)];
    }
    return self;
}

@end
