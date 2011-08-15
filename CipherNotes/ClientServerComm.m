//
//  ClientServerComm.m
//  secdef
//
//  Created by David Massey on 5/31/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "JSONKit.h"
#import "NSString+URLEncoding.h"
#import "ClientServerComm.h"
#import "Contact.h"
#include "Message.h"

#define ACTIVATED_URL  @"http://localhost:8000/keyserver/device/activated/%@"
#define ACTIVATE_URL   @"http://localhost:8000/keyserver/device/activate/%@"

#define MESSAGE_SEND_URL @"http://localhost:8000/keyserver/message/send"
#define GETMESSAGE_URL  @"http://localhost:8000/keyserver/message/get/%@"

#define GETPUBKEY_URL @"http://localhost:8000/keyserver/pubkey/get/%@"

#define CONTACTLIST_URL @"http://localhost:8000/keyserver/contacts/get/%@"
#define AESKEY_URL      @"http://localhost:8000/keyserver/msgkey/send"
#define GETKEY_URL      @"http://localhost:8000/keyserver/msgkey/get/%@"

static int userpk = 0;

NSString *testKeys[] = { @"E03B689E-7E06-5F39-A7DC-8F0E103C3325", 
    @"A03B689E-7E06-5F39-A7DC-8F0E103C3325" };

@implementation ClientServerComm

+(void) setUserId:(int)pk {
    userpk = pk;
}

+(NSString *) userId {
    return [[NSNumber numberWithInt:userpk] description];
}

+(NSString *) getUDID {
    return testKeys[userpk-1];
    // return [[UIDevice currentDevice] uniqueIdentifier];
}

+(NSString *) getMessage:(NSString *)msgId {
    NSString *hUserId = [ClientServerComm urlEncode:msgId];
    NSString *url = [NSString stringWithFormat:GETMESSAGE_URL, hUserId];
    
    NSData *data = [ClientServerComm performGetAndGetResponse:url];
    NSDictionary *jsonData = [data objectFromJSONData];
    int found = [[jsonData valueForKey:@"found"] intValue];
    
    NSString *res = nil;
    if(found) {
        res = [NSString stringWithString:[jsonData valueForKey:@"msg"]];
        res = [res stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return res;
}

+(NSString *) urlEncode:(NSString *)str {
    NSString *rstr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return rstr;
}

+(NSString *) formatForPost:(NSDictionary *)dict {
    NSMutableArray *keyvals = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [dict keyEnumerator];
    id k;
    while((k = [enumerator nextObject])) {
        NSString *key = (NSString *)k;
        NSString *value = (NSString *)[dict objectForKey:k];
        NSString *fkey = [key urlEncode];
        NSString *fvalue = [value urlEncode];
        
        [keyvals addObject:[NSString stringWithFormat:@"%@=%@", fkey, fvalue]];
    }
    NSString *res = [keyvals componentsJoinedByString:@"&"];
    
    [keyvals release];
    return res;    
}

+(NSString*)UUIDString {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

+(NSData *) performGetAndGetResponse: (NSString *)url {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setURL:[NSURL URLWithString:[ClientServerComm urlEncode:url]]];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:
                    &response error:&error];
    
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"URL: %@ - Resp:%@", url, resp);
    
    [resp release];
    return data;
}

+(NSData *) performPostAndGetResponse:(NSString *)url withText:(NSString *)postTest {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    NSData *postData = [postTest dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
        
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:
                    &response error:&error];
    
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"postdata: %@", [NSString stringWithUTF8String:[postData bytes]]);
    
    NSLog(@"post and get resp: %@", resp);
    
    [resp release];
    return data;
}

+(NSString *) getKey:(NSString *)msgId {
    NSString *hUserId = [ClientServerComm urlEncode:msgId];
    NSString *url = [NSString stringWithFormat:GETKEY_URL, hUserId];
    
    NSData *data = [ClientServerComm performGetAndGetResponse:url];
    NSDictionary *jsonData = [data objectFromJSONData];
    int found = [[jsonData valueForKey:@"found"] intValue];
    
    NSString *res = nil;
    if(found) {
        res = [NSString stringWithString:[jsonData valueForKey:@"msgkey"]];
        res = [res stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"msgkey = %@", res);
    }
    return res;
}


+(void) sendKey:(NSString *)base64EncAESKey messageId:(NSString *)msgId expires:(NSString *)expirationDate {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:msgId forKey:@"msgid"];
    [params setObject:base64EncAESKey forKey:@"key"];
    [params setObject:expirationDate forKey:@"mintoexpire"];
    
    NSString *post = [ClientServerComm formatForPost:params];
    
    NSData *data = [ClientServerComm performPostAndGetResponse:AESKEY_URL  withText:post];

    NSString *resp = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
     NSLog(@"sendKey resp: %@", resp);
}


+(NSArray *) getContactList {
    NSMutableArray *res = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *udid = [ClientServerComm urlEncode:[ClientServerComm getUDID]];
    NSString *url = [NSString stringWithFormat:CONTACTLIST_URL, udid];
    
    NSData *data = [ClientServerComm performGetAndGetResponse:url];
    
    NSDictionary *contactsJson = [data objectFromJSONData];
    
    NSArray *contacts = [contactsJson objectForKey:@"contacts"];
    
    for(NSArray *contact in contacts) {
        Contact *nc = [Contact contactFromData:[[contact objectAtIndex:0] description] andName:[contact objectAtIndex:1]];
        [res addObject:nc];
    }
    
    return res;
}

+(NSString *) getPublicKey:(NSString *)userId {
    NSString *hUserId = [ClientServerComm urlEncode:userId];
    NSString *url = [NSString stringWithFormat:GETPUBKEY_URL, hUserId];

    NSData *data = [ClientServerComm performGetAndGetResponse:url];
    NSDictionary *jsonData = [data objectFromJSONData];
    int found = [[jsonData valueForKey:@"found"] intValue];
    
    NSString *res = nil;
    if(found) {
        res = [NSString stringWithString:[jsonData valueForKey:@"pubkey"]];
        res = [res stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return res;
}

+(long) sendMessage:(SecDefMessage *)message {
    NSString *post = [message formatForServicePost];
    NSData *data = [ClientServerComm performPostAndGetResponse:MESSAGE_SEND_URL withText:post];
    
    NSDictionary *jsonData = [data objectFromJSONData];    
    int resultcode = [[jsonData valueForKey:@"resultcode"] intValue];    
    
    if(resultcode == 0) {
        return [[jsonData valueForKey:@"msgid"] longValue];
    } else {
        return -1;
    }
    
    NSLog(@"sendMessage resultCode: %d", resultcode);
}

+(BOOL) activate:(NSString *)publicKey {
    NSString *udid = [ClientServerComm urlEncode:[ClientServerComm getUDID]];
    NSString *url = [NSString stringWithFormat:ACTIVATE_URL, udid];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:publicKey forKey: @"pubkey"];    
    NSString *post = [ClientServerComm formatForPost:dict];

    NSData *data = [ClientServerComm performPostAndGetResponse:url withText:post];
    NSDictionary *jsonData = [data objectFromJSONData];
    
    int resultcode = [[jsonData valueForKey:@"resultcode"] intValue];
    
    return resultcode == 3; // DeviceNowActivated
}

+(BOOL) isActivated {
    NSString *udid = [ClientServerComm urlEncode:[ClientServerComm getUDID]];
    NSString *url = [NSString stringWithFormat:ACTIVATED_URL, udid];
    
    NSData *rawdata = [ClientServerComm performGetAndGetResponse:url];
    
    NSDictionary *jsonData = [rawdata objectFromJSONData];
    
    int resultcode = [[jsonData valueForKey:@"resultcode"] intValue];
    
    return resultcode == 0; // DeviceIsActivated
}

@end
