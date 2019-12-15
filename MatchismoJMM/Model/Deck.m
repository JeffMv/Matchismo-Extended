#import "Deck.h"

@interface Deck() // private stuffs

/** Our cards. NSMutableArray of cards.
 */
@property (strong, nonatomic) NSMutableArray *cards ;

@end


@implementation Deck

// D'un point de vue de la facilité vis-à-vis de l'implementation, il convient de placer le sommet de la pile à l'index 0 (comme ça on peut piocher une carte à l'index 0 (si elle existe)), tandis que ce serait plus casse-pied de déterminer le dernier index des autres piles.
- (void)addCard:(Card *)card atTop:(BOOL)atTop
{
    if (/*card &&*/ atTop) // si la carte est initialisée
    {
        [self.cards insertObject:card atIndex:0];
    }
    else if (/*card &&*/ !atTop)
    {
        [self.cards addObject:card];
    }
}

- (void)addCard:(Card *)card
{
    [self addCard:card atTop:NO];
}

- (Card *)drawRandomCard
{
	Card *foundRandomCard = nil ; // The default value I want for the card (in order to be careful).

	// If there is something in cards (because we will access/withdraw something from the deck)
	if ( [self.cards count] ) // self == deck, self.cards is a getter (returns a NSMutableArray), and count is a method of NSMutableArray
	{
		unsigned int index = arc4random() /*random number*/ % [self.cards count] ;
		foundRandomCard = self.cards[index] /*the .[] is also a message, but shortened */  ;
		// we remove the card from the deck
		[self.cards removeObjectAtIndex:index];
	}

	return foundRandomCard ;
}


- (NSUInteger)amountOfCards
{
    return [self.cards count];
}
- (NSUInteger)count {
    return [self amountOfCards];
}

// VERIFIER LES ALLOCATIONS DE MEMOIRE !!!  et les envois de messages à des POINTEURS POUVANT ETRE nil . //
- (NSMutableArray *)cards
{
    if (!_cards) // lazy instantiation
    {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}


@end
