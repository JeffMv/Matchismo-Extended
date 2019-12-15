#import "Card.h"

@interface Card() //
// ... // declarations of private properties and methods
// ... // Usually, it's for declaring properties

@property (strong, nonatomic, readwrite) NSString *contents;  // readwrite privately

@end


@implementation Card


- (int)match:(NSArray<Card *> *)otherCards
{
	int score = 0;

	// Note the   for-in   looping syntax. It is called 'fast enumeration'. It works on arrays, dictionaries, etc, ..
	for (Card *otherCard    in    otherCards) {
		if ( [otherCard.contents isEqualToString:self.contents] ) {
			score = score + 1 ;
		}
	}

	return score;
}


- (NSString *)description
{
    NSString* desc = [super description];
    return [desc stringByAppendingString:[NSString stringWithFormat:@" Content=%@", self.contents]
             ];
}



// Getters and setters (and synthesize)
// Objective-C will write them all for us (getters and setters)
// There are there, even though I don't see them


@end
