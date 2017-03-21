//
//  ProfileVC.m
//  Mergify
//
//  Created by Abhishek Kumar on 12/10/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "ProfileVC.h"

@interface ProfileVC ()
{
    NSData *imgData;
}
@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Profile";
    [_txt_Name setValue:TXT_PLACEHOLDER forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)viewDidLayoutSubviews {
    
    _img_Profile.layer.cornerRadius = _img_Profile.frame.size.width/2;
    _img_Profile.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)btn_Action_Update:(id)sender
{
    
}

- (IBAction)btn_Action_Profile:(id)sender
{
    [WebDataManager sharedInstance].delegate = self;
    [[WebDataManager sharedInstance] showAlert:APPLICATION_NAME withMessage:@"Please set your profile image" withViewController:self withButtonsArr:[NSArray arrayWithObjects:@"Camera",@"Photo Library",@"Cancel", nil] withAlertViewTag:101];
}

#pragma mark - WebDataManagerDelegate

- (void)alertViewButtonClicked:(NSInteger)buttonIndex withAlertViewTag:(NSInteger)alertViewTag {
    
    if (alertViewTag == 101) {
        
        switch (buttonIndex){
            case 0:
                [self getCameraPicture];
                break;
            case 1:
                [self getPhotoLibrary];
                break;
            default:
                break;
        }
    } else {
        
    }
}

-(void)getCameraPicture{
    
    if([UIImagePickerController isSourceTypeAvailable:
        UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        
        Displayalert(APPLICATION_NAME, @"Camera Not Available!!", self,[NSArray arrayWithObject:@"OK"],0)
    }
}

-(void)getPhotoLibrary {
    if([UIImagePickerController isSourceTypeAvailable:
        UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *picker= [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage* )image editingInfo:(NSDictionary *)editInfo{
    
    //_img_Placeholder.image = image;
    
    [_img_Profile setImage:image];
    
    imgData = UIImageJPEGRepresentation(image, 0.1f);
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
    
    [textField resignFirstResponder];
    
    return  YES;
}

#pragma mark - Private Method

- (BOOL)validate {
    
    [self.view endEditing:YES];
    
    if ([[_txt_Name.text removeNull] isEqualToString:@""]) {
        
        Displayalert(APPLICATION_NAME, @"Please enter name", self,[NSArray arrayWithObject:@"OK"],1)
        
    } else {
        return YES;
    }
    
    return NO;
}

#pragma mark - Webservices

- (void)registerUser {
    
    return;
    
    NSDictionary *params = @{@"opt":@"qwe", @"name":_txt_Name.text};
    
    NSLog(@"%@",params);
    
    if (imgData == nil) {
        imgData = UIImageJPEGRepresentation(_img_Profile.image, 0.1f);
    }
    
    [[WebDataManager sharedInstance] executeWebServiceDataUploadWithParamater:params withImage:imgData withViewController:self withName:@"uploadedfile" fileName:@"test.png" mimeType:@"image/jpeg" withBlock:^(NSDictionary *items, NSError *error) {
        
        if (error) {
            
            Displayalert(APPLICATION_NAME,[error localizedDescription] , self,[NSArray arrayWithObject:@"OK"],1)
            
            return;
        }
        
        NSLog(@"%@",items);
        
        if ([items isKindOfClass:[NSDictionary class]])
        {
            if ([[items objectForKey:@"status"] isEqualToString:@"Success"])
            {
                NSLog(@" -------- Success ----------- ");
                
                Displayalert(APPLICATION_NAME,@"Profile updated successfully." , self,[NSArray arrayWithObject:@"OK"],1)
                
            }else{
                
                Displayalert(APPLICATION_NAME,@"Unable to update profile." , self,[NSArray arrayWithObject:@"OK"],1)
            }
        }
        
    }];
    
}

@end
