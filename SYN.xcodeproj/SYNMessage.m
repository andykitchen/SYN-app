//
//  SYNMessage.m
//  SYN
//
//  Created by Andy Kitchen on 4/05/12.
//  Copyright 2012 GoodCode. All rights reserved.
//

#import "SYNMessage.h"


@implementation SYNMessage

- (id)init
{
    return [self initWithString:@""];
}

- (id)initWithString:(NSString*)inMessageBody
{
    self = [super init];
    if (self) {
        messageBody = inMessageBody;
    }
    return self;
}

- (void) send
{
    NSLog(@"message sending: %@", messageBody);

    NSString* urlString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SYNMessageURL"];
    if (urlString == Nil) {
        NSLog(@"error: SYNMessageURL key not found in info.plist");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[@"Test Body" dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(connection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"error: could not initialize message connection");
        return;
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];

    int statusCode = [((NSHTTPURLResponse *)response) statusCode];
    if (statusCode >= 400) {
        [connection cancel];
        NSDictionary *errorInfo
        = [NSDictionary dictionaryWithObjectsAndKeys:
           [NSString
              stringWithFormat:
                NSLocalizedString(@"Server returned status code %d",@""),
              statusCode],
            NSLocalizedDescriptionKey,
            
            [response URL],
            NSURLErrorFailingURLStringErrorKey, nil];
           
        NSError *statusError
        = [NSError errorWithDomain:NSURLErrorDomain
                              code:statusCode
                          userInfo:errorInfo];
        [self connection:connection didFailWithError:statusError];

    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [connection release];
    [responseData release];
    
    NSLog(@"error: sending message -- %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"message response: %@",
      [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    
    [connection release];
    [responseData release];
}

@end
