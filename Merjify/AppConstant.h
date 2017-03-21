//
//  AppConstant.h
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#ifndef AppConstant_h
#define AppConstant_h


#endif /* AppConstant_h */

#define SCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width

//#define MENU_HEADER_SIZE static const CGFloat kYSLScrollMenuViewWidth = SCREEN_WIDTH==320?65:(SCREEN_WIDTH==375?80:90);


#define NAVIGATION_BAR_COLOR [UIColor colorWithRed:37/255.0f green:37/255.0f blue:44/255.0f alpha:1.0f]

#define TXT_PLACEHOLDER [UIColor colorWithRed:248.0f/255.0f green:104.0f/255.0f blue:118.0f/255.0f alpha:1.0f]

#define THIS  [AppDelegate classinstance]

#define H_RED_COLOR @"#E72940"

#define FONT_NAME @"Futura-Medium"

#define Font_Futura_Medium(sizeoffont) [UIFont fontWithName:@"Futura-Medium" size:sizeoffont]

/*  ------------  Alert title and messages  --------------   */

#define Displayalert(alerttittle,alert_message,alertview,arr,tag) [[WebDataManager sharedInstance] showAlert:alerttittle withMessage:alert_message withViewController:alertview withButtonsArr :arr withAlertViewTag :tag];


#define APPLICATION_NAME @"Mergify"


/*  ------------  AdMob  --------------   */

#define AdMobID @"ca-app-pub-3940256099942544/2934735716"

/*  ------------  AdMob  --------------   */




/*  ------------  Alert title and messages  --------------   */


///////////////////////////////////////////////////////////////
/*  ------------  Webservices List  --------------   */

#define BASEURL @"http://netforce.biz/marzify/api/services.php?"
#define BASEURL_ForgotPassword @"http://netforce.biz/marzify/api/forgotpassword.php?"



/*  ------------  Webservices List  --------------   */




/*  ------------  Soundcloud  --------------   */

#define CLIENT_ID @"7e5b3989945c3e787c1123a65d31f243"
#define CLIENT_SECRET @"cb782fe4a91ff39e4f5fcfa27ca50532"
#define REDIRECT_URI @"merjify://oauth"

#define SC_API_URL @"https://api.soundcloud.com"
#define SC_TOKEN @"SC_TOKEN"
#define SC_CODE @"SC_CODE"

/*  ------------  Soundcloud  --------------   */


/*  ------------  Spotify  --------------   */

#define S_CLIENT_ID @"eeff670707fe402e8d3a2fcd2d0f9991"
#define S_REDIRECT_URL @"merjify://"

#define kTokenSwapServiceURL "http://netforce.biz/ravitest/swap.php"
#define kTokenRefreshServiceURL "http://netforce.biz/ravitest/swap.php"
#define kSessionUserDefaultsKey "SpotifySession"

/*  ------------  Spotify  --------------   */


