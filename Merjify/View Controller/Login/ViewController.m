//
//  ViewController.m
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "ViewController.h"

#import "SignUpVC.h"


@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [CommonUtils setStatusBarBackgroundColor:[UIColor clearColor]];
    //[CommonUtils setStatusBarBackgroundColor:NAVIGATION_BAR_COLOR];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [_txt_Email setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
    [_txt_Password setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark IBAction

- (IBAction)btn_Action_Login:(id)sender
{

    if ([self validate]) {
        
        // hit api to login user...
        [self login];
        
    } else {
        
        // Nothing to do...
    }
}

- (IBAction)btn_Action_ForgotPassword:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:APPLICATION_NAME message:@"Please enter Email" preferredStyle:UIAlertControllerStyleAlert];
    alert.view.tag = 101;
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //NSLog(@"okButton %@",[[alert.textFields objectAtIndex:0] text]);
        
        if ([[[alert.textFields objectAtIndex:0].text removeNull] isEqualToString:@""]) {
            
            Displayalert(APPLICATION_NAME, @"Please enter Email", self,[NSArray arrayWithObject:@"OK"],1)
            
        }else if (![[[alert.textFields objectAtIndex:0].text removeNull] StringIsValidEmail]) {
            
            Displayalert(APPLICATION_NAME, @"Please enter valid Email", self,[NSArray arrayWithObject:@"OK"],1)
            
        } else{
            
            // call api for forgot password...
            [self forgotPasswordWithEmailID:[alert.textFields objectAtIndex:0].text];
        }
        
    }];
    [alert addAction:okButton];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelButton];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btn_Action_SignUp:(id)sender
{
    SignUpVC *signUp = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpVC"];
    [self.navigationController pushViewController:signUp animated:YES];
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
            
            // hit api to login user...
            [self login];
            
        } else {
            
            // Nothing to do...
        }
    }
    
    if (textField == _txt_Email) {
        [_txt_Password becomeFirstResponder];
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
        
    } else {
        return YES;
    }
    
    return NO;
}

#pragma mark - Webservices

- (void)login {
    
    //opt=login&email=ajay@netforce.co&password=123456
    
    NSString *params = [NSString stringWithFormat:@"opt=login&email=%@&password=%@",_txt_Email.text,_txt_Password.text];
    
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
                 
                 [[NSUserDefaults standardUserDefaults] setValue:[[[items objectForKey:@"data"] objectAtIndex:0] objectForKey:@"Cust_ID"] forKey:@"user_id"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [[NSUserDefaults standardUserDefaults] setValue:[[[items objectForKey:@"data"] objectAtIndex:0] objectForKey:@"email"] forKey:@"email"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [[NSUserDefaults standardUserDefaults] setValue:_txt_Password.text forKey:@"password"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [THIS updateApplicationState];
                 
                 [self.navigationController setNavigationBarHidden:NO];
                 
             }else{
                 
                 Displayalert(APPLICATION_NAME,@"Email or Password does not matched. Please enter correct Email and Password" , self,[NSArray arrayWithObject:@"OK"],1)
             }
         }
         
     }];
}

- (void)forgotPasswordWithEmailID:(NSString *)email {
    
    NSString *params = [NSString stringWithFormat:@"emailId=%@",email];
    
    //netforce.biz/marzify/api/forgotpassword.php?emailId=ajay@netforce.co
    
    NSLog(@"params ----- %@",params);
    
    [[WebDataManager sharedInstance] executeForgotPasswordWebServiceWithParamater:params withViewController:self withBlock:^(NSDictionary *items, NSError *error)
     {
         NSLog(@"%@",items);
         
         if (error) {
             
             Displayalert(APPLICATION_NAME,[error localizedDescription], self,[NSArray arrayWithObject:@"OK"],1)
             
             return;
         }
         
         if ([items isKindOfClass:[NSDictionary class]])
         {
             if ([[items objectForKey:@"Response"] isEqualToString:@"success"])
             {
                 NSLog(@" -------- Success -------- ");
                 
                 Displayalert(APPLICATION_NAME,@"Password successfully sent to the registered email." , self,[NSArray arrayWithObject:@"OK"],1)
                 
             }else{
                 
                 Displayalert(APPLICATION_NAME,@"Email does not exist. Please enter correct Email" , self,[NSArray arrayWithObject:@"OK"],1)
             }
         }
         
     }];
}

@end
