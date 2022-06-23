//
//  NSAttributedStringExtension.m
//  twitter
//
//  Created by jacquelinejou on 6/23/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (SetAsLinkSupport)

- (BOOL)setAsLink:(NSString*)textToFind linkURL:(NSString*)linkURL;

@end


@implementation NSMutableAttributedString (SetAsLinkSupport)

//- (NSMutableAttributedString *)makeHyperlink:(NSString*)path string:(NSString*)string substring:(NSString*)substring {
//    NSString *nsString = [[NSString alloc] init];
//    nsString = string;
//    NSRange substringRange = [nsString rangeOfString:substring];
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
//     if (substringRange.location != NSNotFound) {
//         [self addAttribute:attributedString value:path range:substringRange];
//         return attributedString;
//     }
//     return attributedString;
//}

@end
