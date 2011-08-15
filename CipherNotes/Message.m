//
//  Message.m
//  secdef
//
//  Created by David Massey on 6/14/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Message.h"
#import "NSData+Base64.h"
#import "ClientServerComm.h"
#import "CryptoUtils.h"

static NSSet *fixedHeaders = nil;

@implementation SecDefMessage

@synthesize msgid;

@synthesize headers;
@synthesize message;
@synthesize encMessage;
@synthesize aesKeyP2;

-(NSManagedObject *) prepareForSave:(NSManagedObjectContext *)context {

    NSManagedObject *res = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    
    NSString *msgId = [[NSNumber numberWithLong:self.msgid] description];
    
    [res setValue:self.encMessage  forKey:@"EncMessage"];
    [res setValue:self.aesKeyP2    forKey:@"aesKeyP2"];
    [res setValue:msgId            forKey:@"EncMessageId"];
    
    return res;
}

+(SecDefMessage *) messageFromService:(NSString *)msgId withKey:(NSString *)aesBase64KeyP2 {
    SecDefMessage *res = [[[SecDefMessage alloc] init] autorelease];
    
    NSString *encMessage = [ClientServerComm getMessage:msgId];

    [res setMsgid:[msgId longLongValue]];
    [res setEncMessage:encMessage];
    [res setAesKeyP2:aesBase64KeyP2];
    
    NSString *cipherAesP1 = [ClientServerComm getKey:msgId];
    RSA      *privKey     = [CryptoUtils getPrivateKeyFromStore];
    
    NSData *aesPlainBytesP1 = [CryptoUtils decryptBase64EncodedData:cipherAesP1 withPrivKey: privKey];
    NSData *aesPlainBytesP2 = [NSData dataFromBase64String:aesBase64KeyP2]; 
    
    unsigned char aeskey[AES_KEYSIZE_BYTES];
    memset(aeskey, 0, AES_KEYSIZE_BYTES);
    
    int amid = AES_KEYSIZE_BYTES / 2;
    
    memcpy(aeskey, [aesPlainBytesP1 bytes], amid);
    memcpy(aeskey+amid, [aesPlainBytesP2 bytes], amid);
    
    NSString *plainMsg = [CryptoUtils decryptBase64EncodedString:[res encMessage] withAESKey:aeskey];
    
    [res loadFromString:plainMsg];
    
    [res setMessage:plainMsg];
    
    return res;
}

+(SecDefMessage *) messageFromSave:(NSManagedObject *)encMessage {
    
    NSString *msgId = (NSString *)[encMessage valueForKey:@"EncMessageId"];
    
    NSString *cipherAesP1 = [ClientServerComm getKey:msgId];
    if(cipherAesP1 == nil) {
        return nil;
    }
    
    SecDefMessage *msg = [[[SecDefMessage alloc] init] autorelease];
  
    [msg setMsgid:[msgId longLongValue]];
    [msg setEncMessage:[encMessage valueForKey:@"EncMessage"]];

    NSString *aesBase64KeyP2 = (NSString *)[encMessage valueForKey:@"aesKeyP2"];
     

    RSA      *privKey     = [CryptoUtils getPrivateKeyFromStore];
    
    NSData *aesPlainBytesP1 = [CryptoUtils decryptBase64EncodedData:cipherAesP1 withPrivKey: privKey];
    NSData *aesPlainBytesP2 = [NSData dataFromBase64String:aesBase64KeyP2]; 
        
    unsigned char aeskey[AES_KEYSIZE_BYTES];
    memset(aeskey, 0, AES_KEYSIZE_BYTES);
    
    int amid = AES_KEYSIZE_BYTES / 2;
    
    memcpy(aeskey, [aesPlainBytesP1 bytes], amid);
    memcpy(aeskey+amid, [aesPlainBytesP2 bytes], amid);
    
    NSString *plainMsg = [CryptoUtils decryptBase64EncodedString:[msg encMessage] withAESKey:aeskey];
    
    [msg loadFromString:plainMsg];
    
    [msg setMessage:plainMsg];

    return msg;
}
     
-(void) loadFromString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    while(![scanner isAtEnd]) {
        NSString *scannedChars;
        if([scanner scanUpToString:@"\r\n" intoString:&scannedChars]) {
            NSLog(@"Scanned: %@", scannedChars);
        }
    }
    
}

+(SecDefMessage *) messageFromHeaders:(NSDictionary *)dict {
    SecDefMessage *msg = [[[SecDefMessage alloc] init] autorelease];
    
    for(NSString *key in fixedHeaders) {
        [msg.headers setValue:[dict valueForKey:key] forKey:key];
    }
    
    return msg;
}

- (id) init
{
    if((self = [super init])) {
        if(!fixedHeaders) {
            fixedHeaders = [[NSSet alloc] initWithObjects:FROMID_KEY, FROMNAME_KEY, TOID_KEY, 
                            TONAME_KEY, SENT_KEY, EXPIRES_KEY, ATTACH_KEY, SUBJECT_KEY, nil];
            headers = [[NSMutableDictionary alloc] init];
        }
        
        msgid = -1;
    }
    return self;
}

-(long) sendToService:(unsigned char *)key {
    
    NSString *plainMsg = [self asString]; 

    self.encMessage = [CryptoUtils encryptAndBase64EncodeString:plainMsg withAESKey:key];
     
    self.msgid = [ClientServerComm sendMessage:self];    
    return self.msgid;
}

-(NSString *) asString {
    NSMutableString *res = [[[NSMutableString alloc] init] autorelease];
    for(NSString *key in self.headers) {
        NSString *value = (NSString *)[headers objectForKey:key];
        if(value != nil) {
            [res appendFormat:@"%@:%@\r\n", key, value];
        }
    }
    
    [res appendFormat:@"\r\n%@", self.message];
    
    return res;
}

-(NSString *) formatForServicePost {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[self.headers valueForKey:FROMID_KEY] forKey:@"frid"];
    [dict setValue:[self.headers valueForKey:TOID_KEY] forKey:@"toid"];
    [dict setValue:self.encMessage forKey:@"msg"];
    
    NSString *postString = [ClientServerComm formatForPost: dict];
    [dict release];
    return postString;
}

-(NSString *) description {
    return [self asString];
}

@end
