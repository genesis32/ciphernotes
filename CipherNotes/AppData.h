//
//  AppData.h
//  secdef
//
//  Created by David Massey on 6/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppData : NSObject {

}

+(AppData *) appData;

-(void) savePrivateKey:(NSString *)pemKey;    
-(void) savePublicKey:(NSString *)pemKey; 
-(NSString *)getPrivateKey;
-(NSString *)getPublicKey;
-(void) sync;
@end
