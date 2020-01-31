//
//  ICMBoidLayer.h
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-20.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class ICMBoid;

@interface ICMBoidLayer : CALayer

@property (readwrite, nonatomic, weak) ICMBoid * boid;
@property (readwrite, nonatomic, strong) NSString * imageName;

- (void) update;

@end
