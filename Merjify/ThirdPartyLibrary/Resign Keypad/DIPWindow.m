
#import "DIPWindow.h"


@interface DIPWindow(PrivateMethods)
@end


@implementation DIPWindow


- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
#pragma mark activity timer
- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    NSSet *allTouches = [event allTouches];
    //NSLog(@"%lu",(unsigned long)[allTouches count]);
    if ([allTouches count] > 0) {
        // To reduce timer resets only reset the timer on a Began or Ended touch.
        
        UITouch *touch = [allTouches anyObject];
        
        NSString *className = NSStringFromClass([touch.view class]);
        //NSLog(@"%@",className);
        
        if ([touch.view isKindOfClass:[UITextField class]] || [touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UITextView class]] || [className isEqualToString:@"UIWebBrowserView"]) {
            
            return;
        }
        
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan) {
            
            [self endEditing:YES];
        }
    }
}

@end
