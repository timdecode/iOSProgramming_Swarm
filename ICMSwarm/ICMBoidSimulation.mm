//
//  ICMBoidSimulation.m
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-20.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import "ICMBoidSimulation.h"

#import "ICMBoid.h"
#import "ICMFingerBoid.h"
#import "randomNumbers.h"

#include <vector>

using namespace std;





static size_t const gridWidth = 20;
static size_t const gridHeight = 20;

#define CellAt(grid, x, y) grid[y + gridWidth * x]

@implementation ICMBoidSimulation
{
@public
    NSMutableArray * _boids;
    NSMutableArray * _touchBoids;
    NSMutableArray * _enemies;
    
    Neighbour __strong * grid[gridWidth * gridHeight];
}

- (id) init
{
    self = [super init];
    
    if( self )
    {
        _boids = [NSMutableArray array];
        _touchBoids = [NSMutableArray array];
        _enemies = [NSMutableArray array];
        
        _desiredSeparation = 30.0;
        _maxAcceleration = 10.0;
        _maxSpeed = 0.03;
        _perceptionDistance = 130.0;
        
        _alignment = 2.0;
        _separation = 200.0;
        _cohesion = 5.0;
        _fear = 500.0;
    }
    
    return self;
}

struct GridPoint
{
    unsigned int x;
    unsigned int y;
};

- (GridPoint) _gridPointFor:(GLKVector3)point
{
    GridPoint ret;
    
    ret.x = (unsigned int)floorf((point.x / _size.x) * gridWidth);
    ret.y = (unsigned int)floorf((point.y / _size.y) * gridHeight);
    
    ret.x = MIN(gridWidth - 1, ret.x);
    ret.y = MIN(gridHeight - 1, ret.y);
    
    return ret;
}

- (void) _updateNeighbours
{
    // clear the grid
    for( unsigned int x = 0; x < gridWidth; x++ )
    {
        for( unsigned int y = 0; y < gridHeight; y++ )
        {
            CellAt(grid, x, y) = nil;
        }
    }
    
    // update each grid cell with a linked-list of boids at that position
    for( ICMBoid * boid in _boids )
    {
        GridPoint point = [self _gridPointFor:boid.position];
        
        Neighbour * cell = CellAt(grid, point.x, point.y);
        
        if( cell == nil )
        {
            cell = [[Neighbour alloc] init];
            CellAt(grid, point.x, point.y) = cell;
        }
        else
        {
            // find the last cell in our list
            while( cell.next )
                cell = cell.next;
            
            cell.next = [[Neighbour alloc] init];
            cell = cell.next;
        }
        
        cell.boid = boid;
    }
    

}

- (void) visitNeigbhoursForBoid:(ICMBoid*)boid withBlock:(void(^)(ICMBoid * neighbour))block
{
    GridPoint halfPerceptionDistance = [self _gridPointFor:GLKVector3Make(self.perceptionDistance / 2.0f,
                                                                          self.perceptionDistance / 2.0f,
                                                                          self.perceptionDistance / 2.0f)];
    
    // visit each boid and find all the neighbours in a rectangle around the boid
       
        GLKVector3 position = boid.position;
        GridPoint point = [self _gridPointFor:position];
        
        for( int x = MAX(0, point.x - halfPerceptionDistance.x); x < MIN(gridWidth, point.x + halfPerceptionDistance.x); x++ )
        {
            for( int y = MAX(0, point.y - halfPerceptionDistance.y); y < MIN(gridHeight, point.y + halfPerceptionDistance.y); y++ )
            {
                Neighbour * cell = CellAt(grid, x, y);
                
                while( cell.next )
                {
                    GLKVector3 neighbourPoint = cell.boid.position;
                    float distance = GLKVector3Distance(neighbourPoint, position);
                    
                    if( distance > 0 && distance < _perceptionDistance )
                        block(cell.boid);
                    
                    cell = cell.next;
                }
            }
        }
}

- (ICMBoid*) createBoid
{
    ICMBoid * boid = [[ICMBoid alloc] init];
    
    // remember all the boids we have created
    [_boids addObject:boid];
    
    // the boid needs to know about the simulation as well
    boid.simulation = self;
    
    // position the boid randomly in our bounds
    boid.position = GLKVector3Make(float_random(0.0f, self.size.x),
                                   float_random(0.0f, self.size.y),
                                   float_random(0.0f, self.size.z));
    
    // give it a random velocity
    boid.velocity = GLKVector3Make(float_random(-10.0, 10.0),
                                   float_random(-10.0, 10.0),
                                   0.0);
    
    return boid;
}

- (ICMBoid*) createTouchBoid
{
    ICMBoid * touchBoid = [[ICMFingerBoid alloc] init];
    
    [_touchBoids addObject:touchBoid];
    [_boids addObject:touchBoid];
    
    return touchBoid;
}

- (ICMBoid*) createTouchEnemy
{
    ICMBoid * touchBoid = [[ICMFingerBoid alloc] init];
    
    [_enemies addObject:touchBoid];
    
    return touchBoid;
}

- (void) removeBoid:(ICMBoid *)boid
{
    [_boids removeObject:boid];
    [_enemies removeObject:boid];
    [_touchBoids removeObject:boid];
}

- (void) stepSimulation:(double)deltaT
{
    [self _updateNeighbours];
    
    for( ICMBoid * boid in _boids )
    {
        //        boid.neighbours = _boids;
        boid.enemies = _enemies;
        
        [boid stepSimulation:deltaT];
    }
}

@end

