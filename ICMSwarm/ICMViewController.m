//
//  ICMViewController.m
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-20.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import "ICMViewController.h"

#import "ICMBoidSimulation.h"
#import "ICMBoid.h"
#import "ICMBoidLayer.h"

@interface ICMViewController ()

@end

@implementation ICMViewController
{
    NSTimer * _simulationTimer;
    
    ICMBoidSimulation * _simulation;
    NSMutableArray * _boidLayers;
    
    UIPanGestureRecognizer * dragRecognizer;
    
    ICMBoid * _fingerBoid;
}

- (void) _startTimer
{
    // Create a timer that will call stepSimulation: 30 times/second.
    _simulationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0
                                                        target:self
                                                      selector:@selector(stepSimulation:)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _boidLayers = [NSMutableArray array];
    
    [self _setupSimulation];
    [self _startTimer];
    
    dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDrag:)];
    
    [self.view addGestureRecognizer:dragRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) dealloc
{
    // Stop the timer from firing
    [_simulationTimer invalidate];
}

- (void) _setupSimulation
{
    _simulation = [[ICMBoidSimulation alloc] init];
    
    CGSize bounds = self.view.bounds.size;
    _simulation.size = GLKVector3Make(bounds.width, bounds.height, 0.0);
    
    // create 800 boids
    for( unsigned int i = 0; i < 800; i++ )
    {
        ICMBoid * boid = [_simulation createBoid];
        
        // also create a layer for the boid
        ICMBoidLayer * layer = [[ICMBoidLayer alloc] init];
        layer.boid = boid;
        layer.imageName = @"arrow";
        layer.bounds = CGRectMake(0.0, 0.0, 20.0, 20.0);
        
        
        // let the boid hold onto its layer
        boid.userObject = layer;
        
        [self.view.layer addSublayer:layer];
        
        [_boidLayers addObject:layer];
    }
}

- (void) didDrag:(UIPanGestureRecognizer*)pan
{
    if( pan.state == UIGestureRecognizerStateBegan )
    {
        // create a finger boid
        _fingerBoid = [_simulation createTouchEnemy];
        
        CGPoint point = [pan locationInView:self.view];
        _fingerBoid.position = GLKVector3Make(point.x, point.y, 0.0);
        
        // also create a layer for the boid
        ICMBoidLayer * layer = [[ICMBoidLayer alloc] init];
        layer.boid = _fingerBoid;
        layer.imageName = @"enemy";
        layer.bounds = CGRectMake(0.0, 0.0, 20.0, 20.0);
        
        
        // let the boid hold onto its layer
        _fingerBoid.userObject = layer;
        
        [self.view.layer addSublayer:layer];
        
        [_boidLayers addObject:layer];
    }
    
    else if (pan.state == UIGestureRecognizerStateEnded )
    {
        // destroy a finger boid
        if( _fingerBoid )
        {
            CALayer * layer = _fingerBoid.userObject;
            
            [layer removeFromSuperlayer];
            
            [_simulation removeBoid:_fingerBoid];
            
            _fingerBoid = nil;
        }
    }
    else
    {
        // update a finger boid
        CGPoint point = [pan locationInView:self.view];
        CGPoint velocity = [pan velocityInView:self.view];
        
        _fingerBoid.position = GLKVector3Make(point.x, point.y, 0.0);
        _fingerBoid.velocity = GLKVector3Make(velocity.x, velocity.y, 0.0);        
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_simulationTimer invalidate];
    _simulationTimer = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    // startup the timer again
    if( _simulationTimer )
        return;
    
    [self _startTimer];
}

- (void) stepSimulation:(NSTimer*)timer
{
    double stepTime = timer.timeInterval;
        
    // update the simulation
    [_simulation stepSimulation:stepTime];
    
    // update the visualization of the simulation
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    for( ICMBoidLayer * layer in _boidLayers )
    {
        [layer update];
    }
    
    [CATransaction commit];
}

@end
