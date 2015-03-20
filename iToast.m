/*

iToast.m

MIT LICENSE

Copyright (c) 2011 Guru Software

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/


#import "iToast.h"
#import <QuartzCore/QuartzCore.h>

#define CURRENT_TOAST_TAG 6984678

static const CGFloat kComponentPadding = 5;

static iToastSettings *sharedSettings = nil;

@interface iToast(private)

- (iToast *) settings;
- (CGRect)_toastFrameForImageSize:(CGSize)imageSize withLocation:(iToastImageLocation)location andTextSize:(CGSize)textSize;
- (CGRect)_frameForImage:(iToastType)type inToastFrame:(CGRect)toastFrame;

@end


@implementation iToast


- (id) initWithText:(NSString *) tex{
	if (self = [super init]) {
		self.text = [tex copy];
	}
	return self;
}

- (void) show{
	[self show:iToastTypeNone];
}

- (void) show:(iToastType) type {
	
	iToastSettings *theSettings = _settings;
	
	if (!theSettings) {
		theSettings = [iToastSettings getSharedSettings];
	}
	
	UIImage *image = [theSettings.images valueForKey:[NSString stringWithFormat:@"%i", type]];
	
	UIFont *font = [UIFont systemFontOfSize:theSettings.fontSize];
    CGSize textSize = [self.text boundingRectWithSize:CGSizeMake(280, 60)
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil].size;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width , textSize.height + kComponentPadding)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = font;
	label.text = self.text;
	label.numberOfLines = 0;
    [label setTextAlignment:NSTextAlignmentCenter]; // default to center
	if (theSettings.useShadow) {
		label.shadowColor = [UIColor darkGrayColor];
		label.shadowOffset = CGSizeMake(1, 1);
	}
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	if (image) {
		btn.frame = [self _toastFrameForImageSize:image.size withLocation:[theSettings imageLocation] andTextSize:textSize];
        
        switch ([theSettings imageLocation]) {
            case iToastImageLocationLeft:
                [label setTextAlignment:NSTextAlignmentLeft];
                label.center = CGPointMake(image.size.width + kComponentPadding * 2 
                                           + (btn.frame.size.width - image.size.width - kComponentPadding * 2) / 2, 
                                           btn.frame.size.height / 2);
                break;
            case iToastImageLocationTop:
                [label setTextAlignment:NSTextAlignmentCenter];
                label.center = CGPointMake(btn.frame.size.width / 2, 
                                           (image.size.height + kComponentPadding * 2 
                                            + (btn.frame.size.height - image.size.height - kComponentPadding * 2) / 2));
                break;
            default:
                break;
        }
		
	} else {
		btn.frame = CGRectMake(0, 0, textSize.width + kComponentPadding * 2, textSize.height + kComponentPadding * 2);
		label.center = CGPointMake(btn.frame.size.width / 2, btn.frame.size.height / 2);
	}
	CGRect lbfrm = label.frame;
	lbfrm.origin.x = ceil(lbfrm.origin.x);
	lbfrm.origin.y = ceil(lbfrm.origin.y);
	label.frame = lbfrm;
	[btn addSubview:label];
	
	if (image) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.frame = [self _frameForImage:type inToastFrame:btn.frame];
		[btn addSubview:imageView];
	}
	
	btn.backgroundColor = [UIColor colorWithRed:theSettings.bgRed green:theSettings.bgGreen blue:theSettings.bgBlue alpha:theSettings.bgAlpha];
	btn.layer.cornerRadius = theSettings.cornerRadius;
	
	UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	
	CGPoint point;
	
	// Set correct orientation/location regarding device orientation
	UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
	switch (orientation) {
		case UIDeviceOrientationPortrait:
		{
			if (theSettings.gravity == iToastGravityTop) {
				point = CGPointMake(window.frame.size.width / 2, 45);
			} else if (theSettings.gravity == iToastGravityBottom) {
				point = CGPointMake(window.frame.size.width / 2, window.frame.size.height - 45);
			} else if (theSettings.gravity == iToastGravityCenter) {
				point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
			} else {
				point = theSettings.postition;
			}
			
			point = CGPointMake(point.x + theSettings.offsetLeft, point.y + theSettings.offsetTop);
			break;
		}
		case UIDeviceOrientationPortraitUpsideDown:
		{
			btn.transform = CGAffineTransformMakeRotation(M_PI);
			
			float width = window.frame.size.width;
			float height = window.frame.size.height;
			
			if (theSettings.gravity == iToastGravityTop) {
				point = CGPointMake(width / 2, height - 45);
			} else if (theSettings.gravity == iToastGravityBottom) {
				point = CGPointMake(width / 2, 45);
			} else if (theSettings.gravity == iToastGravityCenter) {
				point = CGPointMake(width/2, height/2);
			} else {
				// TODO : handle this case
				point = theSettings.postition;
			}
			
			point = CGPointMake(point.x - theSettings.offsetLeft, point.y - theSettings.offsetTop);
			break;
		}
		case UIDeviceOrientationLandscapeLeft:
		{
			btn.transform = CGAffineTransformMakeRotation(M_PI/2); //rotation in radians
			
			if (theSettings.gravity == iToastGravityTop) {
				point = CGPointMake(window.frame.size.width - 45, window.frame.size.height / 2);
			} else if (theSettings.gravity == iToastGravityBottom) {
				point = CGPointMake(45,window.frame.size.height / 2);
			} else if (theSettings.gravity == iToastGravityCenter) {
				point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
			} else {
				// TODO : handle this case
				point = theSettings.postition;
			}
			
			point = CGPointMake(point.x - theSettings.offsetTop, point.y - theSettings.offsetLeft);
			break;
		}
		case UIDeviceOrientationLandscapeRight:
		{
			btn.transform = CGAffineTransformMakeRotation(-M_PI/2);
			
			if (theSettings.gravity == iToastGravityTop) {
				point = CGPointMake(45, window.frame.size.height / 2);
			} else if (theSettings.gravity == iToastGravityBottom) {
				point = CGPointMake(window.frame.size.width - 45, window.frame.size.height/2);
			} else if (theSettings.gravity == iToastGravityCenter) {
				point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
			} else {
				// TODO : handle this case
				point = theSettings.postition;
			}
			
			point = CGPointMake(point.x + theSettings.offsetTop, point.y + theSettings.offsetLeft);
			break;
		}
		default:
			break;
	}

	btn.center = point;
	btn.frame = CGRectIntegral(btn.frame);
	
	NSTimer *timer1 = [NSTimer timerWithTimeInterval:((float)theSettings.duration)/1000 
											 target:self selector:@selector(dismiss)
										   userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
	
	btn.tag = CURRENT_TOAST_TAG;

	UIView *currentToast = [window viewWithTag:CURRENT_TOAST_TAG];
	if (currentToast != nil) {
    	[currentToast removeFromSuperview];
	}

	btn.alpha = 0;
	[window addSubview:btn];
	[UIView beginAnimations:nil context:nil];
	btn.alpha = 1;
	[UIView commitAnimations];
	
    view = btn;
    
	[btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
}

- (CGRect)_toastFrameForImageSize:(CGSize)imageSize withLocation:(iToastImageLocation)location andTextSize:(CGSize)textSize {
    CGRect theRect = CGRectZero;
    switch (location) {
        case iToastImageLocationLeft:
            theRect = CGRectMake(0, 0, 
                                 imageSize.width + textSize.width + kComponentPadding * 3, 
                                 MAX(textSize.height, imageSize.height) + kComponentPadding * 2);
            break;
        case iToastImageLocationTop:
            theRect = CGRectMake(0, 0, 
                                 MAX(textSize.width, imageSize.width) + kComponentPadding * 2, 
                                 imageSize.height + textSize.height + kComponentPadding * 3);
            
        default:
            break;
    }    
    return theRect;
}

- (CGRect)_frameForImage:(iToastType)type inToastFrame:(CGRect)toastFrame {
    iToastSettings *theSettings = _settings;
    UIImage *image = [theSettings.images valueForKey:[NSString stringWithFormat:@"%i", type]];
    
    if (!image) return CGRectZero;
    
    CGRect imageFrame = CGRectZero;

    switch ([theSettings imageLocation]) {
        case iToastImageLocationLeft:
            imageFrame = CGRectMake(kComponentPadding, (toastFrame.size.height - image.size.height) / 2, image.size.width, image.size.height);
            break;
        case iToastImageLocationTop:
            imageFrame = CGRectMake((toastFrame.size.width - image.size.width) / 2, kComponentPadding, image.size.width, image.size.height);
            break;
            
        default:
            break;
    }
    
    return imageFrame;
    
}

- (void) dismiss {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	view.alpha = 0;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeToast)];
	[UIView commitAnimations];
//	NSTimer *timer2 = [NSTimer timerWithTimeInterval:500 
//											 target:self selector:@selector(dismiss)
//										   userInfo:nil repeats:NO];
//	[[NSRunLoop mainRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
}

- (void) removeToast {
    self.isRemoved = YES;
	[view removeFromSuperview];
}


+ (iToast *) makeText:(NSString *) _text{
	iToast *toast = [[iToast alloc] initWithText:_text];
	return toast;
}


- (iToast *) setDuration:(NSInteger ) duration{
	[self theSettings].duration = duration;
	return self;
}

- (iToast *) setGravity:(iToastGravity) gravity 
			 offsetLeft:(NSInteger) left
			  offsetTop:(NSInteger) top{
	[self theSettings].gravity = gravity;
	[self theSettings].offsetLeft = left;
	[self theSettings].offsetTop = top;
	return self;
}

- (iToast *) setGravity:(iToastGravity) gravity{
	[self theSettings].gravity = gravity;
	return self;
}

- (iToast *) setPostion:(CGPoint) _position{
	[self theSettings].postition = CGPointMake(_position.x, _position.y);
	
	return self;
}

- (iToast *) setFontSize:(CGFloat) fontSize{
	[self theSettings].fontSize = fontSize;
	return self;
}

- (iToast *) setUseShadow:(BOOL) useShadow{
	[self theSettings].useShadow = useShadow;
	return self;
}

- (iToast *) setCornerRadius:(CGFloat) cornerRadius{
	[self theSettings].cornerRadius = cornerRadius;
	return self;
}

- (iToast *) setBgRed:(CGFloat) bgRed{
	[self theSettings].bgRed = bgRed;
	return self;
}

- (iToast *) setBgGreen:(CGFloat) bgGreen{
	[self theSettings].bgGreen = bgGreen;
	return self;
}

- (iToast *) setBgBlue:(CGFloat) bgBlue{
	[self theSettings].bgBlue = bgBlue;
	return self;
}

- (iToast *) setBgAlpha:(CGFloat) bgAlpha{
	[self theSettings].bgAlpha = bgAlpha;
	return self;
}


-(iToastSettings *) theSettings{
	if (!_settings) {
		_settings = [[iToastSettings getSharedSettings] copy];
	}
	
	return _settings;
}

@end


@implementation iToastSettings
@synthesize offsetLeft;
@synthesize offsetTop;
@synthesize duration;
@synthesize gravity;
@synthesize postition;
@synthesize fontSize;
@synthesize useShadow;
@synthesize cornerRadius;
@synthesize bgRed;
@synthesize bgGreen;
@synthesize bgBlue;
@synthesize bgAlpha;
@synthesize images;
@synthesize imageLocation;

- (void) setImage:(UIImage *) img withLocation:(iToastImageLocation)location forType:(iToastType) type {
	if (type == iToastTypeNone) {
		// This should not be used, internal use only (to force no image)
		return;
	}
	
	if (!images) {
		images = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
	
	if (img) {
		NSString *key = [NSString stringWithFormat:@"%i", type];
		[images setValue:img forKey:key];
	}
    
    [self setImageLocation:location];
}

- (void)setImage:(UIImage *)img forType:(iToastType)type {
    [self setImage:img withLocation:iToastImageLocationLeft forType:type];
}


+ (iToastSettings *) getSharedSettings{
	if (!sharedSettings) {
		sharedSettings = [iToastSettings new];
		sharedSettings.gravity = iToastGravityCenter;
		sharedSettings.duration = iToastDurationShort;
		sharedSettings.fontSize = 16.0;
		sharedSettings.useShadow = YES;
		sharedSettings.cornerRadius = 5.0;
		sharedSettings.bgRed = 0;
		sharedSettings.bgGreen = 0;
		sharedSettings.bgBlue = 0;
		sharedSettings.bgAlpha = 0.7;
		sharedSettings.offsetLeft = 0;
		sharedSettings.offsetTop = 0;
	}
	
	return sharedSettings;
	
}

- (id) copyWithZone:(NSZone *)zone{
	iToastSettings *copy = [iToastSettings new];
	copy.gravity = self.gravity;
	copy.duration = self.duration;
	copy.postition = self.postition;
	copy.fontSize = self.fontSize;
	copy.useShadow = self.useShadow;
	copy.cornerRadius = self.cornerRadius;
	copy.bgRed = self.bgRed;
	copy.bgGreen = self.bgGreen;
	copy.bgBlue = self.bgBlue;
	copy.bgAlpha = self.bgAlpha;
	copy.offsetLeft = self.offsetLeft;
	copy.offsetTop = self.offsetTop;
	
	NSArray *keys = [self.images allKeys];
	
	for (NSString *key in keys){
		[copy setImage:[images valueForKey:key] forType:[key intValue]];
	}
    
    [copy setImageLocation:imageLocation];
	
	return copy;
}

@end


@interface iToastQueue ()
@end

@implementation iToastQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static iToastQueue *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[iToastQueue alloc] init];
    });
    return sharedInstance;
}

- (void)queueToast:(iToast *)toast {
    iToastOperation *op = [[iToastOperation alloc] initWithToast:toast];
    [self.queue addOperation:op];
}

- (void)cancelAllQueuedToasts {
    [self.queue cancelAllOperations];
}

@end


// credit: http://www.dribin.org/dave/blog/archives/2009/05/05/concurrent_operations/
@interface iToastOperation ()
@end

@implementation iToastOperation

@synthesize isCancelled = _isCancelled;
@synthesize isExecuting = _isExecuting;
@synthesize isFinished = _isFinished;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queuePriority = NSOperationQueuePriorityNormal;
        self.qualityOfService = NSOperationQualityOfServiceUtility;
        _isCancelled = NO;
        _isExecuting = NO;
        _isFinished = NO;
    }
    return self;
}

- (instancetype)initWithToast:(iToast*)toast {
    self = [super init];
    if (self) {
        self.toast = toast;
        [self.toast addObserver:self forKeyPath:@"isRemoved" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self.toast removeObserver:self forKeyPath:@"isRemoved"];
}

// First, we have to make sure we are running on the main thread.
// Second, we have to change the isExecuting property to YES.
// Use -start instead of -main so we can manage isExecuting and isFinished.
- (void)start {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (self.isCancelled) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    if (self.isCancelled) { // safety
        return;
    }
    
    [self.toast show];
}

// need to set _isFinished = YES; otherwise the operation won't be removed from queue
- (void)cancel {
    [self willChangeValueForKey:@"isCancelled"];
    _isCancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
    
    [self.toast dismiss];
    [self finish];
}

// The key point here is that we change the isExecuting and isFinished flags. Only when these are set to NO and YES, respectively, will the operation be removed from the queue. The queue monitors their values using key-value observing.
- (void)finish {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.toast && [keyPath isEqualToString:@"isRemoved"]) {
        [self finish];
    }
}

@end
