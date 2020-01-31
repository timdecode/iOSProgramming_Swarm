//
//  ICMOpenGLViewController.m
//  ICMSwarm
//
//  Created by Timothy Davison on 2012-11-28.
//  Copyright (c) 2012 University of Calgary. All rights reserved.
//

#import "ICMOpenGLViewController.h"

#import "ICMBoidSimulation.h"
#import "ICMFingerBoid.h"
#import "ICMBoid.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface ICMOpenGLViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    float * _vertexData;
    size_t _vertexDataSize;
    
    ICMBoidSimulation * _simulation;
    ICMBoid * _fingerBoid;
    
    UIPanGestureRecognizer * dragRecognizer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ICMOpenGLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // add a gesture recognizer for dragging a finger around
    dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDrag:)];
    [self.view addGestureRecognizer:dragRecognizer];
    
    // setup the boid simulation
    [self _setupSimulation];

    // create our opengl context
    // and configure it
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // setup GL
    [self setupGL];    
}


- (void) _setupSimulation
{
    _simulation = [[ICMBoidSimulation alloc] init];
    
    CGSize bounds = self.view.bounds.size;
    _simulation.size = GLKVector3Make(bounds.width, bounds.height, 0.0);
    
    // create 800 boids
    for( unsigned int i = 0; i < 800; i++ )
    {
        [_simulation createBoid];
    }
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

// -------------------------------------------------------------------------------------------------
#pragma mark - Touch Events
// -------------------------------------------------------------------------------------------------

- (void) didDrag:(UIPanGestureRecognizer*)pan
{
    if( pan.state == UIGestureRecognizerStateBegan )
    {
        // create a finger boid
        _fingerBoid = [_simulation createTouchEnemy];
        
        CGPoint point = [pan locationInView:self.view];
        _fingerBoid.position = GLKVector3Make(point.x, point.y, 0.0);
    }
    
    else if (pan.state == UIGestureRecognizerStateEnded )
    {
        // destroy a finger boid
        if( _fingerBoid )
        {
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

// -------------------------------------------------------------------------------------------------
#pragma mark - OpenGL
// -------------------------------------------------------------------------------------------------

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    
    [self setupBoidsVertexBuffer];
}

- (void) setupBoidsVertexBuffer
{
    _vertexDataSize = sizeof(GLKVector3) * 3 * _simulation.boids.count;
    _vertexData = malloc(_vertexDataSize);
    
    [self _updateVertexData];
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    glBufferData(GL_ARRAY_BUFFER,       // We want OpenGL to create a buffer for our vertex data on the GPU
                 _vertexDataSize,       // How many bytes are used by the vertex data
                 _vertexData,           // Give OpenGL a pointer to our data so that it can be copied to the GPU
                 GL_DYNAMIC_DRAW // Let OpenGL know that we are going to be sending this frequently
                 );
    

    // Now we tell OpenGL how to read the data in our vertex data. This data represents vertices,
    // vertices are composed of 3 floating point numbers, one float per component (x, y, z)
    //
    // Our _vertexData looks like this then
    // [x_0 y_0 z_0 x_1 y_1 z_1 ... x_(n-1) y_(n-1) z_(n-1)]
    //
    // That is 3 floats per vertex, and n vertices 
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,  // the vertex attribute whose information we telling OpenGL where to find
                          3,                        // how many elements are there for this attribute?  (we are going to have 3 floats, representing a vertex)
                          GL_FLOAT,                 // what type of elements are these? (each component is a float)
                          GL_FALSE,                 // should OpenGL normalize this data? (no)
                          12,                       // how many bytes separate each vertex? (3 * sizeof(float) = 12)
                          BUFFER_OFFSET(0)          // where in the data can OpenGL find the first element? (at the beginning, 0)
                          );
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void) _updateVertexData
{
    NSUInteger numBoids = _simulation.boids.count;
    NSArray * boids = _simulation.boids;
    
    float * vertex = _vertexData;
    
    static unsigned int const X = 0;
    static unsigned int const Y = 1;
    static unsigned int const Z = 2;
    
    GLKVector3 arrow = GLKVector3Make(1.0, 0.0, 0.0);

    // go through all of the triangles represented each of our boids
    //   - update the position of each triangle based upon the position and direction of the boid
    for( NSUInteger i = 0; i < numBoids; i++ )
    {
        // get our position and direction
        ICMBoid * boid = boids[i];
        GLKVector3 position = boid.position;
        GLKVector3 direction = GLKVector3Normalize(boid.velocity);
        direction.v[2] = 0.0;

        // find a rotation transformation that gets us from the arrow direction (points right)
        // to the direction that the boid is facing
        // the following code is a nice trick one can do to find the shortest arc in 4-space
        // between two unit-length vectors
        GLKVector3 cross = GLKVector3CrossProduct(arrow, direction);
        GLKQuaternion rotation = GLKQuaternionMake(cross.x, cross.y, cross.z, 1.0 + GLKVector3DotProduct(arrow, direction));
        rotation = GLKQuaternionNormalize(rotation);
        
        GLKVector3 vert;
        
        // rotate the <-4, -4, 0> coordinate of the triangle by the direction the boid is facing
        vert = GLKVector3Make(-4.0, -4.0, 0.0);
        vert = GLKQuaternionRotateVector3(rotation, vert);
        // update the vertex based on the boids position, and the rotate corner of the triangel
        vertex[X] = vert.x + position.x;
        vertex[Y] = vert.y + position.y;
        vertex[Z] = vert.z + position.z;
        vertex += 3;

        // rotate and translate corner 2 of the triangle
        vert = GLKVector3Make(-4.0,  4.0, 0.0);
        vert = GLKQuaternionRotateVector3(rotation, vert);
        vertex[X] = vert.x + position.x;
        vertex[Y] = vert.y + position.y;
        vertex[Z] = vert.z + position.z;
        vertex += 3;

        // rotate and translate corder 3 of the triangle
        vert = GLKVector3Make( 8.0,  0.0, 0.0);
        vert = GLKQuaternionRotateVector3(rotation, vert);
        vertex[X] = vert.x + position.x;
        vertex[Y] = vert.y + position.y;
        vertex[Z] = vert.z + position.z;
        vertex += 3;
    }
}

// this is called by UIGLViewController before we draw with opengl
// this is a good place to update a simulation, and to calculate projection and model-view matrices
- (void)update
{
    // update our simulation
    [_simulation stepSimulation:1/30.0];
    
    // update our vertex data with the new positions and velocities
    [self _updateVertexData];

    // now, we will calculate a projection matrix that will convert our triangle vertices from
    // simulation space into screen space
    CGRect bounds = self.view.bounds;
    
    // an orthographic projection is one where the objects are not distorted by distance
    // this is like an engineer's or draftsman's drawing of an object
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(bounds.origin.x,                      // left edge
                                                      bounds.origin.x + bounds.size.width,  // right edge
                                                      bounds.origin.y + bounds.size.height, // bottom
                                                      bounds.origin.y,                      // top
                                                      -10.0,                                // near
                                                      10.0                                  // far
                                                      );
    
    // the model-view matrix can translate, rotate and scale whatever we want to draw to someplace
    // in the world, in our case though, we don't want to do anything
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    
    // calculate a combined matrix that projects and translates our boids onto the screen
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
}

// this is called each time OpenGL wants to draw (usually on a frame-sync)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // set the background colour
    glClearColor(56.0/255.0, 105.0/255.0, 123.0/255.0, 1.0f);
    // clear the color and depth-buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // make our vertex-array definition the current focus on the OpenGL state machine
    glBindVertexArrayOES(_vertexArray);

    // tell openGL to make the buffer of our vertex array the current focus of the OpenGL state machine
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    // upload our updated vertex data to the buffer we just focused above
    glBufferData(GL_ARRAY_BUFFER,       // We want OpenGL to create a buffer for our vertex data on the GPU
                 _vertexDataSize,       // How many bytes are used by the vertex data
                 _vertexData,           // Give OpenGL a pointer to our data so that it can be copied to the GPU
                 GL_DYNAMIC_DRAW // Let OpenGL know that we are going to be sending this frequently
                 );

    // tell OpenGL to render our triangles using the shader defined by _program
    glUseProgram(_program);
    
    // tell the shader what our model-view-projection matrix is so that it can transform the vertices
    // that we are about to draw
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    
    // tell opengl to draw our triangles!
    // (draw 3 * number_of_boids vertices, where 3 is the number of vertices in a triangle)
    glDrawArrays(GL_TRIANGLES, 0, 3 * _simulation.boids.count);
}

#pragma mark -  OpenGL ES 2 shader compilation

// this is ugly boilder-plate to load the shaders that will transform our vertices and draw pixels
// to the screen
- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end