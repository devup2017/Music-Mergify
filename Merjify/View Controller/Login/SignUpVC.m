//
//  SignUpVC.m
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SignUpVC.h"

@interface SignUpVC ()
{
    NSData *imgData;
}
@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CommonUtils setStatusBarBackgroundColor:[UIColor clearColor]];
    
    [_txt_Email setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
    [_txt_Password setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
    [_txt_ConfirmPassword setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)btn_Action_SignUpNow:(id)sender {
    
    if ([self validate]) {
        // hit register api...
        [self registerUser];
        
    } else {
        
        //Nothing to do...
    }
    
}

- (IBAction)btn_Action_SignIn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [CommonUtils setMoveUp:self.view withView:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [CommonUtils setMoveDown:self.view withView:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyGo) {
        
        if ([self validate]) {
            // hit register api...
            [self registerUser];
            
        } else {
            //Nothing to do...
        }
    }

    if (textField == _txt_Email) {
        [_txt_Password becomeFirstResponder];
    } else if (textField == _txt_Password) {
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
    
    if ([[_txt_Email.text removeNull] isEqualToString:@""]) {
        
        Displayalert(APPLICATION_NAME, @"Please enter email", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else if (![_txt_Email.text StringIsValidEmail]) {
        
        Displayalert(APPLICATION_NAME, @"Please enter valid email id", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else if ([[_txt_Password.text removeNull] isEqualToString:@""]){
        
        Displayalert(APPLICATION_NAME, @"Please enter password", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else if (![[_txt_Password.text removeNull] isEqualToString:[_txt_ConfirmPassword.text removeNull]]){
        
        Displayalert(APPLICATION_NAME, @"Please enter correct password", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else {
        return YES;
    }
    
    return NO;
}

#pragma mark - Webservices

- (void)registerUser {
    
    //opt=register&    fname=Ajay&lname=Kumar&fb_id=76767&password=12345&cpassword=12345&email=ajay@netforce.co&contactno=9015159843&status=1&created_date=2016-5-20
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *params = [NSString stringWithFormat:@"opt=register&fname=-&lname=-&fb_id=-&password=%@&cpassword=%@&email=%@&contactno=-&status=1&created_date=%@",_txt_Password.text,_txt_Password.text,_txt_Email.text,[NSString stringWithFormat:@"%@",currentDate]];
    
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
                 NSLog(@" -------- Success -------- ");
                 
                 [[NSUserDefaults standardUserDefaults] setValue:[[[items objectForKey:@"data"] objectAtIndex:0] objectForKey:@"customer_id"] forKey:@"user_id"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [[NSUserDefaults standardUserDefaults] setValue:[[[items objectForKey:@"data"] objectAtIndex:0] objectForKey:@"cust_email"] forKey:@"email"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [[NSUserDefaults standardUserDefaults] setValue:_txt_Password.text forKey:@"password"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [THIS updateApplicationState];
                 
                 [self.navigationController setNavigationBarHidden:NO];
                 
             }else{
                 
                 Displayalert(APPLICATION_NAME,@"Username/Email does not exist. Please enter correct Username/Email" , self,[NSArray arrayWithObject:@"OK"],1)
             }
         }
         
     }];

}

@end
