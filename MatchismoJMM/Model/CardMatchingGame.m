//
//  CardMatchingGame.m
//  MatchismoJMM
//
//  Created by jeffrey.mvutu@gmail.com on 20.06.14.
//  Copyright (c) 2014 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame() // a class extension

// @property (nonatomic, readwrite) NSUInteger score; //
@property (nonatomic, readwrite) NSInteger score; // redéclaration pour pouvoir implémenter un setter. readwrite is the default. So here we have to specify it (otherwise it would be read-only).

@property (nonatomic, strong) NSMutableArray *cards; // of Cards


// That's the internal part of what has been done (matched cards, penalties, selected cards, ...)
// The idea is to put it in the controller and not in the model, since the view doesn't have to talk to the model.
// Here I decide to put this code in the chooseCardAtIndex method because ...
@property (nonatomic, strong) NSMutableArray *matchLogs; // of NSString (what has been done)
// @property (nonatomic, strong) NSString *gameLog; // old implementation of required task nbr. ..

@end




#pragma mark - Constants

// may have to be defined in subclasses

// Two ways in Objective-C to write constants (ways inherited from C).

#define WOUAHOUH_MULTIPLIER 1
//#define WOUAHOUH_MULTIPLIER 138

#define MISMATCH_PENALTY 2
#define MATCH_BONUS 4*WOUAHOUH_MULTIPLIER
#define COST_TO_CHOSE 1*WOUAHOUH_MULTIPLIER
#define SCORE_SPECIAL_PENALTY 12

// static const int MISMATCH_PENALTY = 1;
//static const int MATCH_BONUS = 4;
//static const int COST_TO_CHOSE = 1;

//static const int SCORE_SPECIAL_PENALTY = 12;




@implementation CardMatchingGame
{
    /*
    int numberOfPendingActions = 0;
     */
    
    NSMutableArray *lastChosenContext;
}


#pragma mark - doef

- (NSString *)gameSavingKey
{
    return nil;
}

- (NSString *)maxScoreKey {
    return @"maxScore";
}

- (NSString *)lastMaxScoreKey {
    return @"lastMaxScore";
}





#pragma mark - Saving game state

// abstract
- (void)saveGameInfos {
    
}


#pragma mark - Game restore

// abstract ?
- (BOOL)loadGameInfos{
    return NO;
}






#pragma mark - Public Interface

-(NSString *)lastOperation
{
    return [self.matchLogs lastObject];
}


-(NSUInteger)amountOfOperations{
    return self.matchLogs.count;
}

-(NSString *)operationAtIndex:(NSUInteger)index
{
    if (index >= [self amountOfOperations]) return nil; // out of bounds check
    return [self.matchLogs objectAtIndex:index];
}




#pragma mark - tricks

/*
- (BOOL)canAct {
    if (...){...}
    return YES;
}
*/



- (void)saveChosenContext {
    
    NSMutableArray *chosenStates = [[NSMutableArray alloc] init];
    
    for (Card *card in self.cards){
        // je prends l'état booléen
        
        NSNumber *chosen = [NSNumber numberWithBool:card.isChosen];
        [chosenStates addObject:chosen];
        
    }
    
    lastChosenContext = chosenStates;
     
}



- (BOOL)restoreChosenContext {
    
    if (!lastChosenContext || lastChosenContext.count != self.cards.count){ return FALSE ; }
    
    for (int i=0; i < lastChosenContext.count ; ++i){
        NSNumber *chosen = (NSNumber *) [lastChosenContext objectAtIndex:i] ;
        
        Card *carte = [self.cards objectAtIndex:i];
        carte.chosen = [chosen boolValue];
    }
    
    
    // on clear le contexte
    lastChosenContext = nil;
     
    
    
    return true;
}



#pragma mark - Jeu - Bonuses


- (void)bonusShowAllCardsAndNotify:(id)sender actionAtBegining:(SEL)firstAction actionAtEnd:(SEL)lastAction
{
    [self bonusShowAllCards];
    
    // for instance (f.i.) updateUI
    [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)0.0 target:sender selector:firstAction userInfo:nil repeats:NO];
    
    NSTimeInterval delai = 3.0;
    
    // on prépare la classe à recacher toutes les cartes
    [NSTimer scheduledTimerWithTimeInterval:delai target:self selector:@selector(restoreChosenContext) userInfo:nil repeats:NO];
    
    // f.i. updateUI at the end
    [NSTimer scheduledTimerWithTimeInterval:delai target:sender selector:lastAction userInfo:nil repeats:NO];
    
}



- (void)bonusShowAllCards {
    
    //
    if ([self canUseShowAllCardsBonus]){ // don't allow the use of the bonus if the user has no score

        // save chosen context
        [self saveChosenContext];

        // DURING time interval
        
        
        
            // Let non-matched cards be revealed
        for (Card *card in self.cards){
            card.chosen = (!card.isMatched) ? YES : card.chosen; // switch only visible cards.
        }
        
        // restore chosen context
        // [self restoreChosenContext];
        
        
        NSUInteger penalty = SCORE_SPECIAL_PENALTY;
        self.score -=  penalty;
        [self setLastOperation:[NSString stringWithFormat:@"Used show cards bonus : %i points !", (int) (-penalty)]];
    }

}


- (BOOL)canUseShowAllCardsBonus
{
    return (!lastChosenContext && self.score > SCORE_SPECIAL_PENALTY) ? YES : NO ;
}


#pragma mark - Game controls



-(void)chooseCardAtIndex:(NSUInteger)index
{
    if (! (index < [self.cards count])){
        return ;
    }
    
    Card *card = [self cardAtIndex:index];
    
    if (!card.isMatched){ // si la carte n'est pas déjà trouvée (la paire a été trouvée)
        if (card.isChosen){ // si la carte est déjà selectionnée
            card.chosen = NO; // on la déselectionne
        } else {
            card.chosen = TRUE;
        }
    }
    
    if (card.isChosen){
        // [self setLastOperation:card.contents]; // la carte qui vient d'être selectionnee
        [self setLastOperation:[self contentsOfCardsInArray:[self selectedCards]]]; // pour afficher toutes les cartes actuellement selectionnees
    } else {
        [self setLastOperation:@""];
    }

    
    BOOL matched = FALSE;
    BOOL performedMatch = FALSE;
    
    if ([self selectedCards].count == self.numberOfMatch){
        performedMatch = TRUE;
        matched = [self performCardMatching];
    
        if (matched){
            // on laisse FACE-UP les cartes matched => isChosen == true toujours
        }
        else {
            // on retourne les cartes autres cartes
            for (Card *carte in self.cards){
                if (!carte.isMatched) carte.chosen = false;
            }
            
            // la dernière carte choisie doit être toujours visible.
            card.chosen = true;
        }
    }
    
    
    // Si on n'a pas tenté de faire un match et si la carte était FACE-DOWN
    // on pénalise le score pour avoir tourné la carte en FACE-UP
    if (!performedMatch && card.isChosen){
        self.score -= COST_TO_CHOSE ;
    }

}


// true s'il y a eu match
-(BOOL)performCardMatching
{
    
    NSMutableArray *chosenCards = [self selectedCards];
    
    // si on a le nombre requis de cartes
    if ([chosenCards count] != self.numberOfMatch){     // qd mm check, en cas de runtime modif.
        return FALSE;
    }
    
    
    int matchScore = 0;
    Card *carte = [chosenCards firstObject];
    
    if (carte){
        [chosenCards removeObject:carte];
        
        // on tente de matcher les cartes
        matchScore = [carte match:chosenCards];
        
        [chosenCards addObject:carte];
    }
    
    // attribution/déduction de score
    if (matchScore){ // s'il y a eu un match
        
        NSUInteger gainedScore = matchScore * MATCH_BONUS;
        
        // log
        [self setLastOperation:[NSString stringWithFormat:@"Matched %@ for %lu points.", [self contentsOfCardsInArray:chosenCards], (unsigned long)gainedScore] ];
        
        self.score += gainedScore;
        for (Card *card in chosenCards){
            card.matched = true;
        }
        
        return true;
    }
    
    else { // si pas de match :(
        
        NSUInteger lostScore = MISMATCH_PENALTY;
        
        // log
        [self setLastOperation:[NSString stringWithFormat:@"%@ don't match! %lu point(s) penalty!", [self contentsOfCardsInArray:chosenCards], (unsigned long)lostScore]];
        
        self.score -= lostScore; // on inflige une pénalité
        return false;
    }
}

-(NSString *)contentsOfCardsInArray:(NSArray *)cards
{
    NSMutableString *content = [[NSMutableString alloc] init];
    
    for (Card *card in cards){
        [content appendString:card.contents];
    }
    
    return content;
}

-(NSMutableArray *)selectedCards
{
    NSMutableArray *cartes = [[NSMutableArray alloc] init];
    
    for (Card *carte in self.cards){
        if (!carte.isMatched && carte.isChosen){
            [cartes addObject:carte];
        }
    }
    
    // if (cartes.count == 0) return nil;
    return cartes;
}


-(NSInteger)score
{
    /* If we don't want to return a negative scores
    // It is not clean for a user to have a negative score
    // Even though the user  can 'cheat' by seeing all the cards, at the beginning and then matching them with his/her memory,
    // this is the way I choose to count the score. (For, at last, the user will (or just may) get tired of cheating this way ;)
    if (_score < 0) return 0;
    */
    
    return _score;
}


#pragma mark - Keeping track of operations


-(void)setLastOperation:(NSString *)result
{
    [self.matchLogs addObject:result];
}


#pragma mark - Accessing cards

-(NSMutableArray*)cards
{
    if (!_cards){ _cards = [[NSMutableArray alloc] init]; } // lazy instantation.
    return _cards;
}


-(Card *)cardAtIndex:(NSUInteger)index
{
    return ( index < [self.cards count] ) ? self.cards[index] : nil ;
}



#pragma mark - Initialisations

-(NSMutableArray *)matchLogs
{
    if (!_matchLogs){ // lazy instantiation
        _matchLogs = [[NSMutableArray alloc] init];
    }
    
    return _matchLogs;
}


-(instancetype)init // overwritting the default init
{
    return nil; // because the current object is not properly initialized.
}

-(instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
{
    self = [super init];
    
    if (count < 2){ self = nil; NSLog(@"%s: cannot play a card matching game with < 2 cards", __PRETTY_FUNCTION__); } // must match at least two cards
    NSUInteger initialCardCountInDeck = [deck amountOfCards];
    NSLog(@"%s: \n # cards to be used in the game: %i \n # number of cards in the deck you provided: %i cards", __PRETTY_FUNCTION__, (int)count, (int)initialCardCountInDeck);

    
    if (self){
        for (int i =0 ; i < count; ++i){
            Card *card = [deck drawRandomCard];
            if (card){ // as long as we have cards
                
                // self.cards[i] = card; // another way to add a card. The array is mutable, so there's no problem.
                [self.cards addObject:card]; // more clear.
                
            } else {
                self = nil ; // or maybe we should put the cards back in the deck.
                NSLog(@"%s: Invalid deck \n Not enough cards in the deck you provided. Expected %i, deck contained %i cards", __PRETTY_FUNCTION__, (int)count, (int)initialCardCountInDeck);
                break; // break the for loop.
            }
        }
        
        // default score ?
        // self.score = 10;
    }
    
    
    return self;
}



@end
