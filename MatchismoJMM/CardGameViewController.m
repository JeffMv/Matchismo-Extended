//
//  CardGameViewController.m
//  MatchismoJMM
//
//  Created by jeffrey.mvutu@gmail.com on 11.06.14.
//  Copyright (c) 2014 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"
#import <AVFoundation/AVFoundation.h>
#import <math.h>


@interface CardGameViewController () <AVAudioPlayerDelegate>
//@property (weak, nonatomic) IBOutlet UILabel *flipLabel; // weak storage, because THIS view has a strong pointer to it, so it will keep it in the heap as long as I don't "kill" this view.
// Whenever it would be necessary to keep some infos between views, I may use strong pointers.


// Les cartes dans lesquelles piocher.
@property (strong, nonatomic) Deck *deck;


@property (strong, nonatomic) CardMatchingGame *game ;// Link to my model -- it's a way to do the thing
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (strong, nonatomic, readwrite) IBOutletCollection(UIButton) NSArray *cardButtons;

@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOfMatchMode;


@property (weak, nonatomic) IBOutlet UITextView *matchInfoLabel; // what the user has done
@property (weak, nonatomic) IBOutlet UISlider *matchInfoHistorySlider; // slider to travel through the logs


@property (weak, nonatomic) IBOutlet UILabel *retournements; // label
@property (nonatomic) int nbRetournements; // number of flips


@property (weak, nonatomic) IBOutlet UIButton *bonusButtonShowAll;
@property (weak, nonatomic) IBOutlet UIButton *bonusesButton;

@property (weak, nonatomic) IBOutlet UIButton *boutonNouvellePartie;

// playing sounds, especially moving card sounds
@property (strong, nonatomic) NSMutableArray<AVAudioPlayer *> *busyAudioPlayers;
//@property ()
@end

#define CARD_GAME_VC_Default_CornerRadius 10.0
#define CARD_GAME_VC_Default_BorderWidth 2.0
#define CARD_GAME_VC_Default_UIColor [UIColor redColor]
#define CARD_GAME_VC_Default_Alpha 0.5


@implementation CardGameViewController
{
    BOOL gameDidStart;
    NSUInteger currentMatchInfosIndex;
}

#pragma mark Audio Management

- (AVAudioPlayer *)playNewSound:(NSURL *)audioFileUrl withDelay:(NSTimeInterval)delay {
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileUrl error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    return [self registerPlayerAndPlay:player withDelay:delay];
}

- (AVAudioPlayer *)registerPlayerAndPlay:(AVAudioPlayer *)player withDelay:(NSTimeInterval)delay {
    player.delegate = self;
    [self.busyAudioPlayers addObject:player];
    if (![player playAtTime: player.deviceCurrentTime + delay ]) {
        NSLog(@"Cannot play sound. AVAudioPlayer's settings: %@", player.settings);
    }
    return player;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.busyAudioPlayers removeObject:player];
}


#pragma mark - Changing Subviews' Appearance


void roundViewCornersWithCornerRadius(UIView *view, CGFloat cornerRadius)
{
    view.layer.cornerRadius = cornerRadius;
}

void strokeViewWithColor(UIView *view, UIColor *color)
{
    [view.layer setBorderColor:[color CGColor]];
}

void strokeViewWithColorAndBorderWidth(UIView *view, UIColor *color, CGFloat borderWidth)
{
    strokeViewWithColor(view, color);
    [view.layer setBorderWidth:borderWidth];
}

void changeStrokeAlpha(UIView *view, CGFloat alpha)
{
    view.layer.borderColor = CGColorCreateCopyWithAlpha(view.layer.borderColor, alpha);
}



#pragma mark - Animations


- (void)animatedRedraw
{
    // Ensure the user does not launch an animation while this one is occuring.
    self.boutonNouvellePartie.enabled = NO;
    gameDidStart = NO;

    NSMutableArray *indexes = [NSMutableArray array];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.cardButtons.count-1)];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexes addObject:@(idx)];
    }];
    // NSArray *shuffledIndexes = [self shuffledArray:indexes];
    // NSArray *shuffledCardButtons = [self permutedArray:self.cardButtons withPermutation:shuffledIndexes];
    NSArray *shuffledCardButtons = [self cardButtonsOrderedByClosestToDeckStack];;
    NSArray *reversedShuffledCardButtons = [self reversedArray:shuffledCardButtons];
    
    // Trying to fix the animation where cards are dealt under other set cards
//     [self putViewsToFront:shuffledCardButtons];
    [self putViewsToFront:reversedShuffledCardButtons];
    
    NSArray *positionBkp = [self saveViewsPositionInArray:shuffledCardButtons];
    
    
    NSArray *cardButtonsOrderedForShuffleAnimation = nil;
//    cardButtonsOrderedForShuffleAnimation = shuffledCardButtons;
    cardButtonsOrderedForShuffleAnimation = reversedShuffledCardButtons;
    // cardButtonsOrderedForShuffleAnimation = [self cardButtonsOrderedByClosestToDeckStack];
    
    double movingDuration = [self moveCardButtons:cardButtonsOrderedForShuffleAnimation toCornerAnimated:YES];
    //double movingDuration = [self moveCardButtons:shuffledCardButtons toCornerAnimated:YES];
    

    // restore card buttons with old positions
    NSTimeInterval minimumDuration = 0.60,
    durationVariation = 0.60,
    incrementalDelay = 0.15;
    double springDamping = 1.0;
    
    NSArray *cardsOrderedForDealingAnimation = nil;
    cardsOrderedForDealingAnimation = reversedShuffledCardButtons;
//    cardsOrderedForDealingAnimation = shuffledCardButtons;

    dispatch_queue_t delayQueue = dispatch_queue_create("AnimatedCardDistribution delay queue", NULL);
    dispatch_async(delayQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self animateDealingCardButtons:cardsOrderedForDealingAnimation
         withSavedPositionsAsArrayOfNumbers:positionBkp
                        withMinimumDuration:minimumDuration
                          durationVariation:durationVariation
                               minimumDelay:(movingDuration + 0.5) // wait for the first animation to finish
                           incrementalDelay:incrementalDelay
                     usingSpringWithDamping:springDamping];

        });
    });
    
    gameDidStart = YES;
}

/** Returns the position where the start of the deck on the screen.
 * @param offset:
 */
- (CGPoint)uiDeckPositionBasedOnShiftLength:(CGFloat)decalage {
    // Move cards to the left
//    CGFloat decalage = self.view.frame.size.height > 480 ? 9 : 8; // difference 3.5", 4"
//    CGPoint cornerPoint = {20.0, 25.0} ;
    
    // Move cards to the bottom
    CGSize cardSize = [[self.cardButtons firstObject] frame].size;
    CGPoint cornerPoint = {self.view.frame.size.width/2.0-cardSize.width, (self.view.frame.size.height - cardSize.height - decalage*self.cardButtons.count - 10)} ;
    return cornerPoint;
}

- (CGRect)uiDeckFrameBasedOnShiftLength:(CGFloat)decalage {
    CGPoint pos = [self uiDeckPositionBasedOnShiftLength:decalage];
    CGSize cardSize = [[self.cardButtons firstObject] frame].size;
    CGFloat height = cardSize.height + (self.cardButtons.count * decalage / 4);
    CGRect frame = CGRectMake(pos.x, pos.y, cardSize.width, height);
    frame = CGRectInset(frame, -CARD_GAME_VC_Default_BorderWidth, -CARD_GAME_VC_Default_BorderWidth);
    return frame;
}

- (NSTimeInterval)moveCardButtons:(NSArray *)cardViews toCornerAnimated:(BOOL)animated // with
{
//    CGFloat decalage = self.view.frame.size.height > 480 ? 9 : 8; // difference 3.5", 4"
    CGFloat decalage = 0.4;
    // Corner point where the bottom-most card should be placed.
    // (For instance, in UI perspective: the location where the deck of cards should be placed.)
    CGPoint deckStartCornerPoint = [self uiDeckPositionBasedOnShiftLength:decalage];
    // CGPoint currentCornerPoint = deckStartCornerPoint;  // copy by value
//    CGPoint cornerPointOfTopMostCard = CGPointMake(deckStartCornerPoint.x, (deckStartCornerPoint.y + (decalage * (cardViews.count - 1))));
    CGPoint cornerPointOfTopMostCard = deckStartCornerPoint;
    CGPoint currentCornerPoint = cornerPointOfTopMostCard; // copy by value
    
    NSTimeInterval minimumDuration = 0.30,
//    durationVariation = 0.60,
    delay = 0.0;
    NSTimeInterval incrementalDelay = 0.111; // fine tuned to match duration of sound "card-deck-shuffled-1.mp3"
    
    NSURL *deckShuffleSoundUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"card-deck-shuffled-1" ofType:@"mp3"]];
    [self playNewSound:deckShuffleSoundUrl withDelay:0.5]; // delay fine-tuned with the song file
    
    for (int i=0; i < cardViews.count; ++i) {
        UIView *button = [cardViews objectAtIndex:i];
        
        if (animated){
            [UIView animateWithDuration:minimumDuration
                                  delay:delay
                                options:UIViewAnimationOptionAllowAnimatedContent
                             animations:^{
                                 
                                CGRect frame = button.frame;
                                frame.origin = currentCornerPoint;
                                button.frame = frame;
                                 // Playing a sound for each card being moved
//                                 button.frame.origin = currentCornerPoint;
//                                 NSURL *cardShuffleSoundUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"card-shuffled-1" ofType:@"mp3"]];
//                                 [self playNewSound:cardShuffleSoundUrl];
                                 
                             }
                             completion:nil];
            
            // To make it real, cards are taken one after the other.
            // In other terms, there is a little delay after each card is moved
            delay += incrementalDelay;
            
        } else {
            CGRect frame = button.frame;
            frame.origin = currentCornerPoint;
            button.frame = frame;
            NSLog(@"Move to corners : animation disabled");
        }
        
        // Now 
        currentCornerPoint.y += decalage;  // when we start by moving the bottom-most card first
//        currentCornerPoint.y -= decalage;  // when we start by moving the top-most card first
    }
    
    return (animated ? delay+minimumDuration : 0.0 );
}


/**
 *  @param delay
 *                  Used to wait for the first animation to finish
 */
- (void)animateDealingCardButtons:(NSArray *)cardButtons withSavedPositionsAsArrayOfNumbers:(NSArray *)positions withMinimumDuration:(NSTimeInterval)duration durationVariation:(NSTimeInterval)durationVariation minimumDelay:(NSTimeInterval)delay incrementalDelay:(NSTimeInterval)incrementalDelay usingSpringWithDamping:(CGFloat)damping
{
    // Cannot interact with the app while the game is restarting (and the animation processing)
    // We don't want weird glitches. Also, it's natural for the player to stand still while a card dealer is shuffling...
    [self setUserInteractionButtonsEnabled:NO];
    
    NSArray *views = cardButtons,
            *arrayOfPositions = positions;
    
    // UI prettification: We draw the cards from the top of the deck to the bottom of the deck
    NSInteger currentIndex = 0;
    for (NSInteger i=views.count-1; i >= 0 ; --i) {
        CGPoint origine;
        
        @try {
            
            NSNumber *xpos = [arrayOfPositions objectAtIndex:currentIndex];
            origine.x = [xpos floatValue];
            ++currentIndex;
            
            NSNumber *ypos = [arrayOfPositions objectAtIndex:currentIndex];
            origine.y = [ypos floatValue];
            ++currentIndex;
            
            UIView *curView = [views objectAtIndex:i];
            CGRect newFrame = curView.frame;
            newFrame.origin = origine;
            
            durationVariation *= 10000.0;
            CGFloat deltaDuration = arc4random() % (int)durationVariation;
            deltaDuration /= 10000.0;
            durationVariation /=10000.0;
            // deltaDuration -= durationVariation/2.0;
            
            
            [UIView animateWithDuration:duration + deltaDuration
                                  delay:delay
                 usingSpringWithDamping:damping
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseIn //
//                                options:UIViewAnimationOptionCurveEaseOut // (UIViewAnimationOptions)
                             animations:^{
                                 // disallow touching cards (?)
                                 // no.
                                 // Otherwise, it would be done using a UIViewAnimationOption ...
                                 
                                 // restore positions
                                 [curView setFrame:newFrame];
                             }
                             completion:^(BOOL finished){
                                 if (finished){
                                     
                                 } else {
                                     
                                 }
                             }
             ];
            // Playing a sound for each card being moved
            NSURL *cardShuffleSoundUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"card-sound-1" ofType:@"mp3"]];
            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:cardShuffleSoundUrl error:nil];
            player.enableRate = YES; // sounds are often faster than the animation so we want to change the rate
            player.rate = 0.975; // tweaked manually according to match the sound file
            [self registerPlayerAndPlay:player withDelay:delay + 0.1];

            
            delay +=    incrementalDelay;
        }
        @catch (NSException *exception) {
            // Handle an exception thrown in the @try block
            NSLog(@"Exception %@ lancée", exception);
            //        NSLog(@"Quel est l'index...");
        }
        @finally {
            // Code that gets executed whether or not an exception is thrown
        }
    }
    // Re-enable user interaction when the animations are over
    [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(setUserInteractionButtonsEnabledOnTimerFire:) userInfo:@(YES) repeats:NO];
}


#pragma mark - Utilitaires pour animations

- (void)setUserInteractionButtonsEnabledOnTimerFire:(NSTimer *)timer {
    if (timer.userInfo){
        [self setUserInteractionButtonsEnabled:((NSNumber *)timer.userInfo).boolValue];
    }
}

- (void)setUserInteractionButtonsEnabled:(BOOL)enabled
{
    self.boutonNouvellePartie.enabled = enabled;
    
    self.bonusButtonShowAll.enabled = enabled;
    self.bonusesButton.enabled = enabled;
}


// sauvegarde les positions en NSNumber avec x,y à la suite pour une position donnée
- (NSArray *) saveViewsPositionInArray: (NSArray *)views
{
    NSMutableArray *positions = [[NSMutableArray alloc]init];
    
    for (UIView *view in views) {
        if ([view isKindOfClass:[UIView class]]){
            // CGPoint objects cannot be added to an array
            [positions addObject:[NSNumber numberWithFloat:view.frame.origin.x]];
            [positions addObject:[NSNumber numberWithFloat:view.frame.origin.y]];
        }
    }
    
    return positions;
}

- (double)distanceFromPoint:(CGPoint)start toPoint:(CGPoint)target {
    CGFloat xs = start.x, ys = start.y;
    CGFloat xf = target.x, yf = target.y;
    CGFloat dx = (xf - xs), dy = (yf - ys);
    CGFloat hyp = (dx*dx) + (dy*dy);
    return sqrt(hyp);
}

- (NSArray *)cardButtonsOrderedByClosestToDeckStack {
    NSMutableArray *views = [NSMutableArray array];
    CGFloat decalage = 0.4;
    CGPoint deckStartCornerPoint = [self uiDeckPositionBasedOnShiftLength:decalage];

    views = [NSMutableArray arrayWithArray:self.cardButtons];
    [views sortUsingComparator: ^NSComparisonResult(UIView *buttonA, UIView *buttonB){
        CGFloat d1 = [self distanceFromPoint:buttonA.frame.origin toPoint:deckStartCornerPoint];
        CGFloat d2 = [self distanceFromPoint:buttonB.frame.origin toPoint:deckStartCornerPoint];
        
        // NSComparisonResult result = esign((int) (10000 * (d1 - d2)));
        NSComparisonResult result = (int) (d1 < d2);
        if (d1 == d2) {
            result = 0;
        }

        return result;
    }];
    
    return views;
}


/** Places the given view frontmost (in their parent's view hierarchy).
 *  The first view passed in will be behind and the last view of the array will
 *  be on top of those.
 */
- (void)putViewsToFront:(NSArray *)views {
    // When passing through the array
    // The first view that was but in from will become the one at the bottom
    UIView *superview = [views[0] superview];
    NSLog(@"First view to front is %@", @([views[0] hash]));
    for (NSUInteger i = 0; i < views.count; ++i){
        UIView *aView = views[i];
        CGPoint position = aView.frame.origin;
        NSLog(@"top most %lu) is at index %@, position %@, hash %@", i, @([superview.subviews indexOfObject:aView]), NSStringFromCGPoint(position), @([aView hash]));
        [aView.superview bringSubviewToFront:aView];
        NSLog(@"   -> %lu)  now at index %@", i, @([superview.subviews indexOfObject:aView]));
    }
    UIView *first = [views firstObject];
    UIView *last = [views lastObject];
    NSLog(@"First  view sent to front now at index %@, position %@, hash %@ ", @([superview.subviews indexOfObject:first]), NSStringFromCGPoint(first.frame.origin), @([first hash]));
    NSLog(@"Latest view sent to front now at index %@, position %@, hash %@ ", @([superview.subviews indexOfObject:last]), NSStringFromCGPoint(last.frame.origin), @([last hash]));
    
}


/**
 * It is supposed to move views to in the view hierarchy so that ...
 */
- (void)reorderViewHierarchyOrderOfViews:(NSArray *)views toMatchNewIndexes:(NSArray *)indexes {
    NSMutableDictionary *viewsDictionary = [NSMutableDictionary dictionary];
    
    for (NSUInteger i = 0; i < views.count; ++i){
        UIView *aView = views[i];
        NSNumber *index = [indexes objectAtIndex:[indexes[i] integerValue]];
        viewsDictionary[@(aView.hash)] = @{
                                           @"vw": aView,
                                           @"supvw": aView.superview,
                                           @"hash": @(aView.hash),
                                           /// Putting every view EXACTLY the where it was and between the right siblings
                                           // if we ever add more views along with the cards,
                                           // we have to make sure we place *each* card button exactly where it was
                                           // in the view hierarchy to avoid side effects and weird animations.
                                           // Though it is important to note that...
                                           @"indexInSuperview": @([[aView.superview subviews] indexOfObject:aView]),
                                           @"targetindex": index
                                           };
        // Theme
//        [aView removeFromSuperview]; it would change the index of
    }
    
    for (UIView *aView in views){
        [aView removeFromSuperview];
    }
    
    // for (NSDictionary *viewInfos in viewsDictionary){
    for (NSString *key in viewsDictionary){
        NSDictionary *viewInfos = viewsDictionary[key];
        UIView *aView = viewInfos[@"vw"];
        UIView *superview = viewInfos[@"supvw"];
        NSNumber *index = viewInfos[@"indexInSuperview"];
        [superview insertSubview:aView atIndex:index.integerValue];
    }
}



/**
 * @param arrayOfPositions must be sorted in the same order as
 * @param views
 */
- (void)restorePositions:(NSArray *)arrayOfPositions ofViews:(NSArray *)views
{
    NSInteger currentIndex = 0;
    for (int i=0; i < views.count ; ++i) {
        CGPoint origine;
        
        @try {

            NSNumber *xpos = [arrayOfPositions objectAtIndex:currentIndex];
            origine.x = [xpos floatValue];
            ++currentIndex;
            
            NSNumber *ypos = [arrayOfPositions objectAtIndex:currentIndex];
            origine.y = [ypos floatValue];
            ++currentIndex;
            
            UIView *curView = [views objectAtIndex:i];
            CGRect newFrame = curView.frame;
            newFrame.origin = origine;
            
            [curView setFrame:newFrame];
            
        }
        @catch (NSException *exception) {
            // Handle an exception thrown in the @try block
            NSLog(@"Exception %@ lancée", exception);
            //        NSLog(@"Quel est l'index...");
        }
        @finally {
            // Code that gets executed whether or not an exception is thrown
        }
    }
}


/** Returns a shuffled version of an array
 */
- (NSArray *)shuffledArray:(NSArray *)array
{
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:array];
    NSMutableArray *shuffled = [[NSMutableArray alloc] initWithCapacity:mArray.count];
    
    while ( mArray.count > 0) // while there is still some objects in mArray
    {
        NSUInteger randomIndex = arc4random() % mArray.count;
        [shuffled addObject:[mArray objectAtIndex:randomIndex]];
        [mArray removeObjectAtIndex:randomIndex];
    }
    
    return shuffled;
}

- (NSArray *)reversedArray:(NSArray *)array {
    NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
    // NSLog(@"%lu vs %lu, equal: %@", array.hash, reversed.hash, @(array == reversed)); // equal: 0
    return reversed;
}

/** Permutes an array given a permutation of indexes
 */
- (NSArray *)permutedArray:(NSArray *)array withPermutation:(NSArray *)sigma {
    assert(array.count == sigma.count);
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSUInteger i=0; i < MIN(array.count, sigma.count); ++i) {
        id value = [array objectAtIndex:[sigma[i] integerValue]];
        [result addObject:value];
    }
    return result;
}


#pragma mark - Notifications and messages

- (void)showAlertWithTitle:(NSString *)title content:(NSString *)content andCancelTitle:(NSString *)cancelTitle
{
    [[[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil] show];
}

- (void)showAlertWithTitle:(NSString *)title content:(NSString *)content
{
    [self showAlertWithTitle:title content:content andCancelTitle:@"✅"];
}




#pragma mark - Bonuses

- (IBAction)showAvailableBonuses {
    [self showAlertWithTitle:@"Not that bunch of bonuses yet :(" content:@"Sorry, there is only one bonus available right now"];
}



- (IBAction)bonusRevealCards:(UIButton *)sender
{
    if ([self.game canUseShowAllCardsBonus]){
    sender.enabled = FALSE;
    
    // do it in the model instead of the controller
    [self.game bonusShowAllCardsAndNotify:self actionAtBegining:@selector(updateUI) actionAtEnd:@selector(updateUI)];
    
        sender.enabled = TRUE;
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Cannot use bonus :(" message:@"You do not have enough points for that" delegate:nil cancelButtonTitle:@"I'll grab those points !" otherButtonTitles:nil] show];
    }
}






#pragma mark - Actions / Events


- (IBAction)navigateThroughMatchInfoHistory:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        currentMatchInfosIndex = currentMatchInfosIndex==0 ? 0: currentMatchInfosIndex-1;
    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight){
        currentMatchInfosIndex = currentMatchInfosIndex >= self.game.amountOfOperations-1 ? self.game.amountOfOperations - 1 : currentMatchInfosIndex+1;
    }
    [self retrieveMatchInfos];
}





- (IBAction)startANewGame {
    self.game = nil;
    self.nbRetournements = 0;
    self.numberOfMatchMode.enabled = YES;
    [self updateUI];
    
    self.matchInfoHistorySlider.enabled = NO;
    self.matchInfoHistorySlider.value = self.matchInfoHistorySlider.maximumValue;
    
    [self animatedRedraw];
}

- (IBAction)cardButtonPressed:(UIButton *)sender {
    if ( [self.numberOfMatchMode isEnabled] ) {
        self.game.numberOfMatch = [self nbrOfMatchMode];
        self.numberOfMatchMode.enabled = NO;
    }
    
    if (! [self.matchInfoHistorySlider isEnabled]){
        self.matchInfoHistorySlider.enabled = YES;
    }
    
    // Déterminer quel bouton a été pressé
    NSInteger indexOfCardButton = [self.cardButtons indexOfObject:sender];
    if ([self.cardButtons indexOfObject:sender] == NSNotFound){
        NSLog(@"Index non lié");
    }
    // si je n'ai pas fait le linkage d'un bouton et que je clicque dessus.
    
    [self.game chooseCardAtIndex:indexOfCardButton]; // on dit au modèle de choisir la carte.
    
    [self compterRetournement:sender];
    [self updateUI];
    [self updateMatchLog];
}

- (IBAction)retrieveMatchInfos
{
    [self.matchInfoLabel setText:[self.game operationAtIndex:currentMatchInfosIndex]];
    
    [self matchingHistoryLabelLayoutForLog];
}

- (IBAction)retrieveMatchInfoBasedOnSliderValue:(UISlider *)sender {
    // NSLog(@"\nSlider value : %f \n  minSlider %f \n  maxSlider %f \n  History size %lu", sender.value, sender.minimumValue, sender.maximumValue, (unsigned long)[self.game amountOfOperations]);
    
    currentMatchInfosIndex = sender.value;
    [self retrieveMatchInfos];
}



#pragma mark - Updating UI


- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons){ // random searching
        NSUInteger indexOfCardButton = [self.cardButtons indexOfObject:cardButton];
        
        Card *card = [self.game cardAtIndex:indexOfCardButton];
        
        // what do I have to do with the button : set its title and bg image.
        [cardButton setTitle:[self titleForCard:card]
                    forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                              forState:UIControlStateNormal];
        
        cardButton.enabled = ! card.isMatched;
    }
    
    [self updateLabels];
}

- (void)updateLabels
{
    BOOL negScore = self.game.score < 0;
    
    // updating the score label
    [self.scoreLabel setText:[@"Score " stringByAppendingString:[NSString stringWithFormat:@"%@%li", (negScore ? @"< ":@"") , (long) /* self.game.score */ (!negScore ? self.game.score : 0) ]] ];
    
    // updating the number of flips label
    [self.retournements setText:[NSString stringWithFormat:@"Turned %d times", self.nbRetournements]];
    
    [self.matchInfoLabel setText:[self.game lastOperation]];
}


- (void)matchingHistoryLabelLayoutForLog
{
    if (currentMatchInfosIndex == [self.game amountOfOperations] -1){
            // remettre le champ de texte comme normal
        [self.matchInfoLabel setAlpha:1.0];
        // [self.matchInfoLabel setOpaque:YES];
    } else {
        // passer le champ de texte en grisé
        [self.matchInfoLabel setAlpha:0.7];

        // [self.matchInfoLabel setBackgroundColor:nil];
        // [self.matchInfoLabel setOpaque:NO];
    }
}

- (void)updateMatchLog
{
    [self updateHistorySlider]; currentMatchInfosIndex = [self.game amountOfOperations] -1;
    
    [self.matchInfoHistorySlider setValue:(float)[self.game amountOfOperations] animated:YES];
    
    [self retrieveMatchInfos];
    [self matchingHistoryLabelLayoutForLog];
}

- (void)updateHistorySlider
{
    UISlider *hslider = self.matchInfoHistorySlider;
    hslider.minimumValue = 0;
    hslider.maximumValue = (float)[self.game amountOfOperations];
    
}




- (void)compterRetournement:(UIButton *)pushedButton
{
    if ([[pushedButton titleForState:UIControlStateNormal] isEqualToString:@""]){
        self.nbRetournements++;
    }
}




- (NSString *)titleForCard:(Card *)card
{
    return card.isChosen ? card.contents : @"";
}
- (UIImage *)backgroundImageForCard:(Card *)card
{
    NSString *imageName = card.isChosen ? @"cardFront" : @"cardBack" ;
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        image = [UIImage imageNamed:[imageName stringByAppendingString:@".jpg"]];
    }
    return image;
}


#pragma mark - UI elements

- (void)prettifyCardView:(UIView *)view {
    view.layer.cornerRadius = 5.0;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.7] CGColor];
    view.clipsToBounds = YES;
}

- (NSUInteger)nbrOfMatchMode
{
    switch ([self.numberOfMatchMode selectedSegmentIndex]) {
        default:
        case 0:
            return 2;
            
        case 1:
            return 3;
    }
}

- (void)initializeUIElements
{
    [self initializeButtons];
    [self initializeLogBox];
    [self initializeHistorySlider];
    
    // Initialize a spot for the deck
    CGFloat decalage = 0.4;
    CGRect deckSpot = [self uiDeckFrameBasedOnShiftLength:decalage];
//    deckSpot = CGRectInset(deckSpot, 10, 10);
    UIView *view = [[UIView alloc] initWithFrame:deckSpot];
    view.frame = deckSpot;
    view.backgroundColor = [UIColor clearColor];
    view.layer.cornerRadius = CARD_GAME_VC_Default_CornerRadius / 2;
    view.layer.borderWidth = CARD_GAME_VC_Default_BorderWidth;
    view.layer.borderColor = [CARD_GAME_VC_Default_UIColor CGColor];
//    view.layer.borderWidth = 2.f;
//    view.layer.borderColor = [[UIColor greenColor] CGColor];
    UIColor *bgColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    view.backgroundColor = bgColor;
    [self.view insertSubview:view atIndex:0];
}


- (void)initializeButtons
{
    NSMutableArray *btns = [NSMutableArray array];
    if (self.bonusesButton) {
//        [btns addObject:self.bonusesButton];
    }
    if (self.bonusButtonShowAll) {
//        [btns addObject:self.bonusButtonShowAll];
    }
    for (UIView *view in btns)
    {
        roundViewCornersWithCornerRadius(view, CARD_GAME_VC_Default_CornerRadius);
        
        strokeViewWithColorAndBorderWidth(view, CARD_GAME_VC_Default_UIColor, CARD_GAME_VC_Default_BorderWidth);
        changeStrokeAlpha(view, CARD_GAME_VC_Default_Alpha);
    }
}




- (void)initializeLogBox
{

    /*
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.scoreLabel.bounds cornerRadius:cornerRadius];
    [roundedRect addClip];
     */
    
//    UIColor *edgeColor = [UIColor blueColor];
    UIColor *edgeColor = CARD_GAME_VC_Default_UIColor;
    [self.matchInfoLabel.layer setBorderColor:[[edgeColor colorWithAlphaComponent:CARD_GAME_VC_Default_Alpha] CGColor]];
    [self.matchInfoLabel.layer setBorderWidth:CARD_GAME_VC_Default_BorderWidth];
    
    CGFloat cornerRadius = CARD_GAME_VC_Default_CornerRadius;
    self.matchInfoLabel.clipsToBounds = YES;
    self.matchInfoLabel.layer.cornerRadius = cornerRadius;
}



- (void)initializeHistorySlider
{
    UISlider *hslider = self.matchInfoHistorySlider;
    // self.matchInfoHistorySlider.continuous = FALSE;
    
    hslider.tintColor = CARD_GAME_VC_Default_UIColor;
    hslider.minimumValue = 0;
    hslider.maximumValue = [self.game amountOfOperations];
}




#pragma mark - Initialisations

- (CardMatchingGame *)game
{
    if (! _game){
        gameDidStart = NO;
        Deck *deck = self.deck;
        _game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count usingDeck:deck
                 ];
        _game.numberOfMatch = [self nbrOfMatchMode];
    }
    return _game;
}


- (Deck *)deck
{
    if (!_deck || [_deck amountOfCards]==0)
    {
        _deck = [self createDeck];
    }
    return _deck;
}

- (Deck *)createDeck // abstract
{
    // return [[PlayingCardDeck alloc] init]; // dommage d'avoir forcément un appel à une classe spécifique. => Solution : polymorphisme de controleur (subclass it and make this one abstract).
    
    return nil;
}



- (void) customConfig
{
    self.matchInfoHistorySlider.hidden = YES;
    currentMatchInfosIndex = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    self.busyAudioPlayers = [[NSMutableArray alloc] init];
    
    [self initializeUIElements];
    // change the tint color ? (not here, but how to do that ? )
    
    [self customConfig];
    
    for (UIView *cardView in self.cardButtons) {
        [self prettifyCardView:cardView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.game loadGameInfos];
    [self updateUI]; // updates everything in the UI
    
    for (UIView *cardView in self.cardButtons) {
        [self prettifyCardView:cardView];
    }
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // si le jeu n'a pas été initialisé
    if (! gameDidStart)
    {
        // Je veux que les cartes se mettent en place de manière animée;
        [self animatedRedraw];
    }
}




- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [self.game saveGameInfos];
}


@end
