//
//  main.m
//  CryptTest
//
//  Created by maqj on 16/12/29.
//  Copyright © 2016年 maqj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UUCryptUtil.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...

        if (argc<5) {
            printf("Usage: CryptTest [--encrypt | --decrypt] source_file  target_file key (16 char)\n");
            return 0;
        }
        const char *opt = argv[1];
        const char *sourceFile = argv[2];
        const char *destFile = argv[3];
        const char *key = argv[4];
        
        NSString *operation = [NSString stringWithFormat:@"%s", opt];
        NSError *error = nil;
        
        if ([operation isEqualToString:@"--encrypt"]) {
            error = [UUCryptUtil encrypt:[NSString stringWithFormat:@"%s", sourceFile] to:[NSString stringWithFormat:@"%s", destFile] key:[NSString stringWithFormat:@"%s", key]];

        }else if ([operation isEqualToString:@"--decrypt"]){
            error = [UUCryptUtil decrypt:[NSString stringWithFormat:@"%s", sourceFile] to:[NSString stringWithFormat:@"%s", destFile] key:[NSString stringWithFormat:@"%s", key]];
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
