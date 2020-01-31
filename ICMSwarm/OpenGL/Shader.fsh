//
//  Shader.fsh
//  Test
//
//  Created by Timothy Davison on 2012-11-28.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
