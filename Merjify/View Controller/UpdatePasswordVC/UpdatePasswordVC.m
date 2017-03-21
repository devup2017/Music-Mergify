//
//  UpdatePasswordVC.m
//  Mergify
//
//  Created by Abhishek Kumar on 12/10/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "UpdatePasswordVC.h"

@interface UpdatePasswordVC ()

@end

@implementation UpdatePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Update Password";
    
    [_txt_CurrentPassword setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
    [_txt_NewPassword setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
    [_txt_ConfirmPassword setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)btn_Action_Update:(id)sender {
    
    if ([self validate]) {
        // hit update Password api...
        [self updatePassword];
        
    } else {
        
        //Nothing to do...
    }
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [CommonUtils setMoveUp:self.view withView:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [CommonUtils setMoveDown:self.view withView:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyGo) {
        
        if ([self validate]) {
            
            // hit update Password api...
            [self updatePassword];
            
        } else {
            //Nothing to do...
        }
    }
    
    if (textField == _txt_CurrentPassword) {
        [_txt_NewPassword becomeFirstResponder];
    } else if (textField == _txt_NewPassword) {
        [_txt_ConfirmPassword becomeFirstResponder];
    } else if (textField == _txt_ConfirmPassword) {
        [_txt_ConfirmPassword resignFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return  YES;
}

#pragma mark - Private Method

- (BOOL)validate {
    
    [self.view endEditing:YES];
    
    NSString *str_CurrentPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    
    if ([[_txt_CurrentPassword.text removeNull] isEqualToString:@""]) {
        
        Displayalert(APPLICATION_NAME, @"Please enter current password", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else if (![[_txt_CurrentPassword.text removeNull] isEqualToString:str_CurrentPassword]){
        
        Displayalert(APPLICATION_NAME, @"Your password did not match to the current password. Please enter the correct password.", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else if ([[_txt_NewPassword.text removeNull] isEqualToString:@""]){
        
        Displayalert(APPLICATION_NAME, @"Please enter new password", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else if ([[_txt_ConfirmPassword.text removeNull] isEqualToString:@""]){
        
        Displayalert(APPLICATION_NAME, @"Please enter confirm password", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else if (![[_txt_NewPassword.text removeNull] isEqualToString:[_txt_ConfirmPassword.text removeNull]]){
        
        Displayalert(APPLICATION_NAME, @"Please enter correct password in \"New Password\" and \"Confirm Password\" field.", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else {
        return YES;
    }
    
    return NO;
}

#pragma mark - Webservices

- (void)updatePassword {
    
    //opt=change_password&password=12345&new_password=123456&email=ajay1@netforce.co
    
    NSString *str_email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
    
    NSString *params = [NSString stringWithFormat:@"opt=change_password&password=%@&new_password=%@&email=%@",_txt_CurrentPassword.text,_txt_NewPassword.text,str_email];
    
    NSLog(@"params ----- %@",params);
    
    [[WebDataManager sharedInstance] executeGETWebServiceWithParamater:params withViewController:self withBlock:^(NSDictionary *items, NSError *error)
     {
         NSLog(@"%@",items);
         
         if (error) {
             
             Displayalert(APPLICATION_NAME,[error localizedDescription], self,[NSArray arrayWithObject:@"OK"],1)
             
             return;
         }
         
         if ([items isKindOfClass:[NSDictionary class]])
         {
             if ([[items objectForKey:@"status"] isEqualToString:@"Success"])
             {
                 
                 [[NSUserDefaults standardUserDefaults] setValue:_txt_NewPassword.text forKey:@"password"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 _txt_CurrentPassword.text = @"";
                 _txt_NewPassword.text = @"";
                 _txt_ConfirmPassword.text = @"";
                 
                 Displayalert(APPLICATION_NAME,[[[items objectForKey:@"data"] objectAtIndex:0] valueForKey:@"msg"], self,[NSArray arrayWithObject:@"OK"],1)
                 
             }else{
                 
                 Displayalert(APPLICATION_NAME,[[[items objectForKey:@"data"] objectAtIndex:0] valueForKey:@"msg"], self,[NSArray arrayWithObject:@"OK"],1)
             }
         }
         
     }];
}


@end
