//
//  RZXGPUObject.h
//  RazeCode
//
//  Created by Rob Visentin on 7/16/15.
//

#import <RazeCore/RZXGLContext.h>
#import <RazeCore/RZXBase.h>

typedef void (^RZXGPUObjectTeardownBlock)(RZXGLContext *context);

@interface RZXGPUObject : NSObject

@property (strong, nonatomic, readonly) RZXGLContext *configuredContext;

@property (nonatomic, readonly) RZXGPUObjectTeardownBlock teardownHandler;

- (BOOL)setupGL;
- (BOOL)bindGL;
- (void)teardownGL;

@end
