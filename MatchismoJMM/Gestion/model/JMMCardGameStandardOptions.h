//
//  JMMCardGameStandardOptions.h
//  MatchismoJMM
//
//  Created by jeffrey.mvutu@gmail.com on 05.12.14.
//  Copyright (c) 2014 jeffrey.mvutumabilama@epfl.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Cette classe a pour but de .... ?
 */
@interface JMMCardGameStandardOptions : NSObject

#pragma mark - Getting an instance

//+(JMMCardGameStandardOptions *)sharedOptionSaver;
+(instancetype)sharedOptionSaver;

// +(NSArray *)allowedKeys; // keys that can be stored


#pragma mark - saving methods

// Pour l'instant, cela les sauvegarde dans le standardUserDefaults
//  But : sauvegarder cela dans une autre base de données plus tard.
//- (void)standardSaveOfValue:(NSObject *)object forKey:(NSString *)key;
//- (NSObject *)standardLoadOfValueForKey:(NSString *)key;

//- (void)userDefaultsSaveValue:(id)value ForKey:(id)key;





#pragma mark - Some constants for the informations I want to test




@end
