//
//  UIImage+SolidColors.m
//  TownKitchen
//
//  Created by Peter Bai on 3/21/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "UIImage+SolidColors.h"

@implementation UIImage (SolidColors)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
