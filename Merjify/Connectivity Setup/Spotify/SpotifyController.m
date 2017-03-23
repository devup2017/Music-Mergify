//
//  SpotifyController.m
//  Merjify
//
//  Created by Abhishek Kumar on 21/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import "SpotifyController.h"

#define S(s) @#s

@implementation SpotifyController

- (void)logIn {
    
    [self spotifySetup];
    
    //[[UIApplication sharedApplication] openURL:[SPTAuth defaultInstance].loginURL];
    
    NSLog(@"System Version is %@",[[UIDevice currentDevice] systemVersion]);
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    if (ver_float < 10.0){
        [[UIApplication sharedApplication] openURL:[SPTAuth defaultInstance].spotifyWebAuthenticationURL];
    }else {
        [[UIApplication sharedApplication] openURL:[SPTAuth defaultInstance].spotifyWebAuthenticationURL options:nil completionHandler:nil];
    }
    
}

- (void)spotifySetup {
    
    self.scopes = @[SPTAuthStreamingScope,SPTAuthPlaylistModifyPublicScope,SPTAuthPlaylistModifyPrivateScope, SPTAuthUserReadPrivateScope, SPTAuthUserReadEmailScope];
    //self.scopeDisplayNames = @[S(SPTAuthUserReadPrivateScope), S(SPTAuthUserReadEmailScope)];
    //self.selectedScopes = [NSMutableArray new];
    
    [[SPTAuth defaultInstance] setClientID:S_CLIENT_ID];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:S_REDIRECT_URL]];
    [[SPTAuth defaultInstance] setRequestedScopes:self.scopes];
    
    [SPTAuth defaultInstance].tokenSwapURL = [NSURL URLWithString:@kTokenSwapServiceURL];
    [SPTAuth defaultInstance].tokenRefreshURL = [NSURL URLWithString:@kTokenRefreshServiceURL];
    [SPTAuth defaultInstance].sessionUserDefaultsKey = @kSessionUserDefaultsKey;
    
    
    if (S_CLIENT_ID.length == 0 || S_REDIRECT_URL.length == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Details!" message:@"This app will not work until you fill in your " "Client ID and Callback URL in the constants at the top " "of AppDelegate.m.\n\n For more information, consult the " "SDK's documentation or the Spotify developer website." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDefault handler:nil]];
        
    } else {
        // Check the Info.plist for auth callback
        BOOL found = NO;
        for (NSDictionary *handler in [[NSBundle mainBundle] infoDictionary][@"CFBundleURLTypes"]) {
            NSArray *schemes = handler[@"CFBundleURLSchemes"];
            for (NSString *scheme in schemes) {
                if ([S_REDIRECT_URL hasPrefix:scheme]) {
                    found = YES;
                    break;
                }
            }
        }
        
        if (!found) {
            
            NSString *callbackURLPrefix = [[S_REDIRECT_URL componentsSeparatedByString:@":"] firstObject];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Callback URL Handler!" message:[NSString stringWithFormat:@"This demo app will not work until " "you add your client callback's URL scheme (the '%@' part of '%@') " "to the application's handled URL types, either in the target's " "'Info' pane or directly in the Info.plist file.\n\n " "For more information, consult the SDK's documentation or the " "Spotify developer website.", callbackURLPrefix, S_REDIRECT_URL] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDefault handler:nil]];
            
        }
    }
    
}

@end
