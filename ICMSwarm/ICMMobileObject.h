//
//  ICMMobileObject.h
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-21.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICMBoidSimulation;

@interface ICMMobileObject : NSObject

@property (readwrite, nonatomic, weak) ICMBoidSimulation * simulation;

@property (readwrite, nonatomic, strong) NSArray * neighbours;

@property (readwrite, nonatomic, assign) GLKVector3 position;
@property (readwrite, nonatomic, assign) GLKVector3 velocity;

/**
 For storing an arbitrary object, of the developer's choice.
 */
@property (readwrite, nonatomic, strong) id userObject;

@end
