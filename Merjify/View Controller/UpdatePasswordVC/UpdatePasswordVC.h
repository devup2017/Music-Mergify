//
//  UpdatePasswordVC.h
//  Mergify
//
//  Created by Abhishek Kumar on 12/10/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdatePasswordVC : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *txt_CurrentPassword;
@property (nonatomic, strong) IBOutlet UITextField *txt_NewPassword;
@property (nonatomic, strong) IBOutlet UITextField *txt_ConfirmPassword;

@end
