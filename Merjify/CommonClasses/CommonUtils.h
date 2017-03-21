//
//  CommonUtils.h
//  OCC CRM
//
//  Created by mkrsharma on 1/8/16.
//  Copyright © 2016 Shivam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;


@protocol CommonUtilsDelegate <NSObject>

@optional
- (void)toolBarButtonTappedWithTitle:(NSString *)titleStr;

@end


@protocol SearchTextViewDelegate <NSObject>

@optional
- (void)getTextFromSearchTextField:(NSString *)txt;
- (void)startSearch;
- (void)endSearch;
- (void)searchButtonTapped;
@end


@interface CommonUtils : NSObject<UITextFieldDelegate>
{
    UITextField *textField;
}


+ (CommonUtils *) sharedInstance;

@property (nonatomic, weak) id <SearchTextViewDelegate> searchDelegate;

@property (nonatomic, weak) id <CommonUtilsDelegate>delegate;

+ (BOOL)validateEmail:(NSString*)email;

+ (void)setMoveUp : (UIView *)contentView withView : (UIView *)view;

+ (void)setMoveDown : (UIView *)contentView withView : (UIView *)view;

+ (NSDictionary *)removeAllNullFromDictionary : (NSDictionary *)dict;

+ (UIImage *)imageFromColor:(UIColor *)color sizeofimage:(CGRect)size;

+ (NSString *)getDateStringFromTimestamp : (NSString *)strDate;

+ (NSDate *)getDateFromTimestamp : (NSString *)strDate;

+ (NSString *)stringForObject:(id)obj;

+ (NSString *)stringByTrimmingLeadingWhitespace:(NSString *)str;

+ (NSDictionary *)getRGBFromColor:(UIColor *)color;

+ (NSString *)getHexColorCodeFromColor:(UIColor *)color;

+ (UIColor *)colorFromHexString:(NSString *)hexString;

- (UIToolbar *)showToolBarAboveKeyboardInView:(UIView *)view;

+ (NSInteger )didCreateRandomNumberIfSuffleSelectedWithMaxValue:(NSInteger)maxValue andCurrentIndex:(NSInteger)currentIndex;

//+ (NSArray *)shuffleArray:(NSArray *)arr;

+ (void)setStatusBarBackgroundColor:(UIColor *)color;

+ (NSString *)timeFormatted:(NSInteger)totalSeconds;

+ (UIImage *)convertDataintoImage:(NSData *)imagedata;

- (UITextField *)getText;

- (void)showKeypadForSearchField;

@end
