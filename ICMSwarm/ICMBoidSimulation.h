//
//  ICMBoidSimulation.h
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-20.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import <Foundation/Foundation.h>

// forward declaration of ICMBoid:
//  - makes compilation faster
//  - in large projects, keeps the namespace clean
//  - include the header in the .m
@class ICMBoid;

@interface ICMBoidSimulation : NSObject

@property (readonly, nonatomic, strong) NSArray * boids;

/** The bounds of the simulation are from <0,0,0> to the given size. */
@property (readwrite, nonatomic, assign) GLKVector3 size;

@property (readwrite, nonatomic, assign) float desiredSeparation;
@property (readwrite, nonatomic, assign) float maxAcceleration;
@property (readwrite, nonatomic, assign) float maxSpeed;
@property (readwrite, nonatomic, assign) float perceptionDistance;

@property (readwrite, nonatomic, assign) float cohesion;
@property (readwrite, nonatomic, assign) float separation;
@property (readwrite, nonatomic, assign) float alignment;
@property (readwrite, nonatomic, assign) float fear;

/**
 Creates a new boid while adding it to the simulation. This returns a reference to the newly created
 boid.
 */
- (ICMBoid*) createBoid;

/**
 Creates a boid without a step-simulation function. This is useful for control from a gesture reconginzer.
 */
- (ICMBoid*) createTouchBoid;

- (ICMBoid*) createTouchEnemy;

/**
 Removes the given boid from the simulation.
 */
- (void) removeBoid:(ICMBoid*)boid;

/** 
 This is called each time we want to update the simulation. In here, all of the boids will have their
 position, orientation and velocity calculated for the next frame.
 
 Since we can't model this simulation easily using a continuous method, we use a discrete method based
 upon small time steps. If the time step is small enough, and we iterate through these discrete
 steps fast enough, the simulation will look fluid and continuous.
 */
- (void) stepSimulation:(double)deltaT;

- (void) visitNeigbhoursForBoid:(ICMBoid*)boid withBlock:(void(^)(ICMBoid * neighbour))block;

@end
