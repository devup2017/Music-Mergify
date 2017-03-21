//
//  SignUpVC.h
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpVC : UIViewController<UIActionSheetDelegate, UITextFieldDelegate, WebDataManagerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *txt_Email;
@property (nonatomic, strong) IBOutlet UITextField *txt_Password;
@property (nonatomic, strong) IBOutlet UITextField *txt_ConfirmPassword;

-(IBAction)btn_Action_SignUpNow:(id)sender;
- (IBAction)btn_Action_SignIn:(id)sender;

@end
