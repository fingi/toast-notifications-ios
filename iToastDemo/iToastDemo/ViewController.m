//
//  ViewController.m
//  iToastDemo
//
//  Created by Hlung on 20/3/15.
//  Copyright (c) 2015 Hlung. All rights reserved.
//

#import "ViewController.h"
#import "iToast.h"

@interface ViewController ()
@property (strong, nonatomic) iToast *sharedToast;
@property (assign, nonatomic) int queuedToastCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showToast:(id)sender {
    iToast *t = [iToast makeText:@"This is a TOAST! A simple way to show non blocking alert."];
    [t setGravity:iToastGravityBottom];
    [t setDuration:iToastDurationNormal]; // 3 sec
    [t show];
    self.sharedToast = t;
}

- (IBAction)hideToast:(id)sender {
    [self.sharedToast dismiss];
}

- (IBAction)addToastToQueue:(id)sender {
    NSString *s = [NSString stringWithFormat:@"This is a queued TOAST #%d !", ++self.queuedToastCount];
    
    iToast *t = [iToast makeText:s];
    [t setGravity:iToastGravityBottom];
    [t setDuration:iToastDurationShort]; // 1 sec
    
    [[iToastQueue shared] queueToast:t];
}

- (IBAction)cancelAllQueuedToasts:(id)sender {
    
    [[iToastQueue shared] cancelAllQueuedToasts];
}

@end
