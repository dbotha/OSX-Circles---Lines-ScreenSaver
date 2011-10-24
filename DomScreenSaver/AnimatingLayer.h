//
//  AnimatingLayer.h
//  DomScreenSaver
//
//  Created by Deon Botha on 02/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnimatingLayer : NSObject {
@private
    NSMutableArray *edges_;
    NSMutableArray *startNodes_;
    NSMutableArray *endNodes_;
    BOOL growing_;
    NSInteger totalElapsedTime_;
    NSInteger animateDuration_;
    float percentComplete_;
}

@property (nonatomic, readonly) NSArray *edges;
@property (nonatomic) BOOL growing;
@property (nonatomic) float percentComplete;

-(id) init;
-(void) updateWithElapsedTime: (int) elapsedTime;
-(void) generateNewEdges;

@end
