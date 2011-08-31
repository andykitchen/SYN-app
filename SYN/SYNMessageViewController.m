//
//  SYNMessageViewController.m
//  SYN
//
//  Created by Andy Kitchen on 21/03/11.
//  Copyright 2011 GoodCode. All rights reserved.
//

#import "SYNMessageViewController.h"


@implementation SYNMessageViewController

@synthesize messageText;
@synthesize delegate;

- (IBAction)send {
    if (delegate) {
        [delegate sendMessage:messageText.text];
    }
}

- (IBAction)cancel {
    if (delegate) {
        [delegate cancelMessage];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [messageText release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Message";
    
    if(self.navigationItem) {
        UIBarButtonItem *leftButton = 
        [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        
        UIBarButtonItem *rightButton = 
        [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
        
        self.navigationItem.leftBarButtonItem = leftButton;
        self.navigationItem.rightBarButtonItem = rightButton;
        
        [leftButton release];
        [rightButton release];
    }    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [messageText becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent*)event
{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if(delegate) {
                    [delegate togglePlayPause];   
                }
                break;
                
            default:
                break;
        }
    }   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    self.messageText = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
