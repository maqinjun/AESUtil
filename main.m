//
//  main.m
//  CryptTest
//
//  Created by maqj on 16/12/29.
//  Copyright © 2016年 maqj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UUCryptUtil.h"
#import "uuaes.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSString *src1 = @"/Users/maqj/tmp/encrypt.pdf";
        NSString *dest1 = @"/Users/maqj/tmp/encrypt1.pdf";
        NSString *dest2 = @"/Users/maqj/tmp/encrypt2.pdf";
        NSString *key1 = @"ec2f151588db9e20";
        
        NSError *error1 = nil;
        
        error1 = [[UUCryptUtil shared] decrypt:src1 to:dest1 key:key1];

        if (error1) {
            printf("%s\n", [error1.description cStringUsingEncoding:NSUTF8StringEncoding]);
            return 0;
        }

        error1 = [[UUCryptUtil shared] decrypt:src1 to:dest2 key:key1];
        
        if (error1) {
            printf("%s\n", [error1.description cStringUsingEncoding:NSUTF8StringEncoding]);
            return 0;
        }

        
        return 0;
        
        if (argc<5) {
            printf("Usage: CryptTest [--encrypt | --decrypt] source_file  target_file key (16 char)\n");
            return 0;
        }
        
        const char *path = argv[0];
        const char *opt = argv[1];
        const char *sourceFile = argv[2];
        const char *destFile = argv[3];
        const char *key = argv[4];
        
        NSString *src = nil;
        NSString *dest = nil;
        
        NSString *curPath = [NSString stringWithFormat:@"%s", path];
        curPath = [curPath stringByReplacingOccurrencesOfString:[curPath lastPathComponent] withString:@"./"];

        src = [NSString stringWithFormat:@"%s", sourceFile];
        dest = [NSString stringWithFormat:@"%s", destFile];

        if (![src hasPrefix:@"/"]) {
            src = [NSString stringWithFormat:@"%@/%s", curPath, sourceFile];
        }
        if (![dest hasPrefix:@"/"]) {
            dest = [NSString stringWithFormat:@"%@/%s", curPath, destFile];
        }
        
        NSLog(@"%@", src);
        NSLog(@"%@", dest);
        
        NSString *operation = [NSString stringWithFormat:@"%s", opt];
        NSError *error = nil;
        
        if ([operation isEqualToString:@"--encrypt"]) {
            error = [[UUCryptUtil shared] encrypt:src to:dest key:[NSString stringWithFormat:@"%s", key]];

        }else if ([operation isEqualToString:@"--decrypt"]){
            error = [[UUCryptUtil shared] decrypt:src to:dest key:[NSString stringWithFormat:@"%s", key]];
        }else{
            printf("Usage: CryptTest [--encrypt | --decrypt] source_file  target_file key (16 char)\n");
            return 0;
        }

        if (error) {
            printf("%s\n", [error.description cStringUsingEncoding:NSUTF8StringEncoding]);
            return 0;
        }
        
        printf("Operation successfully.\n");
    }
    return 0;
}
