//
//  BirthdayCardDeck.m
//  MatchismoJMM
//
//  Created by user on 06.10.17.
//  Copyright © 2017 Jeffrey Mvutu Mabilama. All rights reserved.
//

#import "BirthdayCardDeck.h"
#import "TextualCard.h"

@implementation BirthdayCardDeck

- (void)setWish:(NSString *)wish characterCountPerCard:(NSUInteger)charCountPerCard {
    // first we draw all the cards out of the deck
    while (self.amountOfCards > 0) {
        [self drawRandomCard];
    }
    
    // tokenize card contents
    NSMutableString *curSeq = [NSMutableString string];
    NSMutableArray *cardTexts = [NSMutableArray array];
    for (int i=0; i < wish.length; ++i) {
        NSString *nextChar = [[wish substringFromIndex:i] substringToIndex:1];
        if ([self isWhitespace:nextChar] || curSeq.length>=charCountPerCard || (i==wish.length-1) ) {
            // stop
            [cardTexts addObject: curSeq ];
            
            curSeq = [NSMutableString string];
//            [curSeq appendString:nextChar];
            // OR
            [cardTexts addObject:nextChar]; // adds the whitespace
        } else {
            [curSeq appendString:nextChar];
        }
    }
    
    // adding cards
    for (NSInteger i=cardTexts.count-1; i >= 0; --i) {
        NSString *content = cardTexts[i];
        TextualCard *card = [[TextualCard alloc] init];
        card.textContent = content;
        [self addCard:card];
    }
}

- (BOOL)isWhitespace:(NSString *)c {
    NSSet *ws = [NSSet setWithObjects:@" ", @"\n", @"\t", nil];
    return [ws containsObject:c]; // NSString's isEqual method is used
}

@end
