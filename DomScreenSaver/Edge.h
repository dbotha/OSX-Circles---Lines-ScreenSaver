//
//  Edge.h
//  DomScreenSaver
//
//  Created by Deon Botha on 02/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Edge : NSObject {
@private
    NSPoint startNode_;
    NSPoint endNode_;
}

@property (nonatomic, readonly) const NSPoint *startNode;
@property (nonatomic, readonly) const NSPoint *endNode;


-(id) initWithStartNode: (NSPoint) startNode
                endNode: (NSPoint) endNode;

@end
	