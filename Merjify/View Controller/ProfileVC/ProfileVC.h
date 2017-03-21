//
//  ProfileVC.h
//  Mergify
//
//  Created by Abhishek Kumar on 12/10/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileVC : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, WebDataManagerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *txt_Name;

@property (nonatomic, weak) IBOutlet UIImageView *img_Profile;
@property (nonatomic, weak) IBOutlet UIImageView *img_Placeholder;
@property (nonatomic, weak) IBOutlet UIButton *btn_profile;

@end
