//
//  NSString+Additions.m
//  Odometer
//
//  Created by Chris Paveglio on 3/30/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

/** Reverses a given string */
- (NSString *)reversed {
    NSString *reverseString = [NSString new];
    for (NSInteger i = self.length - 1; i > -1; i--) {
        reverseString = [reverseString stringByAppendingFormat:@"%c", [self characterAtIndex:i]];
    }
    return reverseString;
}

@end
