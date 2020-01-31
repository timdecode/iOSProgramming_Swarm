//
//  Shader.vsh
//  Test
//
//  Created by Timothy Davison on 2012-11-28.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec4 diffuseColor = vec4(1.0,1.0,1.0, 1.0);
    
    colorVarying = diffuseColor;
    
    gl_Position = modelViewProjectionMatrix * position;
}
