//
//  SYNMessage.m
//  SYN
//
//  Created by Andy Kitchen on 4/05/12.
//  Copyright 2012 GoodCode. All rights reserved.
//

#import "SYNMessage.h"

#import "SBJson.h"

// Encode a string to embed in an URL.
NSString* encodeToPercentEscapeString(NSString *string) {
    return (NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                              (CFStringRef) string,
                                              NULL,
                                              (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                              kCFStringEncodingUTF8);
}


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

- (void)presentAlertWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView *alert = [[[UIAlertView alloc]
                           initWithTitle:title
                           message:message
                           delegate:nil
                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                           otherButtonTitles: nil]
                          autorelease];
    [alert show];
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
    [request addValue:@"application/json, text/javascript, */*" forHTTPHeaderField:@"Accept"];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];

    NSString *escapedMessageBody = encodeToPercentEscapeString(messageBody);
    NSString *postBody = [NSString stringWithFormat:
        @"form_id=syn_sms_form&op=Send+Message&sms-message=%@",
            escapedMessageBody];
    
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [escapedMessageBody release];
    
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

        NSString *errorDescription =
          [NSString stringWithFormat:
             NSLocalizedString(@"Server returned status code %d",@""),
             statusCode];
        
        NSDictionary *errorInfo
        = [NSDictionary dictionaryWithObjectsAndKeys:
            errorDescription,
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

    [self presentAlertWithTitle:@"Error" message:@"couldn't send message, please try later"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"message response: %@", jsonStr);

    SBJsonParser *parser        = [[SBJsonParser alloc] init];
    NSDictionary *resposeJson   = [parser objectWithString:jsonStr];

    NSLog(@"message parsed:   %@", resposeJson);

    NSArray      *messages_status  = [resposeJson valueForKey:@"messages_status"];
    NSArray      *messages_error   = [resposeJson valueForKey:@"messages_error"];
    
    NSString *title = @"";
    NSDictionary *message;
    if([messages_error count] > 0) {
        title = @"SYN Error";
        message = [messages_error  objectAtIndex:0];
    } else {
        title = @"SYN";
        message = [messages_status objectAtIndex:0];        
    }
    
    NSString     *message_value = [message valueForKey:@"value"];
    
    [self presentAlertWithTitle:title message:message_value];

    [parser release];
    [resposeJson release];
    [jsonStr release];
    [connection release];
    [responseData release];
}

@end
