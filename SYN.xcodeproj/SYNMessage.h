//
//  SYNMessage.h
//  SYN
//
//  Created by Andy Kitchen on 4/05/12.
//  Copyright 2012 GoodCode. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SYNMessage : NSObject {
    NSString *messageBody;
    NSMutableData *responseData;
}

- (id)initWithString:(NSString*)inMessageBody;

- (void)send;

@end
