//
//  SYNMessageViewController.h
//  SYN
//
//  Created by Andy Kitchen on 21/03/11.
//  Copyright 2011 GoodCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYNMessageDelegate
-(void)sendMessage:(NSString*)message;
-(void)cancelMessage;
-(void)togglePlayPause;
@end

@interface SYNMessageViewController : UIViewController {
    UITextView *messageText;
    id<SYNMessageDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITextView *messageText;
@property (nonatomic, retain) id<SYNMessageDelegate> delegate;

@end
