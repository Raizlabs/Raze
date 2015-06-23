//
//  RZXNode.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RazeCore.h>

#import "RZXNode.h"

@interface RZXNode ()

@property (strong, nonatomic) NSMutableArray *mutableChildren;
@property (weak, nonatomic, readwrite) RZXNode *parent;

@end

@implementation RZXNode

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _mutableChildren = [NSMutableArray array];
        _transform = [RZXTransform3D transform];
    }
    return self;
}

#pragma mark - public methods

- (RZXEffect *)effect
{
    RZXEffect *effect = _effect;
    
    if ( effect == nil && self.parent != nil ) {
        effect = self.parent.effect;
    }
    
    return effect;
}

- (NSArray *)children
{
    return [self.mutableChildren copy];
}

- (void)addChild:(RZXNode *)child
{
    [self insertChild:child atIndex:self.mutableChildren.count];
}

- (void)insertChild:(RZXNode *)child atIndex:(NSUInteger)index
{
    [self.mutableChildren insertObject:child atIndex:index];
    child.parent = self;
}

- (void)removeFromParent
{
    [self.parent.mutableChildren removeObject:self];
    self.parent = nil;
}

- (GLKMatrix4)modelMatrix
{
    GLKMatrix4 modelMatrix = self.transform ? self.transform.modelMatrix : GLKMatrix4Identity;
    
    if ( self.parent != nil ) {
        modelMatrix = GLKMatrix4Multiply([self.parent modelMatrix], modelMatrix);
    }
    
    return modelMatrix;
}

- (GLKMatrix4)viewMatrix
{
    GLKMatrix4 viewMatrix = self.camera ? self.camera.viewMatrix : GLKMatrix4Identity;
    
    if ( self.parent != nil ) {
        viewMatrix = GLKMatrix4Multiply([self.parent viewMatrix], viewMatrix);
    }
    
    return viewMatrix;
}

- (GLKMatrix4)projectionMatrix
{
    GLKMatrix4 projectionMatrix = self.camera ? self.camera.projectionMatrix : GLKMatrix4Identity;
    
    if ( self.parent != nil ) {
        projectionMatrix = GLKMatrix4Multiply([self.parent projectionMatrix], projectionMatrix);
    }
    
    return projectionMatrix;
}

#pragma mark - RZXOpenGLObject

- (void)setupGL
{
    [self.effect setupGL];
    
    for ( RZXNode *child in self.children ) {
        [child setupGL];
    }
}

- (void)bindGL
{
// TODO: get resolution somehow
//    self.effect.resolution = GLKVector2Make(_backingWidth, _backingHeight);
    
    self.effect.modelViewMatrix = GLKMatrix4Multiply([self viewMatrix], [self modelMatrix]);
    self.effect.projectionMatrix = [self projectionMatrix];
    
    // can use modelView matrix for normal matrix if only uniform scaling occurs
    GLKVector3 scale = self.transform.scale;
    
    if ( scale.x == scale.y && scale.y == scale.z ) {
        self.effect.normalMatrix = GLKMatrix4GetMatrix3(self.effect.modelViewMatrix);
    }
    else {
        self.effect.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.effect.modelViewMatrix), NULL);
    }

    [self.effect prepareToDraw];
}

- (void)teardownGL
{
    [self.effect teardownGL];
    
    for ( RZXNode *child in self.children ) {
        [child teardownGL];
    }
}

#pragma mark - RZXRenderable

- (void)update:(NSTimeInterval)dt
{
    if (self.updateBlock != nil) {
        self.updateBlock(dt);
    }
    
    for ( RZXNode *child in self.children ) {
        [child update:dt];
    }
}

- (void)render
{
    for ( RZXNode *child in self.children ) {
        [child bindGL];
        [child render];
    }
}

@end
