//
//  NSData+cipher.h
//  AESUtil
//
//  Created by maqj on 17/4/7.
//  Copyright © 2017年 maqj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(cipher)
- (NSData*)EncryptWithKey:(NSString *)key;
- (NSData*)DecryptWithKey:(NSString *)key;
@end
