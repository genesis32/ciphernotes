//
//  CryptoUtils.m
//  secdef
//
//  Created by David Massey on 6/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "CryptoUtils.h"
#import "AppData.h"
#import "NSData+Base64.h"
#import "openssl/pem.h"
#import "openssl/rsa.h"
#import "openssl/rand.h"


@implementation CryptoUtils

+(NSString *) getSHA256Checksum:(void *)bytes withLength:(size_t)length {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, bytes, length);
    SHA256_Final(hash, &sha256);  
    
    NSMutableString *result = [[NSMutableString alloc] init];
    for(int i=0; i < SHA256_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", hash[i]]; 
    }
    return result;
}

+(RSA *) generateKeyPair {
    [CryptoUtils seedPRNG];
    RSA *rsakey = RSA_generate_key(2048, 17, NULL, NULL);
    
    return rsakey;
}

+(NSString *) getKeyContentsFromBio:(BIO *)mem {
    BUF_MEM *bptr = NULL;
    BIO_get_mem_ptr(mem, &bptr);
    
    char *keystrbuff = (char *)malloc(bptr->length + 1);
    memset(keystrbuff, 0, bptr->length + 1);
    memcpy(keystrbuff, bptr->data, bptr->length);
    NSString *result = [NSString stringWithFormat:@"%s", keystrbuff];
    
    free(keystrbuff);
    
    return result;
}

+(NSString *) getPrivateKey:(RSA *)rsa {
    BIO *mem = BIO_new(BIO_s_mem());
    
    PEM_write_bio_RSAPrivateKey(mem, rsa, NULL, NULL, 0, NULL, NULL);
    
    NSString *key = [CryptoUtils getKeyContentsFromBio: mem];
    
    BIO_free(mem);
    
    return key;
}

+(NSString *) getPublicKey:(RSA *)rsa {
    BIO *mem = BIO_new(BIO_s_mem());

    PEM_write_bio_RSA_PUBKEY(mem, rsa);
    
    NSString *key = [CryptoUtils getKeyContentsFromBio: mem];
        
    BIO_free(mem);

    return key;
}

+(void) seedPRNG {    
    RAND_load_file("/dev/urandom", 128);    
    int enoughData = RAND_status();
    assert(enoughData == 1);
}

+(RSA *) getPrivateKeyFromStore {
    AppData *appData = [[AppData alloc] init];
    NSString *privKey = [appData getPrivateKey];
    [appData release];
    
    int length = [privKey length];
    const char *chars = [privKey cStringUsingEncoding:NSUTF8StringEncoding];
    BIO *mem = BIO_new_mem_buf((void *)chars, length);
        
    RSA *rsa = NULL;
    EVP_PKEY *rkey = NULL;
    PEM_read_bio_PrivateKey(mem, &rkey, NULL, NULL);
    rsa = EVP_PKEY_get1_RSA(rkey);

    BIO_free(mem);
    
    return rsa;
}

+(RSA *) getPublicKeyFromString:(NSString *)str {
    const char *chars = [str cStringUsingEncoding:NSUTF8StringEncoding];
    BIO *mem = BIO_new_mem_buf((void *)chars, [str length]);
    
    RSA *rkey = NULL;
    PEM_read_bio_RSA_PUBKEY(mem, &rkey, NULL, NULL);
    
    BIO_free(mem);
    return rkey;
}

+(void) generateAESKey:(unsigned char [AES_KEYSIZE_BYTES])aeskey {
    for(int i=0; i<AES_KEYSIZE_BYTES; i++) {
        aeskey[i] = (unsigned char)arc4random();
    }
}

+(NSString *) encryptAndBase64EncodeString:(NSString *)str withAESKey:(unsigned char *)aesKey {
    unsigned char salt[] = { 0, 1, 2, 3, 0, 1, 2, 3};
    
    EVP_CIPHER_CTX ectx;
    int i, nrounds = 5;
    unsigned char key[32], iv[32];
    
    i = EVP_BytesToKey(EVP_aes_256_cbc(), EVP_sha1(), salt, aesKey, AES_KEYSIZE_BYTES, nrounds, key, iv);
    assert(i == 32);
    
    EVP_CIPHER_CTX_init(&ectx);
    EVP_EncryptInit_ex(&ectx, EVP_aes_256_cbc(), NULL, key, iv);
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    int olen = [data length] + 1;
    
    char *plainbytes = malloc(olen); // add null terminator
    memset(plainbytes, 0, olen);
    [data getBytes:plainbytes length:[data length]];
    
    int clen = olen + AES_BLOCK_SIZE;
    int flen = 0;
    unsigned char *ciphertext = malloc(clen);
    
    EVP_EncryptInit_ex(&ectx, NULL, NULL, NULL, NULL);
    
    EVP_EncryptUpdate(&ectx, ciphertext, &clen, (unsigned char *)plainbytes, olen);
    
    EVP_EncryptFinal(&ectx, ciphertext + clen, &flen);

    int cipherlength = clen + flen;
            
    EVP_CIPHER_CTX_cleanup(&ectx);
    
    NSData *cipherdata = [NSData dataWithBytes:ciphertext length:cipherlength];
    
    NSLog(@"ciphertext - base64 enc: %@", [cipherdata base64EncodedString]);
    
    free(ciphertext);    
    free(plainbytes);
    
    return [cipherdata base64EncodedString];
}

+(NSString *) decryptBase64EncodedString:(NSString *)str withAESKey:(unsigned char *)aesKey {
    
    NSData *data = [NSData dataFromBase64String: str];
    
    unsigned char salt[] = { 0, 1, 2, 3, 0, 1, 2, 3};
    
    EVP_CIPHER_CTX ectx;
    int i, nrounds = 5;
    unsigned char key[32], iv[32];
    
    i = EVP_BytesToKey(EVP_aes_256_cbc(), EVP_sha1(), salt, aesKey, AES_KEYSIZE_BYTES, nrounds, key, iv);
    assert(i == 32);
    
    EVP_CIPHER_CTX_init(&ectx);
    EVP_DecryptInit_ex(&ectx, EVP_aes_256_cbc(), NULL, key, iv);
    
    int len = [data length];
    int plen = 0;
    int flen = 0;
    unsigned char *plaintext = malloc(len);
    unsigned char *cipherbytes = malloc(len);
    [data getBytes:cipherbytes length:len];
    
    EVP_DecryptInit_ex(&ectx, NULL, NULL, NULL, NULL);
    EVP_DecryptUpdate(&ectx, plaintext, &plen, cipherbytes , len);
    EVP_DecryptFinal_ex(&ectx, plaintext+plen, &flen);
    
    EVP_CIPHER_CTX_cleanup(&ectx);
    
    int plainlength = plen + flen;
    NSString *res = [NSString stringWithUTF8String:(char *)plaintext];
    
    NSLog(@"plainlen=%d, plaintext=%@", plainlength, res);
    
    return res;
}      

+(NSString *) encryptDataAndBase64Encode:(NSData *)data withPubKey:(RSA *)pubKey {
    
    unsigned char *plaintext  = (unsigned char *)malloc([data length]);
    [data getBytes:plaintext length:[data length]];
    
    unsigned char *ciphertext = (unsigned char *)malloc(RSA_size(pubKey));
    
    int numBytes = RSA_public_encrypt([data length], plaintext, ciphertext, pubKey, RSA_PKCS1_PADDING);
    
    NSData *outData = [NSData dataWithBytes:ciphertext length:numBytes];
    
    free(plaintext);
    free(ciphertext);
        
    return [outData base64EncodedString];
}

+(NSData *) decryptBase64EncodedData:(NSString *)msg withPrivKey:(RSA *)privKey {
    NSData *data = [NSData dataFromBase64String:msg];
    unsigned int clen = [data length];
    unsigned char *ciphertext = (unsigned char *)malloc(clen);
    [data getBytes:ciphertext length:clen];
    
    int ptlen = RSA_size(privKey);
    unsigned char *plaintext  = (unsigned char *)malloc(ptlen);
        
    int numBytes = RSA_private_decrypt(clen, ciphertext, plaintext, privKey, RSA_PKCS1_PADDING);
    if(numBytes == -1) {
        FILE *fRsaKey = fopen( "/Users/ddm/Desktop/err.txt", "wb" );
        ERR_print_errors_fp(fRsaKey);
        fclose(fRsaKey);
        return nil;
    }
    
    NSData *res = [NSData dataWithBytes:plaintext length:numBytes];
    
    
    free(ciphertext);
    free(plaintext);
    
    return res;
}



@end
