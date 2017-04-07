//
//  NSData+cipher.m
//  AESUtil
//
//  Created by maqj on 17/4/7.
//  Copyright © 2017年 maqj. All rights reserved.
//

#import "NSData+cipher.h"
#import "UUCryptUtil.h"

@implementation NSData(cipher)
- (NSData*)EncryptWithKey:(NSString *)key{
    unsigned char ivTemp[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8};
    return [[UUCryptUtil shared] AES128EncryptWithKey:key iv:ivTemp data:self];
}

- (NSData*)DecryptWithKey:(NSString *)key{
    unsigned char ivTemp[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8};
    return [[UUCryptUtil shared] AES128DecryptWithKey:key iv:ivTemp data:self];
}

@end
