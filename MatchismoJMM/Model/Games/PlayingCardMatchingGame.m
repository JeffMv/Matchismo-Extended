//
//  PlayingCardMatchingGame.m
//  MatchismoJMM
//
//  Created by jeffrey.mvutu@gmail.com on 11.11.14.
//  Copyright (c) 2014 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//

#import "PlayingCardMatchingGame.h"

@interface PlayingCardMatchingGame ()






@end


@implementation PlayingCardMatchingGame


#pragma mark - Overriden abstract methods





#pragma mark - Initialisation


- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck {
    self = [super initWithCardCount:count usingDeck:deck];
    
    if (self){
        // more specific initialisation ...
    }
    
    return self;
}


@end
