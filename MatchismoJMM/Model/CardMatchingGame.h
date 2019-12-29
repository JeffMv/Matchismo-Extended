//
//  CardMatchingGame.h
//  MatchismoJMM
//
//  Created by Jeffrey Mvutu Mabilama on 20.06.14.
//  Copyright (c) 2014 Jeffrey Mvutu Mabilama. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "Deck.h"


//#ifdef CardMatchingGame_DelegateFeature

/*
enum GeneralCardMatchingGameEnd {
    GeneralCardMatchingGameEndPlayerWon,
    GeneralCardMatchingGameEndPlayerLost,
    GeneralCardMatchingGameEndNoMoreMatchButStillUnmatchedCards
};
*/

/*
typedef GeneralCardMatchingGameEnd : NSUInteger {
    GeneralCardMatchingGameEndPlayerWon,
    GeneralCardMatchingGameEndPlayerLost,
    MyEnumValueC,
} GeneralCardMatchingGameEnds;
*/

@protocol CardMatchingGameDelegate <NSObject>
@required
//- (void)cardMatchingGameDidEndWithStatus:(GeneralCardMatchingGameEnd )endStatus;
@optional

@end
//#endif // CardMatchingGame_DelegateFeature


@interface CardMatchingGame : NSObject

#pragma mark - Initialization

// DESIGNATED INITIALIZER (we have to call this one from the SUBCLASS'S DESIGNATED INITIALIZER) - We must always specify what is/are our designated initializer(s) if they differ from it's super-class.
-(instancetype)initWithCardCount:(NSUInteger)count
                       usingDeck:(Deck *)deck ; /// Classes can have multiple initializers, but obviously only one designated initializer


#ifdef CardMatchingGame_DelegateFeature
@property (weak, nonatomic) id delegate;
#endif // CardMatchingGame_DelegateFeature


#pragma mark - Saving and restoring game state - to be implemented

// abstract
- (NSString *)gameSavingKey;

// abstract (?)
- (void)saveGameInfos;
- (BOOL)loadGameInfos; // if problem ...


#pragma mark - Extended infos - to be implemented

//- (NSInteger)maxScore;
//- (NSInteger)lastScore;

/*
- (NSArray *)maxScores
{
    
}
 */


#pragma mark - Se mettre des objectifs

//- (NSUInteger)maximumScoreWithUnmatchedCards;
//- (NSUInteger)perfectScoreWithAllDeckCards;



#pragma mark - Informations on the Game State

// It is a game, so we want a score.
@property (nonatomic, readonly) NSInteger score;

@property (nonatomic) NSUInteger numberOfMatch; // (mode) 2 or 3 cards


#pragma mark - Logs

// A string with the result of the last card choice.
-(NSString *)lastOperation; // Assignment 2 : string with the last operation.

// How many operations have been done
// -(NSUInteger)amountOfOperations;
-(NSUInteger)amountOfOperations;

-(NSString *)operationAtIndex:(NSUInteger)index;




#pragma mark - Game - special controls

#ifndef CardMatchingGame_DelegateFeature
- (void)bonusShowAllCardsAndNotify:(id)sender actionAtBegining:(SEL)firstAction actionAtEnd:(SEL)lastAction;
#else
- (void)bonusShowAllCardsIfPossible;
#endif // CardMatchingGame_DelegateFeature

- (BOOL)canUseShowAllCardsBonus;


#pragma mark - Game controls - basic contols

//- (BOOL)canMatch; // if there are still some cards to match
//- (BOOL)countRemainingMatches;
//- (BOOL)canStillPlay;

// model method : choose the card and do all the matching and scoring and sets matched cards as matched.
-(void)chooseCardAtIndex:(NSUInteger)index ;

-(Card *)cardAtIndex:(NSUInteger)index;



@end
