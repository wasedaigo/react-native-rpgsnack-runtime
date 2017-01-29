//
//  RuntimeView.m
//  RNRPGSnackRuntime
//
//  Created by Daigo Sato on 1/25/17.
//  Copyright © 2017 Daigo Sato. All rights reserved.
//

#import "RuntimeView.h"
#import <Mobile/Mobile.h>

@implementation RuntimeView
GLKView* _glkView;

- (id)init {
    if ( self = [super init] ) {
        self.width = 320;
        self.height = 480;

        _glkView = [[GLKView alloc] init];
        _glkView.delegate = self;
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _glkView.context = context;
        [self addSubview: _glkView];
        [EAGLContext setCurrentContext:context];

        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, self.width, self.height);
    [_glkView setFrame: self.frame];

    if (!MobileIsRunning()) {

        MobileSetData([self.gamedata dataUsingEncoding:NSUTF8StringEncoding]);
        NSError* err = nil;
        CGRect rect = self.frame;
        int width = MobileScreenWidth();
        int height = MobileScreenHeight();
        double scaleX = (double)rect.size.width / (double)MobileScreenWidth();
        double scaleY = (double)rect.size.height / (double)MobileScreenHeight();
        double scale = MIN(scaleX, scaleY);
        MobileStart(scale, &err);
        if (err != nil) {
            NSLog(@"Error: %@", err);
        }
        
        if (self.onRuntimeInit) {
            self.onRuntimeInit(@{});
        }
    }
}

- (void)drawFrame{
    [_glkView setNeedsDisplay];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    NSError* err = nil;
    MobileUpdate(&err);
    if (err != nil) {
        NSLog(@"Error: %@", err);
    }
}

- (void)updateTouches:(NSSet*)touches {
    for (UITouch* touch in touches) {
        if (touch.view != _glkView) {
            continue;
        }
        CGPoint location = [touch locationInView: _glkView];
        MobileUpdateTouchesOnIOS(touch.phase, (int64_t)touch, location.x, location.y);
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [self updateTouches:touches];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    [self updateTouches:touches];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    [self updateTouches:touches];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [self updateTouches:touches];
}

@end
