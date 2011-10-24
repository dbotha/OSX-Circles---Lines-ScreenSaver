//
//  DomScreenSaverView.m
//  DomScreenSaver
//
//  Created by Deon Botha on 02/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <math.h>

#import "DomScreenSaverView.h"
#import "AnimatingLayer.h"
#import "Edge.h"

@implementation DomScreenSaverView

static const NSUInteger FPS = 30;
static const NSUInteger NUM_LAYERS = 1;
static const NSUInteger MAX_CIRCLE_DIAMETER = 30;
static const NSUInteger WIDTH_IN_POINTS = 10000;
static const NSUInteger HEIGHT_IN_POINTS = 10000;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        layers = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < NUM_LAYERS; ++i) {
            AnimatingLayer *layer = [[AnimatingLayer alloc] init];
            [layer generateNewEdges];
            [layers addObject: layer];
            [layer release];
        }
        
        /* Init OpenGL */
        NSOpenGLPixelFormatAttribute attributes[] = { 
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADepthSize, 16,
            NSOpenGLPFAMinimumPolicy,
            NSOpenGLPFAClosestPolicy,
            0 };  
        NSOpenGLPixelFormat *format;
        
        format = [[[NSOpenGLPixelFormat alloc] 
                   initWithAttributes:attributes] autorelease];
        
        glView = [[MyOpenGLView alloc] initWithFrame:NSZeroRect 
                                         pixelFormat:format];
		
        if (!glView)
        {             
            NSLog( @"Couldn't initialize OpenGL view." );
            [self autorelease];
            return nil;
        } 
        
        [self addSubview:glView]; 
        [self initOpenGL]; 
        
        [self setAnimationTimeInterval:1.0 / FPS];
    }
    return self;
}

- (void)dealloc {
    [glView removeFromSuperview];
    [glView release];
    [layers release];
    [super dealloc];
}

- (void)initOpenGL {
    [[glView openGLContext] makeCurrentContext];
    glShadeModel( GL_SMOOTH );
    glEnable( GL_LINE_SMOOTH );
    glEnable( GL_POLYGON_SMOOTH );
    glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
    glHint( GL_POLYGON_SMOOTH_HINT, GL_NICEST );
    glClearColor( 1.0f, 1.0f, 1.0f, 1.0f );
//    glClearDepth( 1.0f ); 
//    glEnable( GL_DEPTH_TEST );
//    glDepthFunc( GL_LEQUAL );
//    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [glView setFrameSize:newSize]; 
    
    [[glView openGLContext] makeCurrentContext];
    
    // Reshape
    glViewport(0, 0, (GLsizei)newSize.width, (GLsizei)newSize.height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    glOrtho(0, (GLdouble)newSize.width, 0, (GLdouble)newSize.height, -1, 1);
    glMatrixMode( GL_MODELVIEW );
    glLoadIdentity();		
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
	glEnable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
    
    [[glView openGLContext] update];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

    NSSize size = [self bounds].size;
    float scaleX = size.width / WIDTH_IN_POINTS;
    float scaleY = size.height / HEIGHT_IN_POINTS;
    
    [[glView openGLContext] makeCurrentContext];
    glClear(GL_COLOR_BUFFER_BIT);
    
    glColor3f(0.0f, 0.0f, 0.0f);       
    for (NSUInteger i = 0; i < [layers count]; ++i) {
        AnimatingLayer *layer = [layers objectAtIndex: i];
        for (NSUInteger j = 0; j < [layer.edges count]; ++j) {
            Edge *edge = [layer.edges objectAtIndex: j];

            if (layer.growing) {
                [self drawEdgeFrom: edge.startNode to: edge.endNode percentComplete: layer.percentComplete  scaleX: scaleX scaleY:scaleY];
                [self drawPoint: edge.startNode withRadius: MAX_CIRCLE_DIAMETER * (1.0 - layer.percentComplete) scaleX: scaleX scaleY:scaleY];
            } else {
                [self drawEdgeFrom: edge.endNode to:edge.startNode percentComplete:1.0 - layer.percentComplete  scaleX: scaleX scaleY:scaleY];
                [self drawPoint: edge.endNode withRadius: MAX_CIRCLE_DIAMETER * layer.percentComplete scaleX: scaleX scaleY: scaleY];
            }
        }
    }
    
    
    
    glFlush(); 
}


- (void)drawPoint: (const NSPoint *) p withRadius: (float) radius scaleX: (float) scaleX scaleY: (float) scaleY {
    float x = p->x * scaleX;
    float y = p->y * scaleY;

    glBegin( GL_TRIANGLE_FAN );
    glVertex2f(x, y);
    int segments = 100;
    int r = radius;
    for( int n = 0; n <= segments; ++n ) {
        float const t = 2 * M_PI * (float) n / (float) segments;
        glVertex2f(x + sin(t)*r, y + cos(t)*r);
    }
    glEnd();
}

- (void) drawEdgeFrom: (const NSPoint *) p1 to: (const NSPoint *) p2 percentComplete: (float) percentComplete scaleX: (float) scaleX scaleY: (float) scaleY  {
    float dx = p1->x - p2->x;
    float dy = p1->y - p2->y;
    
    float totalLineLength = sqrt(dx*dx + dy*dy);
    float partialLine = totalLineLength * percentComplete;
    
    float angle = atan2(dy, dx);
    float newX = p1->x - cos(angle) * partialLine;
    float newY = p1->y - sin(angle) * partialLine;

    glBegin(GL_LINES); 
    glVertex2i(p1->x * scaleX, p1->y * scaleY); 
    glVertex2i(newX * scaleX, newY * scaleY); 
    glEnd(); 
}

- (void)animateOneFrame
{
    // update
    for (NSUInteger i = 0; i < [layers count]; ++i) {
        [[layers objectAtIndex: i] updateWithElapsedTime: 1000 / FPS];
    }
    
    // render: request that our view be redrawn (causes Cocoa to call drawRect:)
    [self setNeedsDisplay: YES];
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
