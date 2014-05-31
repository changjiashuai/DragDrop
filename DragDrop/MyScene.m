//
//  MyScene.m
//  DragDrop
//
//  Created by CJS on 14-5-7.
//  Copyright (c) 2014年 常家帅. All rights reserved.
//

#import "MyScene.h"

static NSString *const kAnimalNodeName = @"movable";

@interface MyScene ()

@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKSpriteNode *selectedNode;

@end

@implementation MyScene

static inline CGPoint mult(CGPoint a, float b)
{
    return CGPointMake(a.x * b, a.y *b);
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // loading the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"blue-shooting-stars"];
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        // loading the images
        NSArray *imageNames = @[@"bird", @"cat", @"dog", @"turtle"];
        
        for (int i=0; i < [imageNames count]; i++) {
            NSString *imageName = [imageNames objectAtIndex:i];
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            [sprite setName:kAnimalNodeName];
            
            float offsetFraction = ((float)(i + 1)) / ([imageNames count] + 1);
            [sprite setPosition:CGPointMake(size.width * offsetFraction, size.height / 2)];
            [_background addChild:sprite];
            
        }
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
}

-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        [self selectNodeForTouch:touchLocation];
    }else if (recognizer.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        if (![[_selectedNode name] isEqualToString:kAnimalNodeName]) {
            float scrollDuration = 0.2;
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            CGPoint pos = [_selectedNode position];
            CGPoint p = mult(velocity, scrollDuration);
            
            CGPoint newPos = CGPointMake(pos.x + p.x, pos.y + p.y);
            newPos = [self boundLayerPos:newPos];
            [_selectedNode removeAllActions];
            
            SKAction *moveTo = [SKAction moveTo:newPos duration:scrollDuration];
            [moveTo setTimingMode:SKActionTimingEaseOut];
            [_selectedNode runAction:moveTo];
            
        }
    }
}

//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint positionInScene = [touch locationInNode:self];
//    CGPoint previousPosition = [touch previousLocationInNode:self];
//    
//    CGPoint translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y);
//    [self panForTranslation:translation];
//}

-(void)panForTranslation:(CGPoint)translation
{
    CGPoint position = [_selectedNode position];
    if ([[_selectedNode name] isEqualToString:kAnimalNodeName]) {
        [_selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
    }else{
        CGPoint newPos = CGPointMake(position.x + translation.x, position.y + translation.y);
        [_background setPosition:[self boundLayerPos:newPos]];
    }
}

-(CGPoint)boundLayerPos:(CGPoint)newPos
{
    CGSize winSize = self.size;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -[_background size].width + winSize.width);
    retval.y = [self position].y;
    return retval;
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    /* Called when a touch begins */
//    UITouch *touch = [touches anyObject];
//    CGPoint positionInScene = [touch locationInNode:self];
//    [self selectNodeForTouch:positionInScene];
//}

-(void)selectNodeForTouch:(CGPoint)touchLocation
{
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    if (![_selectedNode isEqual:touchedNode]) {
        [_selectedNode removeAllActions];
        [_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
        _selectedNode = touchedNode;
        
        if ([[touchedNode name] isEqualToString:kAnimalNodeName]) {
            SKAction *sequence = [SKAction sequence:@[[SKAction rotateToAngle:degToRad(-4.0f) duration:0.1],
                                                      [SKAction rotateToAngle:0.0 duration:0.1],
                                                      [SKAction rotateToAngle:degToRad(4.0f) duration:0.1]]];
                                  [_selectedNode runAction:[SKAction repeatActionForever:sequence]];
        }
    }
}
                                  
float degToRad(float degree)
{
    return degree / 180.0f * M_PI;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
