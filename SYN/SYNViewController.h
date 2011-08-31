//
//  SYNViewController.h
//  SYN
//
//  Created by Andy Kitchen on 20/03/11.
//  Copyright 2011 GoodCode. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNMessageViewController.h"

@class AudioStreamer;

@interface SYNViewController : UIViewController <SYNMessageDelegate> {
    AudioStreamer *streamer;
    UILabel *statusLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

- (IBAction)togglePlayPause;

- (void)cancelMessage;
- (void)sendMessage:(NSString *)message;

@end
