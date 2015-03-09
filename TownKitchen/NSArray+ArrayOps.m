//
//  NSArray+ArrayOps.m
//  Yelp
//
//  Created by Miles Spielberg on 2/11/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "NSArray+ArrayOps.h"

@implementation NSArray (ArrayOps)

+ (NSArray *)arrayWithRangeFrom:(NSInteger)from to:(NSInteger)to {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:to - from + 1];
    for (NSInteger i = from; i <= to; i++) {
        [result addObject:@(i)];
    }
    return [NSArray arrayWithArray:result];
}

- (id)foldWithZero:(id)z block:(id(^)(id, id))op {
    for (id x in self) {
        z = op(z, x);
    }
    return z;
}

- (NSArray *)mapWithBlock:(id(^)(id))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id x in self) {
        [result addObject:block(x)];
    }
    
    return [NSArray arrayWithArray:result];
}

- (id)firstItemMatching:(BOOL(^)(id))block {
    for (id x in self) {
        if (block(x)) {
            return x;
        }
    }
    
    return nil;
}

@end
