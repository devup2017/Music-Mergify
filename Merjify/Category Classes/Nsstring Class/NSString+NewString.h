//
//  NSString+NewString.h
//  Windowloop
//
//  Created by Mac-i7 on 08/02/14.
//  Copyright (c) 2014 openxcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NewString)

    // This method remove null value from current string object..
-(NSString *)removeNull;

    // this method validat your string from nil or null....
-(BOOL)validatetext;

/*
- (NSString *)encodedURLString;
- (NSString *)encodedURLParameterString;
- (NSString *)decodedURLString;
- (NSString *)removeQuotes;
*/

+(NSString *)isKindofclass;

    //Validate Email
-(BOOL)StringIsValidEmail;
    //Validate for Integer Number string
-(BOOL)StringIsIntigerNumber;
    //Validate for Float Number string
-(BOOL)StringIsFloatNumber;
    //Complete Number string
-(BOOL)StringIsComplteNumber;
    //alpha numeric string
-(BOOL)StringIsAlphaNumeric;
    //illegal char in string
-(BOOL)StringWithIlligalChar;
-(BOOL)StringIsValidPhoneNumber;
    //Strong Password
-(BOOL)StringWithStrongPassword:(int)minimumLength;

-(float)getHeight_withFont:(UIFont *)myFont widht:(float)myWidth;

    // Parse JSON data
+(id)ParseJsonData:(NSData*)Webservicedata;

    // MD5 Encodeing of a string
//- (NSString *) encodeStringtoMD5;

@end
