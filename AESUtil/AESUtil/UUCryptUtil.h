//
//  UUCryptUtil.h
//  CryptTest
//
//  Created by maqj on 16/12/29.
//  Copyright © 2016年 maqj. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* defaultKey();

@interface UUCryptUtil : NSObject

+ (instancetype)shared;
- (NSError*)decrypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key;
- (NSError*)encrypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key;

- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(unsigned char[16]) iv data:(NSData*)data;
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(unsigned char[16]) iv data:(NSData*)data;

@end
