//
//  Edge.m
//  DomScreenSaver
//
//  Created by Deon Botha on 02/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Edge.h"


@implementation Edge
@dynamic startNode, endNode;

-(id) initWithStartNode: (NSPoint) startNode
                endNode: (NSPoint) endNode {
    if ((self = [super init]) != nil) {
        startNode_ = startNode;
        endNode_ = endNode;
    }
    
    return self;
}

-(const NSPoint *) startNode {
    return &startNode_;
}

-(const NSPoint *) endNode {
    return &endNode_;
}

@end
