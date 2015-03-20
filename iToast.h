/*

iToast.h

MIT LICENSE

Copyright (c) 2012 Guru Software

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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum iToastGravity {
	iToastGravityTop = 1000001,
	iToastGravityBottom,
	iToastGravityCenter
}iToastGravity;

typedef enum iToastDuration {
	iToastDurationLong = 10000,
	iToastDurationShort = 1000,
	iToastDurationNormal = 3000
}iToastDuration;

typedef enum iToastType {
	iToastTypeInfo = -100000,
	iToastTypeNotice,
	iToastTypeWarning,
	iToastTypeError,
	iToastTypeNone // For internal use only (to force no image)
}iToastType;

typedef enum {
    iToastImageLocationTop,
    iToastImageLocationLeft
} iToastImageLocation;


@class iToastSettings;

@interface iToast : NSObject {
	iToastSettings *_settings;
	
	NSTimer *timer;
	
	UIView *view;
	
}

@property (assign, nonatomic) BOOL isRemoved;
@property (copy, nonatomic) NSString *text;

- (void) show;
- (void) show:(iToastType) type;
- (void) dismiss;
- (iToast *) setDuration:(NSInteger ) duration;
- (iToast *) setGravity:(iToastGravity) gravity 
			 offsetLeft:(NSInteger) left
			 offsetTop:(NSInteger) top;
- (iToast *) setGravity:(iToastGravity) gravity;
- (iToast *) setPostion:(CGPoint) position;
- (iToast *) setFontSize:(CGFloat) fontSize;
- (iToast *) setUseShadow:(BOOL) useShadow;
- (iToast *) setCornerRadius:(CGFloat) cornerRadius;
- (iToast *) setBgRed:(CGFloat) bgRed;
- (iToast *) setBgGreen:(CGFloat) bgGreen;
- (iToast *) setBgBlue:(CGFloat) bgBlue;
- (iToast *) setBgAlpha:(CGFloat) bgAlpha;

+ (iToast *) makeText:(NSString *) text;

- (iToastSettings *) theSettings;

@end



@interface iToastSettings : NSObject<NSCopying>{
	NSInteger duration;
	iToastGravity gravity;
	CGPoint postition;
	iToastType toastType;
	CGFloat fontSize;
	BOOL useShadow;
	CGFloat cornerRadius;
	CGFloat bgRed;
	CGFloat bgGreen;
	CGFloat bgBlue;
	CGFloat bgAlpha;
	NSInteger offsetLeft;
	NSInteger offsetTop;

	NSDictionary *images;
	
	BOOL positionIsSet;
}


@property(assign) NSInteger duration;
@property(assign) iToastGravity gravity;
@property(assign) CGPoint postition;
@property(assign) CGFloat fontSize;
@property(assign) BOOL useShadow;
@property(assign) CGFloat cornerRadius;
@property(assign) CGFloat bgRed;
@property(assign) CGFloat bgGreen;
@property(assign) CGFloat bgBlue;
@property(assign) CGFloat bgAlpha;
@property(assign) NSInteger offsetLeft;
@property(assign) NSInteger offsetTop;
@property(readonly) NSDictionary *images;
@property(assign) iToastImageLocation imageLocation;


- (void) setImage:(UIImage *)img forType:(iToastType) type;
- (void) setImage:(UIImage *)img withLocation:(iToastImageLocation)location forType:(iToastType)type;
+ (iToastSettings *) getSharedSettings;
						  
@end

#pragma mark - queuing mechanism

// Allow multiple toasts to queue up and show the next one when the one before it has dismissed.

// Usage: create a toast as normally, but don't call -show on it. Instead, add it to -queueToast:.
// Example:
// iToast *t = [iToast makeText:@"This is a queued TOAST!"];
// [[iToastQueue shared] queueToast:t]

@interface iToastQueue : NSObject
@property (strong, nonatomic) NSOperationQueue *queue;
+ (instancetype)shared;
- (void)queueToast:(iToast*)toast;
- (void)cancelAllQueuedToasts;
@end

@interface iToastOperation : NSOperation

// re-declared NSOperation variable so we can set it
@property (readonly) BOOL isCancelled;
// re-declared NSOperation variable so we can set it
@property (readonly) BOOL isExecuting;
// re-declared NSOperation variable so we can set it
@property (readonly) BOOL isFinished;

@property (strong, nonatomic) iToast *toast;

- (instancetype)initWithToast:(iToast*)toast;

@end

