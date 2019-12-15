//
//  TextualCard.m
//  MatchismoJMM
//
//  Created by user on 06.10.17.
//  Copyright © 2017 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//

#import "TextualCard.h"

@implementation TextualCard

- (NSString *)contents {
    return self.textContent;
}

- (NSString *)textContent {
    if (!_textContent) {
        _textContent = @"";
    }
    return _textContent;
}

/**
 *  If this card is empty and it is matched with another empty card, good point.
 *  If this card is not empty, the other card must be non empty too, but contents may vary.
 */
- (int)match:(NSArray<TextualCard *> *)otherCards {
    NSInteger baseScore = 3;
    NSInteger curMultiplier = 1;
    NSInteger score = 0;
//    if ([self.contents isEqualToString:@""])
    for (Card *card in otherCards) {
        if ([self.contents isEqualToString:card.contents]) {
            score += curMultiplier * baseScore;
            ++curMultiplier;
        }
    }
    return score;
}

@end
