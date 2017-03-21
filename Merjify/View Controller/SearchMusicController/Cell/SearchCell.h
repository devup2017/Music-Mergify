//
//  SearchCell.h
//  Mergify
//
//  Created by Abhishek Kumar on 07/12/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_Counting;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Username;

@property (weak, nonatomic) IBOutlet UIImageView *img_CellBG;
@property (weak, nonatomic) IBOutlet UIImageView *img_Userprofile;
@property (weak, nonatomic) IBOutlet UIImageView *img_AcountType;

@property (weak, nonatomic) IBOutlet UIButton *btn_More;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con_accountImageLead;

@end
