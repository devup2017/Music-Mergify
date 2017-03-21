//
//  SoundListCell.h
//  Merjify
//
//  Created by Abhishek Kumar on 18/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_Counting;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Username;

@property (weak, nonatomic) IBOutlet UIImageView *img_CellBG;
@property (weak, nonatomic) IBOutlet UIImageView *img_Userprofile;
@property (weak, nonatomic) IBOutlet UIImageView *img_AcountType;

//@property (weak, nonatomic) IBOutlet UIView *view_more;
@property (weak, nonatomic) IBOutlet UIButton *btn_More;
//@property (weak, nonatomic) IBOutlet UIButton *btn_Delete;
//@property (weak, nonatomic) IBOutlet UIButton *btn_AddToPlayList;


@property (weak, nonatomic) IBOutlet UIImageView *img_MoreImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con_accountImageLead;
@end

