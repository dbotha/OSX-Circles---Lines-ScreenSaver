//
//  DomScreenSaverView.h
//  DomScreenSaver
//
//  Created by Deon Botha on 02/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "MyOpenGLView.h"

@interface DomScreenSaverView : ScreenSaverView {
@private
    NSMutableArray *layers;
    MyOpenGLView *glView;
}

- (void)initOpenGL;
- (void)drawPoint: (const NSPoint *) p withRadius: (float) radius scaleX: (float) scaleX scaleY: (float) scaleY;
- (void)drawEdgeFrom: (const NSPoint *) p1 to: (const NSPoint *) p2 percentComplete: (float) percentComplete scaleX: (float) scaleX scaleY: (float) scaleY ;

@end
