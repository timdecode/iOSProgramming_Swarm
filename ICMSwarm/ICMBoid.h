//
//  ICMBoid.h
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-20.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICMMobileObject.h"

@interface ICMBoid : ICMMobileObject

@property (readwrite, nonatomic, strong) NSMutableArray * neighbours;
@property (readwrite, nonatomic, strong) NSMutableArray * enemies;

- (void) stepSimulation:(double)deltaT;

@end

@interface Neighbour : NSObject
@property (readwrite, nonatomic, unsafe_unretained) ICMBoid * boid;
@property (readwrite, nonatomic, strong) Neighbour * next;
@end
