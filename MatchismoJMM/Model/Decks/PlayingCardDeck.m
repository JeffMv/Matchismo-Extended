#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@interface PlayingCardDeck()

@end


@implementation PlayingCardDeck

- (instancetype)init
{
    self = [super init] ;
    // Puisqu'on a affecté le résultat de l'initialisation de la super-classe à self, on peut tester si l'initialisation s'est bien passée ou pas.

    if (self)
    {
            // Maintenant que l'initialisation de la super-classe est garantie, on peut initialiser l'instance de cette classe comme il nous semble bon.
     
            // On va assigner au lot de cartes de la super-classe u ne carte particulière.
        // Pour cela, on itère
        for (NSString *couleur in [PlayingCard validSuits])
        {
            for (NSUInteger rank = 1; rank <= [PlayingCard maxRank]; rank++ )
            {
                PlayingCard *card = [[PlayingCard alloc] init];
                card.suit = couleur ;
                card.rank = rank ;
                [self addCard:card atTop:YES] ;
            }
        }
        // NSLog(@"   The freshly created deck contains %d cards.", [self amountOfCards]);
    }
    
    return self ;
}



@end

