//
//  PlayingCardView.m
//  SuperCard
//
//  Created by jeffrey.mvutu@gmail.com on 29.11.14.
//  Copyright (c) 2014 JFrey Mab'. All rights reserved.
//

#import "PlayingCardView.h"

@interface PlayingCardView ()



@property (nonatomic) CGFloat faceCardScaleFactor;



@end




@implementation PlayingCardView

#define KEY_for_FACE_CARD_SCALE_FACTOR @"faceCardScaleFactor"
#define KEY_for_FRAME_POSITION_X @"playingCardPositionX"
#define KEY_for_FRAME_POSITION_Y @"playingCardPositionY"


#pragma mark - Saving and Restoring Informations


- (void)saveOnScreenPosition
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setFloat:self.faceCardScaleFactor forKey:KEY_for_FACE_CARD_SCALE_FACTOR];
    [ud setFloat:self.frame.origin.x forKey:KEY_for_FRAME_POSITION_X];
    [ud setFloat:self.frame.origin.y forKey:KEY_for_FRAME_POSITION_Y];
    [ud synchronize];
}

- (void)reloadPositionOnScreen
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    self.faceCardScaleFactor = [[[NSUserDefaults standardUserDefaults] valueForKey:KEY_for_FACE_CARD_SCALE_FACTOR]  floatValue];
    
    CGPoint center;
    center.x = [[ud valueForKey:KEY_for_FRAME_POSITION_X] floatValue];
    center.y = [[ud valueForKey:KEY_for_FRAME_POSITION_Y] floatValue];
}



#pragma mark - Properties
@synthesize faceCardScaleFactor = _faceCardScaleFactor;
#define DEFAULT_FACE_CARD_SCALE_FACTOR 0.90   // percents


- (CGFloat)faceCardScaleFactor {
    // I want it to be at least a ... It's also a way to protect ourselves
    if (!_faceCardScaleFactor) { _faceCardScaleFactor = DEFAULT_FACE_CARD_SCALE_FACTOR;  }
    return _faceCardScaleFactor;
}
-(void)setFaceCardScaleFactor:(CGFloat)faceCardScaleFactor {
    _faceCardScaleFactor = faceCardScaleFactor;
    [self setNeedsDisplay];
}





#pragma mark - Gestures

- (void)scalePicture:(UIPinchGestureRecognizer *)gesture
{
    
    if ( gesture.state == UIGestureRecognizerStateChanged ||
        gesture.state == UIGestureRecognizerStateEnded) {
        
        self.faceCardScaleFactor *= gesture.scale;
        
        // do not accumulate the pinch
        gesture.scale = 1.0;
    }
}






#pragma mark - Drawing

#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 12.0



- (CGFloat)cornerScaleFactor {
    return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT ; }

- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor] ;}
- (CGFloat)cornerOffset {  return [self cornerRadius] / 3.0 ; }




- (void)pushContextAndRotateUpsideDown
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);
    CGContextRotateCTM(context, M_PI);
}

- (void)popContext
{
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation. #PerformanceHit
- (void)drawRect:(CGRect)rect
{
            // Drawing code
    
    // creating a context
        // #Context : _____
    
    // Doing everything with UIBeziePath
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]  ];
    // self.bounds is my coordinate system : it's width and heght is the amount of space I have on screen to draw in.
    
    // #continue here at 51:00 minutes  #Jeff
    
    [roundedRect addClip];
    [[UIColor whiteColor] setFill];
    
    UIRectFill(self.bounds); // the clip I have added prevents from filling outside of that ...
    
    [[UIColor redColor] setStroke];
    [roundedRect stroke];
    
    
    if (self.faceUp) {
            // s'il y a une image, on veut l'utiliser
        UIImage *faceImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", [self rankAsString], [self unicodeSuitName] ]]; // look this image up
        
        // if it founds a/the pict, it will try to draw the pips
        if (faceImage){
            // want to draw it
            
            CGRect imageRect = CGRectInset(self.bounds,
                                      self.bounds.size.width * (1.0 - self.faceCardScaleFactor),
                                      self.bounds.size.height * (1.0 -self.faceCardScaleFactor));
            
                // On dessine l'image
            [faceImage drawInRect:imageRect];
            
        } else {
            // on dessine les "pips" (nb de ... en f du rang)
            [self drawPips];
        }
        
        [self drawCorners];
        
    } else {
        UIImage *image = [UIImage imageNamed:@"cardback"];
        [image drawInRect:self.bounds];
    }
    
}




#pragma mark - Pips

#define PIP_HOFFSET_PERCENTAGE 0.165
#define PIP_VOFFSET1_PERCENTAGE 0.090
#define PIP_VOFFSET2_PERCENTAGE 0.175
#define PIP_VOFFSET3_PERCENTAGE 0.270

- (void)drawPips
{
    if ((self.rank == 1) || (self.rank == 5) || (self.rank == 9) || (self.rank == 3)) {
        [self drawPipsWithHorizontalOffset:0
                            verticalOffset:0
                        mirroredVertically:NO];
    }
    if ((self.rank == 6) || (self.rank == 7) || (self.rank == 8)) {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:0
                        mirroredVertically:NO];
    }
    if ((self.rank == 2) || (self.rank == 3) || (self.rank == 7) || (self.rank == 8) || (self.rank == 10)) {
        [self drawPipsWithHorizontalOffset:0
                            verticalOffset:PIP_VOFFSET2_PERCENTAGE
                        mirroredVertically:(self.rank != 7)];
    }
    if ((self.rank == 4) || (self.rank == 5) || (self.rank == 6) || (self.rank == 7) || (self.rank == 8) || (self.rank == 9) || (self.rank == 10)) {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:PIP_VOFFSET3_PERCENTAGE
                        mirroredVertically:YES];
    }
    if ((self.rank == 9) || (self.rank == 10)) {
        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                            verticalOffset:PIP_VOFFSET1_PERCENTAGE
                        mirroredVertically:YES];
    }
}



- (void)drawPipsWithHorizontalOffset:(CGFloat)hoffset
                      verticalOffset:(CGFloat)voffset
                  mirroredVertically:(BOOL)mirroredVertically
{
    [self drawPipsWithHorizontalOffset:hoffset
                        verticalOffset:voffset
                            upsideDown:NO];
    
    if (mirroredVertically) {
        [self drawPipsWithHorizontalOffset:hoffset
                            verticalOffset:voffset
                                upsideDown:YES];
    }
}



#define PIP_FONT_SCALE_FACTOR 0.012

- (void)drawPipsWithHorizontalOffset:(CGFloat)hoffset
                      verticalOffset:(CGFloat)voffset
                          upsideDown:(BOOL)upsideDown
{
    if (upsideDown){
        [self pushContextAndRotateUpsideDown];
    }
    
    CGPoint middle = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    UIFont *pipFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    pipFont = [pipFont fontWithSize:[pipFont pointSize] * self.bounds.size.width * PIP_FONT_SCALE_FACTOR];
    
    NSAttributedString *attributedSuit = [[NSAttributedString alloc] initWithString:self.suit attributes:@{ NSFontAttributeName : pipFont }];
    CGSize pipSize = [attributedSuit size];
    
    CGPoint pipOrigin = CGPointMake(
                                    middle.x - (pipSize.width/2.0)  - (hoffset * self.bounds.size.width),
                                    middle.y - (pipSize.height/2.0) - (voffset * self.bounds.size.height)
                                    );
    
    [attributedSuit drawAtPoint:pipOrigin];
    
    if (hoffset) {
        pipOrigin.x += hoffset*2.0*self.bounds.size.width;
        [attributedSuit drawAtPoint:pipOrigin];
    }
    if (upsideDown){ [self popContext]; }
}





#pragma mark - Draw Corners

- (void)drawCorners
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *cornerFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    // change size
    cornerFont = [cornerFont fontWithSize:
                  cornerFont.pointSize //
                  * [self cornerScaleFactor]];
    
    
    NSAttributedString *cornerText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", [self rankAsString], self.suit] attributes:@{ NSFontAttributeName : cornerFont , NSParagraphStyleAttributeName: paragraphStyle}];
    
    CGRect textBounds;
    textBounds.origin = CGPointMake([self cornerOffset], [self cornerOffset]);
    textBounds.size = [cornerText size];
    
    [cornerText drawInRect:textBounds];
    
    [self pushContextAndRotateUpsideDown];
    [cornerText drawInRect:textBounds];
    [self popContext];
}




- (NSString *)unicodeSuitName {
    NSString *suitChar;
    
    if ([self.suit isEqualToString:@"♥️"]){
//        suitChar = @"♥︎";
        suitChar = @"♥";
   } else if ([self.suit isEqualToString:@"♠️"]) {
//        suitChar = @"♠︎";
        suitChar = @"♠";
    } else if ([self.suit isEqualToString:@"♣️"]) {
        suitChar = @"♣";
    } else if ([self.suit isEqualToString:@"♦️"]) {
//        suitChar = @"♦︎";
        suitChar = @"♦";
    } else {
        NSLog(@"Erreur");
        suitChar = self.suit ; // invalid suit => invalid card => invalid (playing card) view.
        // ♤♧♡♢
    }
    
    return suitChar;
//    return [NSString stringWithFormat:@"%@%@", [self rankAsString], suitChar];
}




#pragma mark - Initialization

- (void)setup
{
    // don't draw a background for me
    // matter of style : I mean I don't have a background color
    // self.backgroundColor = [UIColor clearColor];
    self.backgroundColor = nil;
    
    self.opaque = NO;
    
    // when the bounds change, I want the behavior to be : redraw
    self.contentMode = UIViewContentModeRedraw ;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}




#pragma mark - Properties (Setting the card)
// need to redraw the card after that

- (NSString *)rankAsString
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K",@"Joker"][self.rank];
}


// Après avoir changé le contenu de la carte, il faut que celle-ci soit mise à jour.
- (void)setRank:(NSUInteger)rank {
    
    // save ourselves a setNeedsDisplay #PerformanceOptimization when it comes to UI things
    
    if (_rank != rank){
        _rank = rank;
    
        [self setNeedsDisplay];
    }
}

-(void)setSuit:(NSString *)suit {
    if (! [_suit isEqualToString:suit]){
        //    _suit = suit;  // copie de la référence ?
        _suit = [suit copy];
        [self setNeedsDisplay];
    }
}

-(void)setFaceUp:(BOOL)faceUp {
    if ( _faceUp != faceUp ){
        _faceUp = faceUp;
        [self setNeedsDisplay];
    }
}




@end
