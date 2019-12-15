//
//  BirthdayCardGameViewController.m
//  MatchismoJMM
//
//  Created by user on 06.10.17.
//  Copyright © 2017 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//

#import "BirthdayCardGameViewController.h"
#import "BirthdayCardDeck.h"

@interface BirthdayCardGameViewController ()

@end

@implementation BirthdayCardGameViewController

- (void)viewDidLoad {
    NSString *message = @"Joyeux anniversaire Glody! Sois béni!";
    [self setTextMessage:message];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Deck *)createDeck {
    BirthdayCardDeck *deck = [[BirthdayCardDeck alloc] init];
    [deck setWish:self.textMessage characterCountPerCard: 2 ];
    return deck;
}

- (void)setTextMessage:(NSString *)textMessage {
    assert(textMessage);
    _textMessage = textMessage;
    [self createDeck];
}

@end
