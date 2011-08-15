//
//  AppData.m
//  secdef
//
//  Created by David Massey on 6/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "AppData.h"
#import "ClientServerComm.h"

@implementation AppData

+(AppData *) appData {
    AppData *appData = [[[AppData alloc] init] autorelease];
    return appData;
}

-(void) sync {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs synchronize];
}

-(NSString *) getDataKey:(NSString *)key {
    NSString *str = [NSString stringWithFormat:@"%@_%@", [ClientServerComm userId],
                     key];
    return str;
}

-(void) savePublicKey:(NSString *)pemKey {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *dk = [self getDataKey:@"pubkey"];
    
    [prefs setObject:pemKey forKey:dk]; 
    [prefs synchronize];
}

-(void) savePrivateKey:(NSString *)pemKey {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *dk = [self getDataKey:@"privkey"];
    
    NSLog(@"Saving private key %@ = %@", dk, pemKey);
    
    [prefs setObject:pemKey forKey:dk];
    [prefs synchronize];
}

-(void) setActivated:(BOOL)activated {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *dk = [self getDataKey:@"activated"];
    
    [prefs setBool:activated forKey:dk];
    [prefs synchronize];
}

-(NSString *)getPrivateKey {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *dk = [self getDataKey:@"privkey"];
    NSString *val = [prefs objectForKey:dk];

    NSLog(@"Retrieving private key %@ = %@", dk, val);
    
    return (NSString *)[prefs objectForKey:dk];
}

-(NSString *)getPublicKey {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *dk = [self getDataKey:@"pubkey"];
    return (NSString *)[prefs objectForKey:dk];
}

@end
