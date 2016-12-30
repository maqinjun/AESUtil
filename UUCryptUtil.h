//
//  UUCryptUtil.h
//  UUEMMDemo
//
//  Created by maqj on 16/12/29.
//  Copyright © 2016年 maqj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UUCryptUtil : NSObject
+ (NSError*)decrypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key;
+ (NSError*)encrypt:(NSString*)srcPath to:(NSString*)destPath key:(NSString*)key;

@end
