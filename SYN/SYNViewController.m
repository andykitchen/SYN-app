//
//  SYNViewController.m
//  SYN
//
//  Created by Andy Kitchen on 20/03/11.
//  Copyright 2011 GoodCode. All rights reserved.
//

#import "SYNViewController.h"

#import "AudioStreamer.h"

@implementation SYNViewController
@synthesize playPauseButton;
@synthesize pauseImage;
@synthesize playImage;
@synthesize activityIndicator;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Actions, Events, Notifications

- (IBAction)togglePlayPause
{
    [streamer pause];
}

- (IBAction)sendStudioMessage
{
    SYNMessageViewController *messageViewController =
        [[SYNMessageViewController alloc] 
         initWithNibName:@"SYNMessageViewController" bundle:nil];

    UINavigationController *navigationController =
        [[UINavigationController alloc]
            initWithRootViewController:messageViewController];

    navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.603 green:0.0 blue:0.603 alpha:1.0];
    messageViewController.delegate = self;
    
    [self presentModalViewController:navigationController animated:YES];

    [messageViewController release];
    [navigationController release];
}

- (void)remoteControlReceivedWithEvent:(UIEvent*)event
{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self togglePlayPause];
                break;
                
            default:
                break;
        }
    }   
}

- (void)playbackStateChanged:(NSNotification*)notification
{
    if ([streamer isWaiting]) {
        [self waiting];
	}
	else if ([streamer isPlaying]) {
        [self playing];
	}
	else if ([streamer isPaused]) {
        [self paused];
	}
	else if ([streamer isIdle]) {
        [self paused];
	}
}

- (void)waiting
{
    [self.activityIndicator startAnimating];
    [self setButtonImage:self.playImage];
}

- (void)playing
{
    [self.activityIndicator stopAnimating];
    [self setButtonImage:self.pauseImage];
}

- (void)paused
{
    [self setButtonImage:self.playImage];
}

- (void)setButtonImage:(UIImageView*)imageView {
    [self.playPauseButton setBackgroundImage:imageView.image forState:UIControlStateNormal];
}

- (void)cancelMessage
{
    [self dismissModalViewControllerAnimated:YES];
}
     
 - (void)sendMessage:(NSString *)message
{
    NSLog(@"%@", message);
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://syn.gravityrail.net:8000/syn"];
	streamer = [[AudioStreamer alloc] initWithURL:url];
    [url release];
    
    [streamer start];
    
    [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(playbackStateChanged:)
         name:ASStatusChangedNotification
         object:streamer];

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    if (self.playImage == Nil) {
        UIImage *playImageIcon = [playPauseButton backgroundImageForState:UIControlStateNormal];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:playImageIcon];
        self.playImage = imageView;
        [imageView release];
    }
    
    [self playing];
    [self.activityIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self becomeFirstResponder];    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self resignFirstResponder];
}


- (void)viewDidUnload
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];

    [self setPauseImage:nil];
    [self setPlayImage:nil];
    [streamer release];

    [self setPlayPauseButton:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [pauseImage release];
    [playImage  release];
    [playPauseButton release];
    [activityIndicator release];
    [super dealloc];
}
@end
