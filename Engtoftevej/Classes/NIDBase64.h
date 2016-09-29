//
//  NSData+Base64.h
//  base64
//
//  Copyright Nets-DanID A/S. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>

@interface NIDBase64 : NSObject {
    
}

+ (NSData *)dataFromBase64String:(NSString *)aString;
+ (NSString *)stringFromBase64String:(NSString *)aString;
+ (NSString *)base64EncodedString:(NSData*)data;
+ (NSString *)base64EncodedStringWithString:(NSString*)aString;

+ (NSString *)base64EncodedStringNoCRLF:(NSData *)data;
+ (NSString *)base64EncodedStringWithStringNoCRLF:(NSString *)aString;

@end
