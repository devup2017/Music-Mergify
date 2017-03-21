//
//  NSString+NewString.m
//  Windowloop
//
//  Created by Mac-i7 on 08/02/14.
//  Copyright (c) 2014 openxcell. All rights reserved.
//

#import "NSString+NewString.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (NewString)


#pragma  mark Validation of Text field
- (NSString *)removeNull
{
   
    if (!self) {
        return @"";
    }
    else if([self isEqualToString:@"<null>"]){
        return @"";
    }
    else if([self isEqualToString:@"(null)"]){
        return @"";
    }
    else if([self isEqualToString:@""])
        return @"";
    else{
        return self;
    }
}

-(BOOL)validatetext
{
    if([[[self removeNull] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || [[self removeNull] length]==0)
        return TRUE;
    return FALSE;
}

/*
- (NSString *)encodedURLString {
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self,
                                                                                             NULL,                   // characters to leave unescaped (NULL = all escaped sequences are replaced)
                                                                                             CFSTR("?=&+"),          // legal URL characters to be escaped (NULL = all legal characters are replaced)
                                                                                             kCFStringEncodingUTF8)); // encoding
	return result ;
}

- (NSString *)encodedURLParameterString {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self,NULL,CFSTR(":/=,!$&'()*+;[]@#?"),kCFStringEncodingUTF8));
	return result;
}

- (NSString *)decodedURLString
{
	NSString *result = (NSString*)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)self,CFSTR(""),kCFStringEncodingUTF8));
	return result;
}

-(NSString *)removeQuotes
{
	NSUInteger length = [self length];
	NSString *ret = self;
	if ([self characterAtIndex:0] == '"') {
		ret = [ret substringFromIndex:1];
	}
	if ([self characterAtIndex:length - 1] == '"') {
		ret = [ret substringToIndex:length - 2];
	}
	
	return ret;
}
*/

#pragma mark - Validate Email
-(BOOL)StringIsValidEmail
{
    if ([[self removeNull] length]==0)
        {
        return false;
        }
    NSString *emailRegex = @"^[+\\w\\.\\-']+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-zA-Z]{2,})+$";
    NSError *error= NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emailRegex options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:[self removeNull] options:0 range:NSMakeRange(0, [self removeNull].length)];
    if (numberOfMatches == 1) {
        return true;
    }
    else
    
    return false;
}

#pragma mark - Validate for Integer Number string
-(BOOL)StringIsIntigerNumber
{
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"[0-9]" options:0 error:NULL];
    NSUInteger matches = [regex numberOfMatchesInString:self options:0
                                                  range:NSMakeRange(0, [self length])];
    if (matches == [self length])
        {
        return YES;
        }
    else
        {
        return NO;
        }
}

-(BOOL)StringIsValidPhoneNumber
{
    NSString *phoneRegex = @"^+(?:[0-9] ?){6,14}[0-9]$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:self];
}
#pragma mark - Validate for Float Number string
-(BOOL)StringIsFloatNumber
{
    if([self rangeOfString:@"."].location == NSNotFound)
        {
        return NO;
        }
    else
        {
        
        NSString *regx = @"(-){0,1}(([0-9]+)(.)){0,1}([0-9]+)";
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regx];
        return [test evaluateWithObject:self];
        }
}


#pragma mark - Complete Number string
-(BOOL)StringIsComplteNumber
{
    NSString *regx = @"(-){0,1}(([0-9]+)(.)){0,1}([0-9]+)";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regx];
    return [test evaluateWithObject:self];
}


#pragma mark - alpha numeric string
-(BOOL)StringIsAlphaNumeric
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    if ([self rangeOfCharacterFromSet:set].location != NSNotFound)
        {
        return NO;
        }
    else
        {
        return YES;
        }
}


#pragma mark - illegal char in string
-(BOOL)StringWithIlligalChar
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    if ([self rangeOfCharacterFromSet:set].location != NSNotFound)
        {
        return YES;
        }
    else
        {
        return NO;
        }
}

#pragma mark -Strong Password
-(BOOL)StringWithStrongPassword:(int)minimumLength
{
    if([self length] <minimumLength)
        {
        return NO;
        }
    BOOL isCaps = FALSE;
    BOOL isNum = FALSE;
    BOOL isSymbol = FALSE;
    
    NSRegularExpression *regexCaps = [[NSRegularExpression alloc]
                                      initWithPattern:@"[A-Z]" options:0 error:NULL];
    NSUInteger intMatchesCaps = [regexCaps numberOfMatchesInString:self options:0
                                                             range:NSMakeRange(0, [self length])];
    if (intMatchesCaps > 0)
        {
        isCaps = TRUE;
        }
    
    NSRegularExpression *regexNum = [[NSRegularExpression alloc]
                                     initWithPattern:@"[0-9]" options:0 error:NULL];
    NSUInteger intMatchesNum = [regexNum numberOfMatchesInString:self options:0
                                                           range:NSMakeRange(0, [self length])];
    if (intMatchesNum > 0)
        {
        isNum = TRUE;
        }
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    if ([self rangeOfCharacterFromSet:set].location != NSNotFound)
        {
        isSymbol = TRUE;
        }
    
    if(isCaps == TRUE && isNum == TRUE && isSymbol == TRUE)
        {
        return TRUE;
        }
    else
        {
        return FALSE;
        }
}

-(float)getHeight_withFont:(UIFont *)myFont widht:(float)myWidth
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    NSString *text = self;
    UIFont *font = myFont;
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]initWithString:text
                                   attributes:@{  NSFontAttributeName: font,
                                                  NSParagraphStyleAttributeName: style
                                                  }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){myWidth, 50000}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize sizer = rect.size;
    sizer.height = ceilf(sizer.height);
    sizer.width  = ceilf(sizer.width);
    return sizer.height;
}


+(id)ParseJsonData:(NSData*)Webservicedata
{
    if ( Webservicedata!=nil) {
        return  [NSJSONSerialization JSONObjectWithData:Webservicedata options:kNilOptions error:nil];
    }
    else
    return @"";
}

+(NSString *)isKindofclass
{
    if ([self isKindOfClass:[NSString class]]) {
        return @"NSString";
    }
        
return @"";
}

/*
- (NSString *) encodeStringtoMD5 {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *result1 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [result1 appendFormat:@"%02x", result[i]];
    }
    return [NSString stringWithString:result1];
}
*/
-(void)GetAllFontFromFontFamily{
    
    for (NSString* family in [UIFont familyNames])
    {
        //NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    
}




@end
