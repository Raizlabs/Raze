//
//  ViewController.m
//  Raze Scene Sandbox
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "ViewController.h"
#import "RZXViewNode.h"

@import RazePhysics;

@interface ViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet RZXSceneView *sceneView;
@property (nonatomic, strong) RZXModelNode *officeNode;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSArray *names;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // The scene view is set in the storyboard and is ultimately a UIVIew with an EAGLCALayer
    self.sceneView.backgroundColor = [UIColor whiteColor];
    self.sceneView.framesPerSecond = 60;
    self.sceneView.multisampleLevel = 4;

    // The effect (a wrapper for an OpenGL shader) that is applied to  the scene
    RZXADSPhongEffect *effect = [RZXADSPhongEffect effect];
    effect.lightPosition = GLKVector3Make(0.0f, 10.0f, 20.0f);

    // The scene is the base node. Anything added to the scene will inherit its properties (the effect, camera, and any transforms)
    RZXScene *scene = [RZXScene sceneWithEffect: effect];

    float ratio = CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds);
    scene.camera = [RZXCamera cameraWithFieldOfView:GLKMathDegreesToRadians(35) aspectRatio:ratio nearClipping:0.001 farClipping:100];
    [scene.camera.transform setTranslation:GLKVector3Make(0.0, 5.0, 10.0)];
    [scene.camera.transform rotateXBy:-0.25];

    self.sceneView.scene = scene;

    RZXMesh *officeMesh = [RZXMesh meshWithName:@"retroOffice"];
    RZXStaticTexture *officeTexture = [RZXStaticTexture textureFromFile:@"officeTexture.png"];

    RZXModelNode *officeNode = [RZXModelNode modelNodeWithMesh:officeMesh texture:officeTexture];
    [scene.rootNode addChild:officeNode];
    [officeNode.transform setTranslation:GLKVector3Make(0.0f, 8.0, -8.0)];
    self.officeNode = officeNode;

    RZXCubeMesh *cube = [RZXCubeMesh cube];
    RZXMeshCollider *cubeCollider = [RZXMeshCollider colliderWithConvexMesh:cube transform:[RZXTransform3D transformWithScale:RZXVector3MakeScalar(2.0f)]];

    officeNode.physicsBody = [RZXPhysicsBody bodyWithCollider:cubeCollider];
    officeNode.physicsBody.restitution = 0.3f;

    RZXStaticTexture *greyTex = [RZXStaticTexture textureFromFile:@"greyTexture.png"];
    RZXModelNode *quad = [RZXModelNode modelNodeWithMesh:[RZXQuadMesh quad] texture:greyTex];

    quad.physicsBody = [RZXPhysicsBody bodyWithCollider:[RZXBoxCollider colliderWithSize:GLKVector3Make(1.0, 1.0, 0.1)]];
//    quad.physicsBody.affectedByGravity = NO;
    quad.physicsBody.dynamic = NO;
    quad.physicsBody.restitution = 0.3f;

    [quad.transform setTranslation:GLKVector3Make(0.0, -2.0, 0.0)];
    [quad.transform setScale:GLKVector3Make(50.0, 50.0, 1.0)];
    [quad.transform rotateXBy:-M_PI_2];

    [scene.rootNode addChild:quad];

    RZXMesh *screenMesh = [RZXMesh meshWithName:@"officeScreen"];
    RZXViewNode *screenNode = [RZXViewNode nodeWithView:self.tableView.superview];
    screenNode.mesh = screenMesh;
    [officeNode addChild:screenNode];

    [self configureGestureRecognizers];
    [self configureNames];
}

- (void)configureGestureRecognizers
{
    self.view.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:panRecognizer];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapRecognizer];

    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];

    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPressRecognizer];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)configureNames
{
    // Current Raizlabs Employees
    self.names = @[ @"Nick Bonatsakis",
                    @"Matt Buckley",
                    @"Dave Counts",
                    @"Anik Das",
                    @"Adam Faja",
                    @"Gary Fortier",
                    @"Michael Gorbach",
                    @"Jon Green",
                    @"Chris Hoogewerff",
                    @"Joe Howard",
                    @"Adam Howitt",
                    @"Dylan James",
                    @"Ben Johnson",
                    @"Justin Kaufman",
                    @"Brian King",
                    @"Matt Lawson",
                    @"Michael LeBarron",
                    @"Richard Lucas",
                    @"Adam Nelsen",
                    @"Jason Petralia",
                    @"Jenn  Pleus",
                    @"Greg Raiz",
                    @"Alex Rouse",
                    @"Aimee Silverman",
                    @"Eric Slosser",
                    @"Mallory Sluetz",
                    @"John Stricker",
                    @"Rob Visentin",
                    @"Hallie Verrier",
                    @"John Watson",
                    @"Josh Wilson"];
}

- (void)handlePan:(UIPanGestureRecognizer *)panRecognizer
{
    [self.officeNode.transform rotateYBy: [panRecognizer velocityInView:self.view].x * 0.0005];
}

- (void)handleTap:(UITapGestureRecognizer *)tapRecognizer
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.toValue = [NSValue rzx_valueWithQuaternion:GLKQuaternionMakeWithAngleAndAxis(0.0, 0.0, 0.0, 0.0)];
    animation.duration = 0.2;
    [self.officeNode addAnimation:animation forKey:@"rotation"];

    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
    animation.toValue = [NSValue rzx_valueWithVec3:GLKVector3Make(0.0, 0.0, 0.0)];
    animation.duration = 0.2;
    [self.officeNode addAnimation:translationAnimation forKey:@"translation"];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchRecognizer
{
    [self.officeNode.transform translateZBy:pinchRecognizer.velocity * 0.01];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
    animation.toValue = [NSValue rzx_valueWithVec3:GLKVector3Make(0.0, 0.74, 3.5)];
    animation.duration = 1.0;

    [self.officeNode addAnimation:animation forKey:@"translation"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.names.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];

    cell.textLabel.text = self.names[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

@end
