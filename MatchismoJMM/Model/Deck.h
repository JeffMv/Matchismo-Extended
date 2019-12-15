#import <Foundation/Foundation.h>
#import "Card.h"


/** A deck is a container of cards.
 * The cards we're actually talking about are generic (and thus could be flashing cards or Pokemon cards or whatever)
 */
@interface Deck : NSObject

    /** Adds a card in the deck
     * @param BOOL atTop : By default (using the second method), it will be ...
     */
- (void)addCard:(Card *)card atTop:(BOOL)atTop ;
- (void)addCard:(Card *)card;


- (Card *)drawRandomCard;

- (NSUInteger)amountOfCards;
//- (NSUInteger)count;

@end

