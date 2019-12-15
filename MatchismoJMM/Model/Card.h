// #import <Foundation/NSObject.h> // superclass's header file
#import <Foundation/Foundation.h> // If the superclass is in iOS itself, we import THE ENTIRE framework

// OR , on iOS 7
// @import Foundation // imports an entire framework.



// Our public API for this class
@interface Card : NSObject

// the contents of the card (Ace of clubs for example)
@property (strong, nonatomic, readonly) NSString *contents ;  // readonly BUT  IDEE DE JEU : lorsque combo, la couleur de la carte change (p. ex. si on utilise une sorte de joker dessus)
	// @property because we need this storage per instance
	// why * : in Obj-C, all objects live in the heap (une sorte de pile, dans la mémoire).



//type bool en plus du C : codé comme un type de base
@property (nonatomic, getter=isChosen) BOOL chosen;  // nonatomic because we still want the setter-getter to be simple (e.g. no locking code, et ceatera)
@property (nonatomic, getter=isMatched) BOOL matched; 


/** Tells whether this card matches with any of the cards of those passed in parameters
 * @param NSArray of cards.
 * @return int : 0 if there are no matches. otherwise, it is positive *and equal to 1* (#Jeff : we may change this and set it to return a score, depending on how good was the match).
 */
- (int)match:(NSArray<Card *> *)otherCards;




@end
