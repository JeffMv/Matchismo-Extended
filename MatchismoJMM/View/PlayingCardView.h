//
//  PlayingCardView.h
//  SuperCard
//
//  Created by jeffrey.mvutu@gmail.com on 29.11.14.
//  Copyright (c) 2014 JFrey Mab'. All rights reserved.
//

#import <UIKit/UIKit.h>



// Views must be as generic as possible
// So try not to tie it to a specific application or model


// Need to think about #PerformanceOptimization when it comes to UI things


@interface PlayingCardView : UIView

@property (nonatomic) NSUInteger rank;
@property (strong, nonatomic) NSString *suit;
@property (nonatomic) BOOL faceUp;

- (void)scalePicture:(UIPinchGestureRecognizer *)gesture;

- (void)saveOnScreenPosition;
- (void)reloadPositionOnScreen;


@end
