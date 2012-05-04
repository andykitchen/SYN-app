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
    UIImageView *pauseImage;
    UIImageView *playImage;
    UIButton *playPauseButton;
}
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UIImageView *pauseImage;
@property (nonatomic, retain) IBOutlet UIImageView *playImage;

- (IBAction)togglePlayPause;

- (void)cancelMessage;
- (void)sendMessage:(NSString *)message;
- (void)playing;
- (void)paused;

@end
