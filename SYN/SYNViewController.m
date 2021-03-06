//
//  SYNViewController.m
//  SYN
//
//  Created by Andy Kitchen on 20/03/11.
//  Copyright 2011 GoodCode. All rights reserved.
//

#import "SYNViewController.h"

#import "SYNMessage.h"
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
    if([streamer isIdle]) {
        NSLog(@"reinit streamer");
        [streamer release];
        [self initStreamer];
    } 
    else {
        NSLog(@"toggle play/pause");
        [streamer pause];
    }
}

- (void)stopIfPaused
{
    if([streamer isPaused]) {
        [streamer stop];
        [self.activityIndicator stopAnimating];
    }
}

- (IBAction)sendStudioMessage
{
    SYNMessageViewController *messageViewController =
        [[SYNMessageViewController alloc] 
         initWithNibName:@"SYNMessageViewController" bundle:nil];

    UINavigationController *navigationController =
        [[UINavigationController alloc]
            initWithRootViewController:messageViewController];

    navigationController.navigationBar.tintColor =
        [UIColor colorWithRed:0.603 green:0.0 blue:0.603 alpha:1.0];

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
        NSLog(@"waiting...");
        [self waiting];
	}
	else if ([streamer isPlaying]) {
        NSLog(@"playing...");
        [self playing];
	}
	else if ([streamer isPaused]) {
        NSLog(@"paused...");
        [self paused];
	}
	else if ([streamer isIdle]) {
        NSLog(@"idle...");
        [self paused];
	}
    else {
        NSLog(@"unknown: %d", streamer.state);
        [self paused];
    }
}

- (void)waiting
{
    [self.activityIndicator startAnimating];
    //[self setButtonImage:self.playImage];
}

- (void)playing
{
    [self.activityIndicator stopAnimating];
    [self setButtonImage:self.pauseImage];
}

- (void)paused
{
    [self.activityIndicator stopAnimating];
    [self setButtonImage:self.playImage];
}

- (void)setButtonImage:(UIImageView*)imageView {
    [self.playPauseButton setImage:imageView.image forState:UIControlStateNormal];
}

- (void)cancelMessage
{
    [self dismissModalViewControllerAnimated:YES];
}
     
 - (void)sendMessage:(NSString *)messageStr
{
    SYNMessage *message = [[SYNMessage alloc] initWithString:messageStr];
    [message send];
    [message release];
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - View lifecycle

- (void)initStreamer
{
    NSString* urlString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SYNStreamURL"];
    if (urlString == Nil) {
        NSLog(@"error: SYNStreamURL key not found in info.plist");
        urlString = @"";
    }

    NSURL *url = [[NSURL alloc] initWithString:urlString];
	streamer = [[AudioStreamer alloc] initWithURL:url];
    [url release];
    
    [streamer start];
}
                    
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initStreamer];
    
    [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(playbackStateChanged:)
         name:ASStatusChangedNotification
         object:streamer];

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    if (self.playImage == Nil) {
        UIImage *playImageIcon = [playPauseButton imageForState:UIControlStateNormal];
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
