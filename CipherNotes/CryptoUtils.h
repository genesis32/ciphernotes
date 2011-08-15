//
//  CryptoUtils.h
//  secdef
//
//  Created by David Massey on 6/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "openssl/rsa.h"
#import "openssl/aes.h"

#define AES_KEYSIZE_BYTES 256

@interface CryptoUtils : NSObject {
    
}

+(RSA *) generateKeyPair;
+(NSString *) getPrivateKey:(RSA *)rsa;
+(NSString *) getPublicKey:(RSA *)rsa;
+(NSString *) getSHA256Checksum:(void *)bytes withLength:(size_t)length;

+(void) seedPRNG;

+(RSA *) getPrivateKeyFromStore;
+(RSA *) getPublicKeyFromString:(NSString *)str;

+(NSString *) encryptDataAndBase64Encode:(NSData *)msg withPubKey:(RSA *)pubKey;
+(NSData *) decryptBase64EncodedData:(NSString *)msg withPrivKey:(RSA *)privKey;

+(NSString *) encryptAndBase64EncodeString:(NSString *)str withAESKey:(unsigned char *)aesKey;
+(NSString *) decryptBase64EncodedString:(NSString *)str withAESKey:(unsigned char *)aesKey;

+(void) generateAESKey: (unsigned char [AES_KEYSIZE_BYTES])key;

@end
