//
//  NSArray+ArrayOps.h
//  Yelp
//
//  Created by Miles Spielberg on 2/11/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ArrayOps)
+ (NSArray *)arrayWithRangeFrom:(NSInteger)from to:(NSInteger)to;
- (NSArray *)mapWithBlock:(id(^)(id))block;
- (id)firstItemMatching:(BOOL(^)(id))block;
@end
