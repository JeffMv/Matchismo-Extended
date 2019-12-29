//
//  JMMCardGameStandardOptions.m
//  MatchismoJMM
//
//  Created by Jeffrey Mvutu Mabilama on 05.12.14.
//  Copyright (c) 2014 Jeffrey Mvutu Mabilama. All rights reserved.
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
