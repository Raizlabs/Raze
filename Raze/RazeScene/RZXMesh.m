//
//  RZXMesh.m
//  RazeScene
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXMesh.h"

#import <OpenGLES/ES2/glext.h>
#import <RazeScene/RZXVertexObjectData.h>
#import <RazeCore/RZXGLContext.h>

@interface RZXMesh()

@property (copy, nonatomic) NSString *meshName;
@property (copy, nonatomic) NSString *meshFileName;

@property (strong, nonatomic) RZXVertexObjectData *vertexObjectData;

@end

@implementation RZXMesh

+ (instancetype)meshWithName:(NSString *)name meshFileName:(NSString *)meshFileName
{
    return [[self alloc] initWithName:name meshFileName:meshFileName];
}

#pragma mark - RZOpenGLObject

- (void)setupGL
{
    if ( self.vertexObjectData == nil ) {
        self.vertexObjectData = [RZXVertexObjectData vertexObjectDataWithFileName:_meshFileName];
    }

    [self.vertexObjectData setupGL];
}

- (void)bindGL
{
    [self.vertexObjectData bindGL];
}

- (void)teardownGL
{
    [self.vertexObjectData teardownGL];
    self.vertexObjectData = nil;
}

#pragma mark - RZRenderable

- (void)render
{
    [self.vertexObjectData render];
}

#pragma mark - private methods

- (instancetype)initWithName:(NSString *)name meshFileName:(NSString *)meshFileName
{
    self = [super init];
    if ( self != nil ) {
        _meshName = name;
        _meshFileName = meshFileName;
    }
    return self;
}

- (NSString *)cacheKeyForContext:(RZXGLContext *)context
{
    return [NSString stringWithFormat:@"%@%p",self.meshName, context];
}

@end
