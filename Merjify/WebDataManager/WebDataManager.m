//
//  WebDataManager.m
//  UrScene
//
//  Created by akhsingh on 7/21/14.
//  Copyright (c) 2014 James Musser. All rights reserved.
//



#import "WebDataManager.h"

#import "AFNetworking.h"

@interface WebDataManager()
{
    NSOperationQueue *operationQueue;
}

@end

@implementation WebDataManager

static  WebDataManager *sharedInstance = nil;

+ (WebDataManager *) sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[WebDataManager alloc] init];
    }
    return sharedInstance;
}

- (id)init;
{
    if (self = [super init])
    {
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}


- (NSString*)stringByTrimmingLeadingWhitespace : (NSString *)str {
    NSInteger i = 0;
    
    while ((i < [str length])
           && ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:[str characterAtIndex:i]] || ([[NSCharacterSet newlineCharacterSet] characterIsMember:[str characterAtIndex:i]])) ) {
        i++;
    }
    return [str substringFromIndex:i];
}

- (void)cancelAllOperations
{
    [operationQueue cancelAllOperations];
}

-(void)startActivityIndicator
{
    [MBProgressHUD showHUDAddedTo:THIS.window animated:YES];
}

-(void)stopActivityIndicator
{
    [MBProgressHUD hideAllHUDsForView:THIS.window animated:YES];
}

-(BOOL)checkNetworkConnection
{
    return THIS.IsReachable;
}

-(void)showAlert : (NSString *)title withMessage : (NSString *)message withViewController : (UIViewController *)controller withButtonsArr : (NSArray *)buttonArr withAlertViewTag : (NSInteger)tag
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    alert.view.tag = tag;
    int i = 0;
    for (NSString *str in buttonArr) {
        
        
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         
            
            if ([self.delegate respondsToSelector:@selector(alertViewButtonClicked:withAlertViewTag:)])
            {
                [self.delegate alertViewButtonClicked:i withAlertViewTag:tag];
            }
        }];
        
        [alert addAction:okButton];
        i++;
    }
    
    [controller presentViewController:alert animated:YES completion:nil];
    
}

- (void)executeWebServiceWithParamater:(NSDictionary *)params withViewController:(UIViewController *)controller withBlock:(FetchBlock)block
{
    //if ([self checkNetworkConnection])
    //{
            
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml",@"text/xml",@"text/html",@"text/plain",@"application/json"]];
        
        [manager GET:[NSString stringWithFormat:@"http://netforce.biz/ravitest/swap.php"] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
           // NSLog(@"JSON: %@", responseObject);
            
            [self stopActivityIndicator];
            
            if (responseObject)
            {
                block(responseObject,nil);
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            
           // NSLog(@"Error: %@", error);
            
            if (error)
            {
                block(nil,error);
            }
            
            /*
            NSString *receivedString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
            NSLog(@"Received Data in error ---->%@",receivedString);
            
            NSLog(@"Error: %@", error);
            
            if (failureBlock != nil) {
                failureBlock(error);
            }
            */
        }];
    
    //}else{
        
         //Displayalert(APPLICATION_NAME, @"Network not found", controller,[NSArray arrayWithObject:@"OK"],1)
    //}
}

- (void)executeForgotPasswordWebServiceWithParamater:(NSString *)params withViewController : (UIViewController *)controller withBlock:(FetchBlock)block {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml",@"text/xml",@"text/html",@"text/plain",@"application/json"]];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",BASEURL_ForgotPassword,params] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        [self stopActivityIndicator];
        
        if (responseObject)
        {
            block(responseObject,nil);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        if (error)
        {
            block(nil,error);
        }
    }];
    
}

- (void)deleteSpotifySong:(NSDictionary *)params withBlock:(FetchBlock)block
{
    //if ([self checkNetworkConnection])
    //{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml",@"text/xml",@"text/html",@"text/plain",@"application/json"]];
    
    [manager DELETE:[NSString stringWithFormat:@"https://api.spotify.com/v1/users/%@/playlists/%@/tracks",[params valueForKey:@"userID"],[params valueForKey:@"playlist"]] parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // NSLog(@"JSON: %@", responseObject);
        
        [self stopActivityIndicator];
        
        if (responseObject)
        {
            block(responseObject,nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error)
        {
            block(nil,error);
        }
        
    }];
    
}

- (void)renewSession:(NSDictionary *)params withBlock:(FetchBlock)block
{
    //if ([self checkNetworkConnection])
    //{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml",@"text/xml",@"text/html",@"text/plain",@"application/json"]];
    
    [manager GET:[NSString stringWithFormat:@"http://netforce.biz/ravitest/swap.php"] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        // NSLog(@"JSON: %@", responseObject);
        
        [self stopActivityIndicator];
        
        if (responseObject)
        {
            block(responseObject,nil);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        // NSLog(@"Error: %@", error);
        
        if (error)
        {
            block(nil,error);
        }
        
        /*
         NSString *receivedString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
         NSLog(@"Received Data in error ---->%@",receivedString);
         
         NSLog(@"Error: %@", error);
         
         if (failureBlock != nil) {
         failureBlock(error);
         }
         */
    }];
    
    //}else{
    
    //Displayalert(APPLICATION_NAME, @"Network not found", controller,[NSArray arrayWithObject:@"OK"],1)
    //}
}

// Soundcloud APIs calling method...
- (void)executeCallWithParamater:(NSString *)params withViewController:(UIViewController *)controller withBlock:(FetchBlock)block {
    
    if ([self checkNetworkConnection])
    {
        [self startActivityIndicator];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml",@"text/xml",@"text/plain",@"application/json"]];
        
        NSLog(@"SC_API_URL ----->>>>> %@",[NSString stringWithFormat:@"%@%@",SC_API_URL,params]);
        
        [manager GET:[NSString stringWithFormat:@"%@%@",SC_API_URL,params] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            //NSLog(@"JSON: %@", responseObject);
            
            [self stopActivityIndicator];
            
            if (responseObject)
            {
                block(responseObject,nil);
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            
            [self stopActivityIndicator];
            
            NSLog(@"Error: %@", error);
            
            if (error)
            {
                block(nil,error);
            }
            
        }];
        
    }else{
        
        Displayalert(APPLICATION_NAME, @"Network not found", controller,[NSArray arrayWithObject:@"OK"],1)
    }
    
}

- (void)executeWebServiceDataUploadWithParamater:(NSDictionary *)params withImage:(NSData *)imageData withViewController:(UIViewController *)controller withName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType  withBlock:(FetchBlock)block
{
    if ([self checkNetworkConnection])
    {
        
        [self startActivityIndicator];
        
        NSLog(@"BASEURL: %@", [NSString stringWithFormat:@"%@",BASEURL]);
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:BASEURL parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:mimeType];
            
        } error:nil];
        
        //[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
        
        
        //        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml",@"text/xml",@"text/html",@"text/plain",@"application/json"]];
        
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
            
            // This is not called back on the main queue.
            // You are responsible for dispatching to the main queue for UI updates
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update the progress view
                
                //[progressView setProgress:uploadProgress.fractionCompleted];
            });
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            [self stopActivityIndicator];
            
            
            if (error) {
                
                NSLog(@"Error: %@", [error localizedDescription]);
                
                block(nil,error);
                
                /*
                 if (!error)
                 {
                 block(nil,error);
                 }
                 */
            } else {
                
                NSString *returnString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                NSLog(@"%@",returnString);
                
                NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                
                NSLog(@"-------Success------ %@",dict);
                
                if (dict)
                {
                    block(dict,nil);
                }
            }
        }];
        
        [uploadTask resume];
        
    }else{
        
        Displayalert(APPLICATION_NAME, @"Network not found", controller,[NSArray arrayWithObject:@"OK"],1)
    }
}

- (void)executeGETWebServiceWithParamater:(NSString *)params withViewController:(UIViewController *)controller withBlock:(FetchBlock)block
{
    if ([self checkNetworkConnection])
    {
        
        [self startActivityIndicator];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml",@"text/xml",@"text/html",@"text/plain",@"application/json"]];
        
        NSLog(@"%@",[NSString stringWithFormat:@"%@%@",BASEURL,params]);
        
        [manager GET:[NSString stringWithFormat:@"%@%@",BASEURL,params] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            
            [self stopActivityIndicator];
            
            if (responseObject)
            {
                block(responseObject,nil);
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            
            [self stopActivityIndicator];
            
            //NSString *receivedString = [[NSString alloc] initWithData:operation.response encoding:NSUTF8StringEncoding];
            
            //NSLog(@"Received Data in error ---->%@",receivedString);
            
            NSLog(@"Error: %@", [error localizedDescription]);
            
            if (error)
            {
                block(nil,error);
            }
        }];
        
    }else{
        
        Displayalert(APPLICATION_NAME, @"Network not found", controller,[NSArray arrayWithObject:@"OK"],1)
    }
}

- (void)executePOSTWebServiceWithParamater:(NSDictionary *)params withFunctionName:(NSString *)apiName withViewController : (UIViewController *)controller withBlock:(FetchBlock)block
{
    if ([self checkNetworkConnection])
    {
        [self startActivityIndicator];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html"]];
        
        [manager POST:@"http://netforce.biz/marzify/api/test.php" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            
            [self stopActivityIndicator];
            
            if (responseObject)
            {
                block(responseObject,nil);
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            
            NSLog(@"Error: %@", error);
            
            if (!error)
            {
                block(nil,error);
            }
            
            NSLog(@"Error: %@", error);
            
            
        }];
        
    }else{
        
        Displayalert(APPLICATION_NAME, @"Network not found", controller,[NSArray arrayWithObject:@"OK"],1)
    }
}

// hit api without using AFNetworking...

- (void)executeWebServiceWithFunction:(NSString *)functionName andParamater:(NSString *)params withViewController : (UIViewController *)controller withBlock:(FetchBlock)block
{
    if ([self checkNetworkConnection])
    {
        NSError *error = nil;
//        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
        
        NSData* jsonData = [params dataUsingEncoding:NSUTF8StringEncoding];
        
        //NSString* encodedUrl = [@"http://netforce.biz/marzify/api/test.php" stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
        
        NSString* encodedUrl = @"http://netforce.biz/marzify/api/test.php";
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
        [request setHTTPMethod:@"POST"];
        
        if (error == nil)
        {
            [request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setHTTPBody:jsonData];
            
            [self startActivityIndicator];
            
            [request setTimeoutInterval:arc4random_uniform(220)];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse   * _Nullable response, NSData*  _Nullable data, NSError * _Nullable connectionError) {
                
                if (error == nil) {
                    if(data)
                    {
                        NSError *err;
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                        
                        //NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        
                        [self stopActivityIndicator];
                        if (dic)
                        {
                            block(dic,nil);
                        }
                        else if (err) {
                            block(nil,err);
                        }
                    }
                    else{
                        [self stopActivityIndicator];
                    }
                }else{
                    //NSError *err;
                    //NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                    
                    NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    NSLog(@"receivedString in error ----- %@",receivedString);
                    
                    [self stopActivityIndicator];
                    
                    Displayalert(APPLICATION_NAME, @"aaa", controller,[NSArray arrayWithObject:@"OK"],1)
                    
                    
                }
            }];
        }
        else
        {
            Displayalert(APPLICATION_NAME, @"aaa", controller,[NSArray arrayWithObject:@"OK"],1)
        }
        
    }else{
        
        Displayalert(APPLICATION_NAME, @"NETWORK_NOT_FOUND", controller,[NSArray arrayWithObject:@"OK"],1)
    }
    
    /*
     NSError *error = nil;
     NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
     
     NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     NSLog(@"jsonString: %@", jsonString);
     
     NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
     
     NSMutableData *body = [NSMutableData data];
     [body appendData:requestData];
     
     NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
     
     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@users/signup",BASEURL1]];
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
     [request setHTTPMethod:@"POST"];
     [request setHTTPShouldHandleCookies:NO];
     
     [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
     
     [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
     [request setHTTPBody:body];
     
     NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
     [[session dataTaskWithRequest:request
     completionHandler:^(NSData *data,
     NSURLResponse *response,
     NSError *error)
     {
     if (error) {
     NSLog(@"%@",error);
     } else {
     NSDictionary * jsonDic =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
     NSLog(@"%@",jsonDic);
     if ([jsonDic objectForKey:@"error"]) {
     
     }
     else{
     
     }
     
     }
     }] resume];
     */
}

@end
