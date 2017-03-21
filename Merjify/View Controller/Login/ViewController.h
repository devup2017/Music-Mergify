//
//  ViewController.h
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    IBOutlet UIImageView *imgBg;
}

@property (nonatomic, strong) IBOutlet UITextField *txt_Email;
@property (nonatomic, strong) IBOutlet UITextField *txt_Password;


- (IBAction)btn_Action_Login:(id)sender;
- (IBAction)btn_Action_ForgotPassword:(id)sender;
- (IBAction)btn_Action_SignUp:(id)sender;

@end

