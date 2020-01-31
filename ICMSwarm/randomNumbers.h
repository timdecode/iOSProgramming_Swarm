//
//  randomNumbers.h
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-20.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#ifndef ICMSwarm_randomNumbers_h
#define ICMSwarm_randomNumbers_h

#ifdef __cplusplus
extern "C" {
#endif
    
float float_random(float min, float max)
{
    return ((float)random() / (float)LONG_MAX) * (max - min) + min;
}

double double_random(double min, double max)
{
    return ((double)random() / (double)LONG_MAX) * (max - min) + min;
}
    
#ifdef __cplusplus
}
#endif

#endif
