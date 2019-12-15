#import "PlayingCard.h"

@interface PlayingCard()

@property (strong, nonatomic, readwrite) NSString *contents;  // readwrite privately 


@end


@implementation PlayingCard

@synthesize contents = _contents; // manual synthesis because property is readonly in a super class's public API.

@synthesize suit = _suit; // we implement both the setter and the getter, so we must explicitly write it.


#pragma mark - Matching Conditions

        //  overridden methods  //
-(int)match:(NSArray<Card *> *)otherCards
{
    // Souvent, lors d'une redéfinition, la sous-classe appelle la méthode de la super classe.
    // Cependant, ici, PlayingCard possédera sa propre implémentation de cette méthode.
    
    int score = 0;
    
    if (otherCards.count == 1){
        PlayingCard *autreCarte = (PlayingCard *) [otherCards firstObject]; // firstObject returns nil if ..
        
        score = (int) [self twoCardMatching:autreCarte];
        
    } else if (otherCards.count == 2){ // trying to match 3 cards together
       
        NSMutableArray *cartes = [NSMutableArray arrayWithArray:otherCards];
        [cartes addObject:self];
        
        score = (int) [self threeCardMatching:cartes];
    }
    else if (otherCards.count == 3) // matching 4 cards.
    {
        NSLog(@"Matching 4 cards not implemented");
    }
    
    return score;
}



- (BOOL)sameRankAsCard:(PlayingCard *)card
{
    // if (card.rank == [self specialRank])
    if (card && self.rank == card.rank)
        return true;
    
    return false;
}

- (BOOL)sameSuitAsCard:(PlayingCard *)card
{
    if (card && self.suit == card.suit)
        return true;
    return false;
}



#pragma mark - Card matching modes (number of match)


- (NSUInteger)twoCardMatching:(PlayingCard *)autreCarte
{
    if (!autreCarte) return 0;
    int score = 0;
    
    if (autreCarte && autreCarte.rank == self.rank){
        score = 6; // points for matching the rank
    } else if ( autreCarte && [autreCarte.suit isEqualToString:self.suit]){
        score = 2; // more cards that will have the same suit.
    }

    return score;
}

// le score de ...
- (NSUInteger)threeCardMatching:(NSArray *)cartes
{
    NSUInteger nbSameRanks = [self numberOfMatchingRanks:cartes];
    NSUInteger nbSameSuits = [self maxNumberOfMatchedSuitInCards:cartes];
 
    NSUInteger matchScore = 0;
    
    /** Matching cases
     */
    
    if (nbSameRanks == 3 /*there should also be no suits matched  so nbSuitsMatched == 0 */){
        // max points
        matchScore = 12; //
    } else if (nbSameRanks == 2 && nbSameSuits == 2){
        // ...
        matchScore = 9;
    }
    else if ( nbSameRanks == 2 /* && nbSameSuits == 0 */ ){
        matchScore = 7;
    } else if ( nbSameSuits == 3){
        matchScore = 4; //
    } else if (nbSameSuits == 2){
        matchScore = 2; //
    }
    // no match in ranks nor in suits
    else {
    }
    
    
    return matchScore;
}


- (NSUInteger)fourCardMatching:(NSArray *)cartes
{
    NSUInteger nbSameRanks = [self numberOfMatchingRanks:cartes];
    NSUInteger nbSameSuits = [self maxNumberOfMatchedSuitInCards:cartes];
    
    NSUInteger matchScore = 0;
    
    
    /** Matching cases
     */
    
    if (nbSameRanks == 4 /*there should also be no suits matched  so nbSuitsMatched == 0 */){
        // max points
        matchScore = 20; //
    } else if (nbSameRanks == 3){
        // ...
        matchScore = 13;
    }
    else if (nbSameRanks == 2 && nbSameSuits == 2){
        // ...
        matchScore = 9;
    }
    else if ( nbSameRanks == 2 /* && nbSameSuits == 0 */ ){
        matchScore = 7;
    } else if ( nbSameSuits == 3){
        matchScore = 4; //
    }
    // not enough matches in both suits and ranks
    else {
    }
    
    
    return matchScore;
}



#pragma mark - Counting
// c'est ici qu'il faut modifier si l'on ajoute un joker


//
-(NSUInteger)maxNumberOfMatchedSuitInCards:(NSArray *)cards
{
    NSUInteger max=0;
    
    for (NSString *suit in [PlayingCard validSuits]){
        NSUInteger nb = [self numberOfCardsOfSuit:suit inCards:cards];
        
        if (nb > max){
            max = nb;
        }
    }
    
    return max;
}

// le nombre de couleurs pour lesquelles on a au moins une paire
- (NSUInteger)numberOfMatchingSuits:(NSArray *)cartes
{
    NSUInteger nb =0;
    for (NSString *suit in [PlayingCard validSuits]){
        if ([self numberOfCardsOfSuit:suit inCards:cartes] >= 2){
            ++nb;
        }
    }
    
    return nb;
}

-(NSUInteger)numberOfCardsOfSuit:(NSString *)suit inCards:(NSArray *)cards
{
    NSUInteger nb=0;
    for (PlayingCard *carte in cards){
        if ([carte.suit isEqualToString:suit]) {
            ++nb;
        }
    }
    return nb;
}


// 0 - 4
- (NSUInteger)numberOfMatchingRanks:(NSArray *)cartes
{
    NSMutableArray *mRank = [[NSMutableArray alloc] init];
    NSMutableArray *mCount = [[NSMutableArray alloc] init];
    
    for (PlayingCard *carte in cartes){
        NSNumber *rang = [NSNumber numberWithInteger:carte.rank];
        
        if ([mRank containsObject:rang]){
            NSInteger index = [mRank indexOfObject:rang];
            
            NSNumber *decompte = [mCount objectAtIndex:index]; // retourne une copie de l'instance
            decompte = [NSNumber numberWithInteger:([decompte integerValue] + 1) ];
            
            [mCount replaceObjectAtIndex:index withObject:decompte];
            
        } else {
            [mRank addObject:rang];
            [mCount addObject:[NSNumber numberWithInt:1]]; // compte une fois
        }
    }
    
    
    // parcourir le dictionnaire à la recherche de la paire max.
    NSUInteger maxVal =0;
    
    for (NSInteger i=0; i < mRank.count ; ++i){
        
        NSInteger tmpval = [[mCount objectAtIndex:i] integerValue];

        if (maxVal < tmpval) {
            maxVal = tmpval;
        }
    }

    return maxVal;
}

#pragma mark - Playing Card Content

+ (NSArray *)validSuits //
{
	return @[@"♥",@"♦",@"♠",@"♣"] ;
}

+ (NSUInteger)maxRank
{
	// return [ [self rankStrings] count]-1; // du prof
	return [[PlayingCard rankStrings] count]-1 ; // mon idée
}
// private, because the public API for the rank is integer (NSUInteger).
+ (NSArray *)rankStrings
{
	// if ... is 0 ;
	return @[@"?" /*for the nil*/, @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"];
}


- (NSString *)contents // getter of the upper class Card
{
	NSArray *rankStrings = [PlayingCard rankStrings] ; // @ makes an object
    
	// retourne Rang|Couleur
	return [rankStrings[self.rank] stringByAppendingString:self.suit] ;
}


- (void)setRank:(NSUInteger)rank
{
    if ( 0 < rank && rank <= [PlayingCard maxRank]){
        _rank = rank;
    } else {
		// convention ?
	}
}


// We want to protect the _suit property from people setting wrong suit
- (void)setSuit:(NSString *)suit
{
	// if (not [@[@"♥",@"♦",@"♠",@"♣"] doesNotContain:suit] )
	if ( [[PlayingCard validSuits] containsObject:suit] ) // creating an NSArray on the fly
	{
		_suit = suit;
	}
}

// overwritting getter of the upper class
- (NSString *)suit
{
	return _suit ? _suit : @"?" ; // if _suit is not nil, otherwise return @"?"
}




@end


