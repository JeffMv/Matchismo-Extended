//
//  CardGameViewController.h
//  MatchismoJMM
//
//  Created by jeffrey.mvutu@gmail.com on 11.06.14.
//  Copyright (c) 2014 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//
// abstract class. Must implement methods as described bellow

#import <UIKit/UIKit.h>

#import "Deck.h"


/** The screen for the card matching game
 *
 */
@interface CardGameViewController : UIViewController

@property (strong, nonatomic, readonly) IBOutletCollection(UIButton) NSArray *cardButtons;

// protected
// for subclasses only
- (Deck *)createDeck; // abstract

@end
