//
//  ClientServerComm.h
//  secdef
//
//  Created by David Massey on 5/31/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface ClientServerComm : NSObject {
    
}

+(void) setUserId:(int)pk;
+(NSString *) userId;

+(NSData *) performGetAndGetResponse:(NSString *)url;
+(NSData *) performPostAndGetResponse:(NSString *)url withText:(NSString *)postTest;

+(NSString *) urlEncode:(NSString *)str;
+(NSString *) formatForPost:(NSDictionary *)dict;
+(NSString *) UUIDString;
+(NSString *) getUDID;

+(BOOL) activate:(NSString *)publicKey;
+(BOOL) isActivated;
+(long) sendMessage:(SecDefMessage *)message;

+(NSArray *) getContactList;

+(NSString *) getPublicKey:(NSString *)userId;

+(void) sendKey:(NSString *)base64EncAESKey messageId:(NSString *)msgId expires:(NSString *)expirationDate;

+(NSString *) getKey:(NSString *)msgId;
+(NSString *) getMessage:(NSString *)msgId;
@end
