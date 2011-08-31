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
@synthesize statusLabel;


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

    navigationController.navigationBar.tintColor = [UIColor redColor];
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
        self.statusLabel.text = @"Connecting...";
	}
	else if ([streamer isPlaying]) {
        self.statusLabel.text = @"Playing...";
	}
	else if ([streamer isPaused]) {
        self.statusLabel.text = @"Paused...";
	}
	else if ([streamer isIdle]) {
        self.statusLabel.text = @"Idle...";
	}
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
    [super viewDidUnload];
 
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];

    [streamer release];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.statusLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
