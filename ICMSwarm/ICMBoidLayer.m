//
//  ICMBoidLayer.m
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-20.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import "ICMBoidLayer.h"
#import "ICMBoid.h"

@implementation ICMBoidLayer
{
    UIImage * _image;
}

@synthesize imageName = _imageName;

- (void) setImageName:(NSString *)imageName
{
    // load a new image for the given name
    _image = [UIImage imageNamed:imageName];
    
    // Core Animation can work directly with CGImageRef objects
    self.contents = (__bridge_transfer id)_image.CGImage;
}

- (void) update
{
    if( !self.boid )
        return;
    
    self.position = CGPointMake(self.boid.position.x, self.boid.position.y);
    
    // we don't have velocity, so don't rotate the layer
    if( GLKVector3AllEqualToScalar(self.boid.velocity, 0.0) )
        return;
    
    GLKVector3 localDirection = GLKVector3Make(1.0, 0.0, 0.0);
    GLKVector3 globalDirection = GLKVector3Normalize(self.boid.velocity);
    
    // a . b = ||a|| * ||b|| * cos(angle)
    CGFloat angle = atan2f(GLKVector3Length(GLKVector3CrossProduct(localDirection, globalDirection)),
                           GLKVector3DotProduct(localDirection, globalDirection));
    
    if( globalDirection.y < 0.0f )
        angle = M_2_PI - angle;
    
    self.transform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0);
}

@end
