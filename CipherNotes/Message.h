//
//  Message.h
//  secdef
//
//  Created by David Massey on 6/14/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FROMID_KEY   @"FromId"
#define FROMNAME_KEY @"FromName"
#define TOID_KEY     @"ToId"
#define TONAME_KEY   @"ToName"
#define SENT_KEY     @"Sent"
#define EXPIRES_KEY  @"Expires"
#define ATTACH_KEY   @"Attachments"
#define SUBJECT_KEY  @"Subject"

@interface SecDefMessage : NSObject {
    long     msgid;

    NSMutableDictionary *headers;
    
    NSString *message;
    NSString *encMessage;
    NSString *aesKeyP2;
}

+(SecDefMessage *) messageFromSave:(NSManagedObject *)encMessage;
+(SecDefMessage *) messageFromService:(NSString *)msgId withKey:(NSString *)aesBase64KeyP2;
+(SecDefMessage *) messageFromHeaders:(NSDictionary *)dict;

-(NSManagedObject *) prepareForSave:(NSManagedObjectContext *)context;
-(void) loadFromString:(NSString *)string;
-(NSString *) asString;
-(NSString *) formatForServicePost;

-(long) sendToService:(unsigned char *)key;

@property (nonatomic) long msgid;
@property (nonatomic, retain) NSMutableDictionary *headers;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *encMessage;
@property (nonatomic, retain) NSString *aesKeyP2;

@end
