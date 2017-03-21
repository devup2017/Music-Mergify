//
//  CommonUtils.m
//  OCC CRM
//
//  Created by mkrsharma on 1/8/16.
//  Copyright © 2016 Shivam. All rights reserved.
//

#import "CommonUtils.h"

static CGFloat animatedDistance;

@implementation CommonUtils

static  CommonUtils *sharedInstance = nil;

+ (CommonUtils *) sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[CommonUtils alloc] init];
    }
    return sharedInstance;
}

+ (BOOL)validateEmail:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,5}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSDictionary *)removeAllNullFromDictionary : (NSDictionary *)dict
{
    NSMutableDictionary *prunedDictionary = [NSMutableDictionary dictionary];
    for (NSString * key in [dict allKeys])
    {
        if (![[dict objectForKey:key] isKindOfClass:[NSNull class]])
            [prunedDictionary setObject:[dict objectForKey:key] forKey:key];
        else
        {
            [prunedDictionary setObject:@"" forKey:key];
        }
    }
    return prunedDictionary;
}

+ (void)setMoveUp : (UIView *)contentView withView : (UIView *)view
{
    CGRect textFieldRect =[contentView.window convertRect:view.bounds fromView:view];
    CGRect viewRect =[contentView.window convertRect:contentView.bounds fromView:contentView];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = contentView.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [contentView setFrame:viewFrame];
    [UIView commitAnimations];
}

+ (void)setMoveDown : (UIView *)contentView withView : (UIView *)view
{
    CGRect viewFrame = contentView.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [contentView setFrame:viewFrame];
    [UIView commitAnimations];
}

+ (UIImage *)imageFromColor:(UIColor *)color sizeofimage:(CGRect)size {
    CGRect rect = size;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSString *)getDateStringFromTimestamp : (NSString *)strDate
{
    if (!strDate || [strDate isEqualToString:@""])
    {
        return @"";
    }
    NSDate *date = [CommonUtils getDateFromTimestamp:strDate];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    return [formatter stringFromDate:date];
}

+ (NSDate *)getDateFromTimestamp : (NSString *)strDate
{
    NSString* header = @"/Date(";
    NSInteger headerLength = [header length];
    
    NSString*  timestampString;
    
    NSScanner* scanner = [[NSScanner alloc] initWithString:strDate];
    [scanner setScanLocation:headerLength];
    [scanner scanUpToString:@")" intoString:&timestampString];
    
    NSCharacterSet* timezoneDelimiter = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
    NSRange rangeOfTimezoneSymbol = [timestampString rangeOfCharacterFromSet:timezoneDelimiter];
    
    
    if (rangeOfTimezoneSymbol.length!=0) {
        scanner = [[NSScanner alloc] initWithString:timestampString];
        
        NSRange rangeOfFirstNumber;
        rangeOfFirstNumber.location = 0;
        rangeOfFirstNumber.length = rangeOfTimezoneSymbol.location;
        
        NSRange rangeOfSecondNumber;
        rangeOfSecondNumber.location = rangeOfTimezoneSymbol.location + 1;
        rangeOfSecondNumber.length = [timestampString length] - rangeOfSecondNumber.location;
        
        NSString* firstNumberString = [timestampString substringWithRange:rangeOfFirstNumber];
//        NSString* secondNumberString = [timestampString substringWithRange:rangeOfSecondNumber];
        
        unsigned long long firstNumber = [firstNumberString longLongValue];
//        uint secondNumber = [secondNumberString intValue];
        
        NSTimeInterval interval = firstNumber/1000;
        
        return [NSDate dateWithTimeIntervalSince1970:interval];
    }
    
    unsigned long long firstNumber = [timestampString longLongValue];
    NSTimeInterval interval = firstNumber/1000;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return date;
}

+ (NSString *)stringForObject:(id)obj{
    NSString *str;
    
    if ([obj isEqualToString:@"(null)"])
        str = @"";
    else if (obj)
        str = (NSString *)obj;
    else
        str = @"";
    
    return str;
    
}

+ (NSString*)stringByTrimmingLeadingWhitespace : (NSString *)str {
    NSInteger i = 0;
    
    while ((i < [str length])
           && ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:[str characterAtIndex:i]] || ([[NSCharacterSet newlineCharacterSet] characterIsMember:[str characterAtIndex:i]])) ) {
        i++;
    }
    return [str substringFromIndex:i];
}

+ (NSDictionary *)getRGBFromColor:(UIColor *)color {
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    
    [tempDic setObject:[NSString stringWithFormat:@"%.02f",components[0]] forKey:@"Red"];
    [tempDic setObject:[NSString stringWithFormat:@"%.02f",components[1]] forKey:@"Green"];
    [tempDic setObject:[NSString stringWithFormat:@"%.02f",components[2]] forKey:@"Blue"];
    
    return tempDic;
}

+ (NSString *)getHexColorCodeFromColor:(UIColor *)color {
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    
    return hexString;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UIToolbar *)showToolBarAboveKeyboardInView:(UIView *)view {
    
    UIToolbar * numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, 50)];
    
    numberToolbar.barStyle = UIBarStyleDefault;
    
    numberToolbar.items = [NSArray arrayWithObjects: [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)], [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneNumberPad)], nil];
    
    [numberToolbar sizeToFit];
    
    return numberToolbar;
}

- (void)cancelNumberPad {
    if ([self.delegate respondsToSelector:@selector(toolBarButtonTappedWithTitle:)])
    {
        [self.delegate toolBarButtonTappedWithTitle:@"Cancel"];
    }
}

- (void)doneNumberPad {
    if ([self.delegate respondsToSelector:@selector(toolBarButtonTappedWithTitle:)])
    {
        [self.delegate toolBarButtonTappedWithTitle:@"Done"];
    }
}

+ (NSInteger )didCreateRandomNumberIfSuffleSelectedWithMaxValue:(NSInteger)maxValue andCurrentIndex:(NSInteger)currentIndex {
    
    NSInteger randomNumber = 0 + rand() % (maxValue-0);
    
    if (randomNumber == currentIndex) {
        
        randomNumber = 0 + rand() % (maxValue-0);
    }
    
    NSLog(@"randomNumber ---- %ld",(long)randomNumber);
    
    return randomNumber;
}

+ (NSArray *)shuffleArray:(NSArray *)arr
{
    NSMutableArray *arr_Suffle = [NSMutableArray arrayWithArray:arr];
    
    NSUInteger count = [arr_Suffle count];
    
    if (count > 1) {
        
        for (NSUInteger i = 0; i < count - 1; ++i) {
            NSInteger remainingCount = count - i;
            NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
            [arr_Suffle exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        }
    }
    
    return arr_Suffle;
}

+ (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

+ (NSString *)timeFormatted:(NSInteger)totalSeconds {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    //int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    
    //return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

+ (UIImage *)convertDataintoImage:(NSData *)imagedata {
    
    UIImage *img = [UIImage imageWithData:imagedata];
    
    return img;
}

- (UITextField *)getText {
    
    textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-100, 21.0)];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textField setTextColor:[UIColor whiteColor]];
    [textField setFont:[UIFont fontWithName:FONT_NAME size:12.0]];
    [textField setPlaceholder:@" Search Music"];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setReturnKeyType:UIReturnKeySearch];
    [textField setValue:[UIColor lightTextColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    [searchIcon setImage:[UIImage imageNamed:@"search"]];
    textField.leftViewMode = UITextFieldViewModeUnlessEditing;
    [textField setLeftView:searchIcon];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 21, SCREEN_WIDTH-100, 0.5)];
    [line setBackgroundColor:[UIColor lightTextColor]];
    [textField addSubview:line];
    [textField setDelegate:self];
    
    return textField;
}

- (void)showKeypadForSearchField {
    if (textField) {
        [textField becomeFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)text shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [text.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([self.searchDelegate respondsToSelector:@selector(getTextFromSearchTextField:)]) {
        [self.searchDelegate getTextFromSearchTextField:newString];
    }
    
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)text {
    [text setText:@""];
    if ([self.searchDelegate respondsToSelector:@selector(startSearch)]) {
        [self.searchDelegate startSearch];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)text {
    [text setText:@""];
    if ([self.searchDelegate respondsToSelector:@selector(endSearch)]) {
        [self.searchDelegate endSearch];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textF {
    if ([self.searchDelegate respondsToSelector:@selector(searchButtonTapped)]) {
        [self.searchDelegate searchButtonTapped];
    }
    [textF resignFirstResponder];
    return YES;
}

@end
