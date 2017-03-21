//
//  WebDataManager.h
//  UrScene
//
//  Created by akhsingh on 7/21/14.
//  Copyright (c) 2014 James Musser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

typedef void (^FetchBlock)(NSDictionary *items, NSError *error);

@protocol WebDataManagerDelegate <NSObject>

@optional
-(void)alertViewButtonClicked : (NSInteger)buttonIndex withAlertViewTag : (NSInteger)alertViewTag;

@end

@interface WebDataManager : NSObject

@property (nonatomic, strong)id <WebDataManagerDelegate>delegate;

+ (WebDataManager *) sharedInstance;

- (void)cancelAllOperations;

- (void)startActivityIndicator;

- (void)stopActivityIndicator;

- (void)showAlert : (NSString *)title withMessage : (NSString *)message withViewController : (UIViewController *)controller withButtonsArr : (NSArray *)buttonArr withAlertViewTag : (NSInteger)tag;


- (void)executeWebServiceWithParamater:(NSDictionary *)params withViewController : (UIViewController *)controller withBlock:(FetchBlock)block;

- (void)executeForgotPasswordWebServiceWithParamater:(NSString *)params withViewController : (UIViewController *)controller withBlock:(FetchBlock)block;

- (void)renewSession:(NSDictionary *)params withBlock:(FetchBlock)block;

- (void)executeWebServiceDataUploadWithParamater:(NSDictionary *)params withImage:(NSData *)imageData withViewController:(UIViewController *)controller withName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType  withBlock:(FetchBlock)block;

- (void)executeGETWebServiceWithParamater:(NSString *)params withViewController:(UIViewController *)controller withBlock:(FetchBlock)block;

- (void)executePOSTWebServiceWithParamater:(NSDictionary *)params withFunctionName:(NSString *)apiName withViewController : (UIViewController *)controller withBlock:(FetchBlock)block;

// hit api without using AFNetworking...
- (void)executeWebServiceWithFunction:(NSString *)functionName andParamater:(NSString *)params withViewController : (UIViewController *)controller withBlock:(FetchBlock)block;

// Soundcloud APIs calling method...
- (void)executeCallWithParamater:(NSString *)params withViewController:(UIViewController *)controller withBlock:(FetchBlock)block;


@end
