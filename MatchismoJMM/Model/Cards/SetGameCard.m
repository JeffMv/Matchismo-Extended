//
//  SetGameCard.m
//  MatchismoJMM
//
//  Created by jeffrey.mvutu@gmail.com on 11.11.14.
//  Copyright (c) 2014 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//

#import "SetGameCard.h"


@interface SetGameCard ()


@property (strong, nonatomic, readwrite) NSString *contents;



@end


@implementation SetGameCard
@synthesize contents = _contents;



- (void)setContents:(NSString *)contents {
    
    
    
}

- (NSString *)contents {
    if (!_contents){ // #LazyInitialization
     
        
        
        
        
    }
    return _contents;
}





- (int)match:(NSArray *)otherCards {
    int score = 0;
    if (otherCards.count != 2) { return score; }
    
    
    
    
    
    return score;
}



@end
