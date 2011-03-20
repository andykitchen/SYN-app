//
//  SYNAppDelegate.h
//  SYN
//
//  Created by Andy Kitchen on 20/03/11.
//  Copyright 2011 GoodCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNViewController;

@interface SYNAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet SYNViewController *viewController;

@end
