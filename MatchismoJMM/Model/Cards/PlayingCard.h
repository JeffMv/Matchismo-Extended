#import "Card.h"


/** Playing Card, for a game like Poker, .. .. ..
 * 
 */
@interface PlayingCard : Card

// La "couleur" (sens large) de la carte
@property (strong, nonatomic) NSString *suit ; // if uninitialized, will be '?'

// Le rang (puissance de la carte).
@property (nonatomic) NSUInteger rank ; // if uninitialized, will be '?'

// @return NSArray of strings that are valid for these playing cards
+ (NSArray *)validSuits;

// @return the maximum rank that can be entered. the minimum is 1 (apart from the 0, which is for an uninitialized instance's rank).
+ (NSUInteger)maxRank;


// - (int)match:(NSArray *)otherCards; // pas besoin de redéclarer la méthode en Obj-C. Usually, we do not REdeclare OVERRIDEN methods in Obj-C.


@end
