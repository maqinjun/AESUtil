//
//  UUCryptUtil.m
//  UUEMMDemo
//
//  Created by maqj on 16/12/29.
//  Copyright © 2016年 maqj. All rights reserved.
//

#import "UUCryptUtil.h"

#include "uuaes.h"

#import <CommonCrypto/CommonCryptor.h>

unsigned char iv[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8};

@interface NSData (NSData_AES)

@end

@implementation NSData (NSData_AES)

- (NSData *)AES128EncryptWithKey:(NSString *)key//加密
{
    unsigned char * keyTmp = (unsigned char*)malloc(sizeof(unsigned char) *kCCKeySizeAES128);
    const char *keyChar = [key cStringUsingEncoding:NSUTF8StringEncoding];
    memcpy(keyTmp, keyChar, sizeof(unsigned char) *kCCKeySizeAES128);
    
    int keysize = 128;
    aes_context aes;
    
    aes_setkey_enc(&aes, (unsigned char*)keyTmp, keysize);
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    unsigned char* buffer = (unsigned char*)malloc(sizeof(unsigned char)*bufferSize);
    memset(buffer, 0, bufferSize);
    
    int ret = aes_crypt_cbc(&aes, AES_ENCRYPT, dataLength, iv, (unsigned char*)[self bytes], buffer);
    
    free(keyTmp);
    
    if (ret < 0) {
        free(buffer);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:dataLength];
}


- (NSData *)AES128DecryptWithKey:(NSString *)key//解密
{
    unsigned char * keyTmp = (unsigned char*)malloc(sizeof(unsigned char) *kCCKeySizeAES128);
    const char *keyChar = [key cStringUsingEncoding:NSUTF8StringEncoding];
    memcpy(keyTmp, keyChar, sizeof(unsigned char) *kCCKeySizeAES128);
    
    int keysize = 128;
    aes_context aes;
    
    aes_setkey_dec(&aes, (unsigned char*)keyTmp, keysize);
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    unsigned char* buffer = (unsigned char*)malloc(sizeof(unsigned char)*bufferSize);
    memset(buffer, 0, bufferSize);

    int ret = aes_crypt_cbc(&aes, AES_DECRYPT, dataLength, iv, (unsigned char*)[self bytes], buffer);
    
    free(keyTmp);
    
    if (ret < 0) {
        free(buffer);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:dataLength];
}
@end

@implementation UUCryptUtil

+ (NSError*)crypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key block:(NSData*(^)(NSData*))block{
    NSAssert(srcPath && destPath, @"Source path or dest path nil.");
    
    NSFileHandle *fileRead = [NSFileHandle fileHandleForReadingAtPath:srcPath];
    if (!fileRead) {
        return [NSError errorWithDomain:@"Source file invalid." code:-1 userInfo:@{}];
    }
    
    NSFileHandle *fileWrite = [NSFileHandle fileHandleForWritingAtPath:destPath];
    if (!fileWrite) {
        [[NSFileManager defaultManager] createFileAtPath:destPath contents:nil attributes:nil];
        fileWrite = [NSFileHandle fileHandleForWritingAtPath:destPath];
    }else{
        [fileWrite truncateFileAtOffset:0];
    }
    
    if (!fileWrite) {
        return [NSError errorWithDomain:@"Create dest file failed." code:-1 userInfo:@{}];
    }
    
    @try {
        NSData *data = [fileRead readDataOfLength:1024];
        
        while (data.length>0) {
            
            CCCryptorStatus status = kCCSuccess;
            
            NSData *decryptedData = nil;
            if (block) {
                decryptedData = block(data);
            }

            if ( !decryptedData||status!= kCCSuccess) {
                NSLog(@"Failed.");
                return [NSError errorWithDomain:@"Decrypt failed." code:status userInfo:nil];
            }
            
            [fileWrite writeData:decryptedData];
            data = [fileRead readDataOfLength:1024];
        }
        
        [fileWrite synchronizeFile];
        
    } @catch (NSException *exception) {
        return [NSError errorWithDomain:exception.description code:-1 userInfo:nil];
    } @finally {
        
        if (fileRead) {
            [fileRead closeFile];
        }
        
        if (fileWrite) {
            [fileWrite closeFile];
        }
    }
    
}

+ (NSError*)encrypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key{
    return  [self crypt:srcPath to:destPath key:key block:^NSData *(NSData *data) {
        return [data AES128EncryptWithKey:key];
    }];
}

+ (NSError*)decrypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key{

    return  [self crypt:srcPath to:destPath key:key block:^NSData *(NSData *data) {
        return [data AES128DecryptWithKey:key];
    }];
}
@end
