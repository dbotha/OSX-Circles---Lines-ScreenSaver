//
//  AnimatingLayer.m
//  DomScreenSaver
//
//  Created by Deon Botha on 02/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimatingLayer.h"
#import "DomScreenSaverView.h"
#import "Edge.h"


@implementation AnimatingLayer
@synthesize edges=edges_, growing=growing_, percentComplete=percentComplete_; 

const NSUInteger MIN_ANIMATE_DURATION = 500;
const NSUInteger MAX_ANIMATE_DURATION = 4000;
const NSUInteger MIN_NODES = 5;
const NSUInteger MAX_NODES = 30;
const NSUInteger WIDTH_IN_POINTS = 10000;
const NSUInteger HEIGHT_IN_POINTS = 10000;

NSMutableArray *edges_;
NSMutableArray *startNodes_;
NSMutableArray *endNodes_;
BOOL growing_;
int totalElapsedTime_;
int percentComplete_;

-(id) init {
    if ((self = [super init]) != nil) {
        edges_      = [[NSMutableArray alloc] init];
        startNodes_ = [[NSMutableArray alloc] init];
        endNodes_   = [[NSMutableArray alloc] init];
        growing_    = YES;
        totalElapsedTime_   = 0;
        animateDuration_    = SSRandomIntBetween(MIN_ANIMATE_DURATION, MAX_ANIMATE_DURATION - 1);
        percentComplete_    = 0;
    }
    return self;
}

-(void) dealloc {
    [endNodes_ release];
    [startNodes_ release];
    [edges_ release];
    [super dealloc];
}

-(void) updateWithElapsedTime: (int) elapsedTime {
    totalElapsedTime_ += elapsedTime;
    percentComplete_ = totalElapsedTime_ / (float) animateDuration_;
    if (percentComplete_ >= 1.0) {
        animateDuration_ = SSRandomIntBetween(MIN_ANIMATE_DURATION, MAX_ANIMATE_DURATION - 1);
        percentComplete_ = 0;
        totalElapsedTime_ = 0;
        
        growing_ = !growing_;
        if (growing_) {
            [self generateNewEdges];	
        }
    }
}

-(void) generateNewEdges {
    // on the absolute first run we don't have any previous end nodes to start from so generate
    // some random start nodes aswell.
    BOOL firstRun = [startNodes_ count] == 0; 
    
    // generate some random nodes to grow edges from
    NSMutableArray *temp = startNodes_;
    startNodes_ = endNodes_;
    endNodes_   = temp;
    [endNodes_ removeAllObjects];
    
    NSUInteger numNodes = SSRandomIntBetween(MIN_NODES, MAX_NODES - 1);
    for (NSUInteger i = 0; i < numNodes; ++i) {
        if (firstRun) {

            [startNodes_ addObject: [NSValue valueWithPoint: 
                                     NSMakePoint(SSRandomIntBetween(0, WIDTH_IN_POINTS - 1), SSRandomIntBetween(0, HEIGHT_IN_POINTS - 1))]];
        }
        [endNodes_ addObject: [NSValue valueWithPoint: 
                               NSMakePoint(SSRandomIntBetween(0, WIDTH_IN_POINTS - 1), SSRandomIntBetween(0, HEIGHT_IN_POINTS - 1))]];
    }
    
    // generate some edges between nodes.
    [edges_ removeAllObjects];
    
    // require every start node must have an outward growing edge, provides a slightly nicer looking effect
    NSMutableSet *endNodesWithIncoming = [[NSMutableSet alloc] initWithCapacity: [endNodes_ count]];
    for (NSUInteger i = 0; i < [startNodes_ count]; ++i) {
        NSValue *startNode = [startNodes_ objectAtIndex: i];
        NSValue *endNode   = [endNodes_ objectAtIndex:SSRandomIntBetween(0, (int) [endNodes_ count] - 1)];
        [endNodesWithIncoming addObject: endNode];
        
        Edge *edge = [[Edge alloc] initWithStartNode: [startNode pointValue] endNode: [endNode pointValue]];
        [edges_ addObject: edge];
        [edge release];
    }
    
    // randomly generate some more edges
    NSUInteger numEdges = SSRandomIntBetween(0, (int) ([endNodes_ count] * [startNodes_ count]));
    for (NSUInteger i = 0; i < numEdges; ++i) {
        NSValue *startNode = [startNodes_ objectAtIndex:SSRandomIntBetween(0, (int) [startNodes_ count] - 1)];
        NSValue *endNode   = [endNodes_ objectAtIndex:SSRandomIntBetween(0,   (int) [endNodes_ count] - 1)];
        [endNodesWithIncoming addObject: endNode];

        Edge *edge = [[Edge alloc] initWithStartNode: [startNode pointValue] endNode: [endNode pointValue]];
        [edges_ addObject: edge];
        [edge release];
    }
    
    // remove all the end nodes that have node edges leading to them, this is possible as
    // we randomly select end nodes.
    for (NSInteger i = [endNodes_ count] - 1; i >= 0; --i) {
        NSValue *endNode = [endNodes_ objectAtIndex: i];
        if (![endNodesWithIncoming containsObject: endNode]) {
            [endNodes_ removeObjectAtIndex: i];
        }
    }

    [endNodesWithIncoming release];
}

@end
