//
//  ICMBoid.m
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-20.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import "ICMBoid.h"
#import "ICMBoidSimulation.h"

@implementation Neighbour
@end

@implementation ICMBoid

@synthesize neighbours = _neighbours;

- (id) init
{
    self = [super init];
    
    if( self )
    {
        self.neighbours = [NSMutableArray array];
        self.enemies = [NSMutableArray array];
    }
    
    return self;
}

GLKVector3 GLKVector3Limit(const GLKVector3 vector, float limit)
{
    float length = GLKVector3Length(vector);
    
    if( length > limit )
        return GLKVector3MultiplyScalar(vector, limit / length);
    else
        return vector;
}

- (GLKVector3) alignmentAcceleration
{
    __block GLKVector3 averageVelocity = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    __block int count = 0;
    [self.simulation visitNeigbhoursForBoid:self withBlock:^(ICMBoid *neighbour) {
        averageVelocity = GLKVector3Add(neighbour.velocity, averageVelocity);
        count++;
    }];
    
    // if we didn't do anything, or our separation is 0, then
    // just return a 0 vector
    if( count == 0 || GLKVector3AllEqualToScalar(averageVelocity, 0.0f) )
        return averageVelocity;
    else
    {
        averageVelocity = GLKVector3DivideScalar(averageVelocity, (float)count);
        
        GLKVector3 alignment = GLKVector3Normalize(averageVelocity);
        return alignment;
    }
}

/**
 centre = (p_0, p_1, ..., p_n) / n;
 
 */
- (GLKVector3) cohesionAcceleration:(double)deltaT
{
    __block GLKVector3 centre = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    __block int count = 0;
    [self.simulation visitNeigbhoursForBoid:self withBlock:^(ICMBoid *neighbour) {
        centre = GLKVector3Add(neighbour.position, centre);
        count++;
    }];
    
    if( count == 0 || GLKVector3AllEqualToScalar(centre, 0.0f) )
        return centre;
    else
    {
        centre = GLKVector3DivideScalar(centre, (float)count);
        
        GLKVector3 cohesion = GLKVector3Subtract(centre, self.position);
        cohesion = GLKVector3Normalize(cohesion);
        cohesion = GLKVector3MultiplyScalar(cohesion, self.simulation.maxAcceleration);
        
        return cohesion;
    }
}

- (GLKVector3) separationAcceleration:(double)deltaT
{
    __block GLKVector3 separation = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    __block int count = 0;
    float desiredSeparation = self.simulation.desiredSeparation;
    [self.simulation visitNeigbhoursForBoid:self withBlock:^(ICMBoid *neighbour) {
        GLKVector3 direction = GLKVector3Subtract(self.position, neighbour.position);
        float distance = GLKVector3Length(direction);
        
        if( distance > 0.0f && distance < desiredSeparation )
        {
            direction = GLKVector3Normalize(direction);
            GLKVector3 localSeparation = GLKVector3MultiplyScalar(direction, desiredSeparation / (distance));
            
            localSeparation = GLKVector3Limit(localSeparation, 3.0);
            
            separation = GLKVector3Add(separation, localSeparation);
            count++;
        }
    }];
    
    if( count == 0.0f || GLKVector3AllEqualToScalar(separation, 0.0f) )
        return separation;
    else
    {
        // normalize the vector
        separation = GLKVector3DivideScalar(separation, (float)count);
        
        separation = GLKVector3Normalize(separation);
        return separation;
    }
}

- (GLKVector3) fearAcceleration
{
    GLKVector3 separation = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    // short-circuit if we don't have neighbours
    if( self.enemies.count == 0 )
        return separation;
    
    int count = 0;
    float perceptionDistance = self.simulation.perceptionDistance;
    for( ICMBoid * enemy in self.enemies )
    {
        GLKVector3 direction = GLKVector3Subtract(self.position, enemy.position);
        float distance = GLKVector3Length(direction);
        
        if( distance > 0.0f && distance < perceptionDistance )
        {
            direction = GLKVector3Normalize(direction);
            GLKVector3 localSeparation = GLKVector3MultiplyScalar(direction, perceptionDistance / (distance));
            
            separation = GLKVector3Add(separation, localSeparation);
        }
    }
    
    if( count == 0.0f || GLKVector3AllEqualToScalar(separation, 0.0f) )
        return separation;
    else
    {
        // normalize the vector
        separation = GLKVector3DivideScalar(separation, (float)count);
        
        separation = GLKVector3Normalize(separation);
        return separation;
    }
}

- (GLKVector3) boundsAcceleration:(double)deltaT
{
    GLKVector3 acceleration = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    CGFloat inset = 20.0f;
    
    if( self.position.x < inset )
        acceleration.v[0] = inset - self.position.x;
    else if( self.position.x > self.simulation.size.x - inset )
        acceleration.v[0] = self.simulation.size.x - inset - self.position.x;
    
    if( self.position.y < inset )
        acceleration.v[1] = inset - self.position.y;
    else if( self.position.y > self.simulation.size.y - inset )
        acceleration.v[1] = self.simulation.size.y - inset - self.position.y;
    
    if( GLKVector3AllEqualToScalar(acceleration, 0.0f) )
        return acceleration;
    else
        return GLKVector3Normalize(acceleration);
}

- (void) stepSimulation:(double)deltaT
{
    GLKVector3 alignment    = [self alignmentAcceleration];
    GLKVector3 cohesion     = [self cohesionAcceleration:deltaT];
    GLKVector3 separation   = [self separationAcceleration:deltaT];
    GLKVector3 bounds       = [self boundsAcceleration:deltaT];
    GLKVector3 fear         = [self fearAcceleration];
    
    // scale our accelerations
    alignment   = GLKVector3MultiplyScalar(alignment, self.simulation.alignment);
    cohesion    = GLKVector3MultiplyScalar(cohesion, self.simulation.cohesion);
    separation  = GLKVector3MultiplyScalar(separation, self.simulation.separation);
    fear        = GLKVector3MultiplyScalar(fear, self.simulation.fear);
    bounds      = GLKVector3MultiplyScalar(bounds, 10.0);
    
    GLKVector3 acceleration = GLKVector3Make(0.0, 0.0, 0.0);
    acceleration = GLKVector3Add(acceleration, alignment);
    acceleration = GLKVector3Add(acceleration, cohesion);
    acceleration = GLKVector3Add(acceleration, separation);
    acceleration = GLKVector3Add(acceleration, fear);
    acceleration = GLKVector3Add(acceleration, bounds);
    
    // instantaneous velocity from our instantaneous acceleration is:
    // v' = v + (alignment + cohesion + separation) * deltaT
    self.velocity = GLKVector3Add(self.velocity, GLKVector3MultiplyScalar(acceleration, deltaT));
    self.velocity = GLKVector3Add(self.velocity, bounds);
    self.velocity = GLKVector3Limit(self.velocity, 100.0);
    
    // p = p + v * dt
    self.position = GLKVector3Add(self.position, GLKVector3MultiplyScalar(self.velocity, deltaT));
    self.position.v[2] = 0.0f;
}

@end
