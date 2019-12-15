//
//  JMMCardGameStandardOptions.m
//  MatchismoJMM
//
//  Created by jeffrey.mvutu@gmail.com on 05.12.14.
//  Copyright (c) 2014 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//

#import "JMMCardGameStandardOptions.h"


@interface JMMCardGameStandardOptions ()

@end
@implementation JMMCardGameStandardOptions

+(instancetype)sharedOptionSaver
{
    static JMMCardGameStandardOptions *sharedInstance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [[JMMCardGameStandardOptions alloc] init];
    });
    
    return sharedInstance;
}

@end
