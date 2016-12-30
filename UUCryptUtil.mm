//
//  UUCryptUtil.m
//  UUEMMDemo
//
//  Created by maqj on 16/12/29.
//  Copyright © 2016年 maqj. All rights reserved.
//

#import "UUCryptUtil.h"
#import <CommonCrypto/CommonCrypto.h>
#include "uuaes.h"

@implementation UUCryptUtil{
    unsigned char _iv[16];
}

+ (instancetype)shared{
    static UUCryptUtil *util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[UUCryptUtil alloc] init];
    });
    return util;
}

- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(unsigned char[16]) iv data:(NSData*)data//加密
{
    
    unsigned char * keyTmp = (unsigned char*)malloc(sizeof(unsigned char) *kCCKeySizeAES128);
    const char *keyChar = [key cStringUsingEncoding:NSUTF8StringEncoding];
    memcpy(keyTmp, keyChar, sizeof(unsigned char) *kCCKeySizeAES128);
    
    int keysize = 128;
    aes_context aes;
    
    aes_setkey_enc(&aes, (unsigned char*)keyTmp, keysize);
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    unsigned char* buffer = (unsigned char*)malloc(sizeof(unsigned char)*bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t inBufferSize = dataLength + (dataLength%16?(16-dataLength%16):0);
    unsigned char* inBuffer = (unsigned char*)malloc(sizeof(unsigned char)*inBufferSize);
    memset(inBuffer, 0, inBufferSize);
    memcpy(inBuffer, [data bytes], dataLength);
    
    
    int ret = aes_crypt_cbc(&aes, AES_ENCRYPT, inBufferSize, iv, inBuffer, buffer);
    
    memset(&aes, 0, sizeof(aes));
    
    free(keyTmp);
    free(inBuffer);
    
    if (ret < 0) {
        free(buffer);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:inBufferSize];
}


- (NSData *)AES128DecryptWithKey:(NSString *)key  iv:(unsigned char[16]) iv data:(NSData*)data//解密
{
    unsigned char * keyTmp = (unsigned char*)malloc(sizeof(unsigned char) *kCCKeySizeAES128);
    const char *keyChar = [key cStringUsingEncoding:NSUTF8StringEncoding];
    memcpy(keyTmp, keyChar, sizeof(unsigned char) *kCCKeySizeAES128);
    
    int keysize = 128;
    aes_context aes;
    aes_setkey_dec(&aes, (unsigned char*)keyTmp, keysize);
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    unsigned char* buffer = (unsigned char*)malloc(sizeof(unsigned char)*bufferSize);
    memset(buffer, 0, bufferSize);
    
    int ret = aes_crypt_cbc(&aes, AES_DECRYPT, dataLength, iv, (unsigned char*)[data bytes], buffer);
    
    free(keyTmp);
    
    if (ret < 0) {
        free(buffer);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:dataLength];
}


- (NSError*)crypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key block:(NSData*(^)(NSData*))block{
    
    NSAssert(srcPath && destPath, @"Source path or dest path nil.");
    
    NSError *error;
    
    NSFileHandle *fileRead = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:srcPath] error:&error];
    if (!fileRead) {
        return error;
    }
    
    NSFileHandle *fileWrite = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:destPath] error:&error];
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
        
        [fileRead seekToFileOffset:0];
        [fileWrite seekToFileOffset:0];
        
        NSData *data = [fileRead readDataOfLength:1024];
        
        while (data.length>0) {
            
            CCCryptorStatus status = kCCSuccess;
            
            NSData *decryptedData = nil;
            if (block) {
                decryptedData = block(data);
            }

            if ( !decryptedData||status!= kCCSuccess) {
                NSLog(@"Failed.");
                return [NSError errorWithDomain:@"crypt failed." code:status userInfo:nil];
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
    
    return nil;
}

- (NSError*)encrypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key{
    
    unsigned char ivTemp[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8};
    memcpy(_iv, ivTemp, sizeof(_iv));

    return  [self crypt:srcPath to:destPath key:key block:^NSData *(NSData *data) {
        return [self AES128EncryptWithKey:key iv:_iv data:data];
    }];
}

- (NSError*)decrypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key{
    
    unsigned char ivTemp[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8};
    memcpy(_iv, ivTemp, sizeof(_iv));

    return  [self crypt:srcPath to:destPath key:key block:^NSData *(NSData *data) {
        return [self AES128DecryptWithKey:key iv:_iv data:data];
    }];
}
@end
