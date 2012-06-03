//
//  SYNAppDelegate.m
//  SYN
//
//  Created by Andy Kitchen on 20/03/11.
//  Copyright 2011 GoodCode. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNViewController.h"
#import "AudioStreamer.h"

#import <AVFoundation/AVAudioSession.h>

#import "SBJson.h"

@implementation SYNAppDelegate


@synthesize window=_window;
@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
	[[NSThread currentThread] setName:@"Main Thread"];
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
        
    [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(presentAlertWithTitle:)
         name:ASPresentAlertWithTitleNotification
         object:nil];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSLog(@"applicationWillResignActive");
    visible = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    NSLog(@"applicationDidEnterBackground");
    visible = NO;
    
    [self.viewController stopIfPaused];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    NSLog(@"applicationWillEnterForeground");
    visible = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    NSLog(@"applicationDidBecomeActive");
    visible = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    NSLog(@"applicationWillTerminate");

    visible = NO;
	[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASPresentAlertWithTitleNotification
         object:nil];
}

- (void)presentAlertWithTitle:(NSNotification *)notification
{
    NSString *title = [[notification userInfo] objectForKey:@"title"];
    NSString *message = [[notification userInfo] objectForKey:@"message"];
    
    //NSLog(@"Current Thread = %@", [NSThread currentThread]);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    
    dispatch_async(main_queue, ^{
        
        //NSLog(@"Current Thread (in main queue) = %@", [NSThread currentThread]);
        if (!visible) {
#ifdef TARGET_OS_IPHONE
            if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];	
                localNotif.alertBody = message;
                localNotif.alertAction = NSLocalizedString(@"Open", @"");
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                [localNotif release];
            }
#endif
        }
        else {
#ifdef TARGET_OS_IPHONE
            UIAlertView *alert = [
                                  [[UIAlertView alloc]
                                   initWithTitle:title
                                   message:message
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                   otherButtonTitles: nil]
                                  autorelease];
            /*
             [alert
             performSelector:@selector(show)
             onThread:[NSThread mainThread]
             withObject:nil
             waitUntilDone:NO];
             */
            [alert show];
#else
            NSAlert *alert =
            [NSAlert
             alertWithMessageText:title
             defaultButton:NSLocalizedString(@"OK", @"")
             alternateButton:nil
             otherButton:nil
             informativeTextWithFormat:message];
            /*
             [alert
             performSelector:@selector(runModal)
             onThread:[NSThread mainThread]
             withObject:nil
             waitUntilDone:NO];
             */
            [alert runModal];
#endif
        }
    });
}


- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
