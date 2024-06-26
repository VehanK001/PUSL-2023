import 'dart:async';


import 'package:flame/components.dart';
//import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter/src/services/hardware_keyboard.dart';
// ignore: implementation_imports, unnecessary_import
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, running, jumping, falling}


class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler {
  
String character;  
// ignore: use_super_parameters
Player ({position, this.character = 'Ninja Frog'}) :super(position: position);

final double stepTime = 0.05;
late final SpriteAnimation idleAnimation;
late final SpriteAnimation  runningAnimation;



final double _gravity = 9.8;
final double _jumpforce = 460;
final double _terminalVelocity = 300;
double horizontalMovement = 0;
double moveSpeed = 100;
Vector2 velocity = Vector2.zero();
bool isOnGround = false;
bool hasJumped = false;
List<CollisionBlock> collisionBlocks = [];



@override
  FutureOr<void> onLoad() {
    
    _loadAllAnimations();
   // debugMode = true;
  
    return super.onLoad(); 
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }
  
  @override
  
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
    keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
    keysPressed.contains(LogicalKeyboardKey.arrowRight);

  horizontalMovement += isLeftKeyPressed ? -1 : 0;
  horizontalMovement += isRightKeyPressed ? 1 : 0;

  hasJumped = keysPressed.contains(LogicalKeyboardKey. space);

    
    return super.onKeyEvent(event, keysPressed);
  }
  
  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);

    runningAnimation = _spriteAnimation('Run', 12);
    
    



    //list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,


    };

    //set current animation
    current = PlayerState.idle;

  }

  SpriteAnimation _spriteAnimation (String state, int amount){

  return SpriteAnimation.fromFrameData(game.images.fromCache('Main Characters/$character/$state (32x32).png'), SpriteAnimationData.sequenced(amount: 12, stepTime: stepTime, textureSize: Vector2.all(32))); 

}
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if(velocity.x < 0 &&  scale.x > 0) {
      flipHorizontallyAroundCenter();
    }else if (velocity.x > 0 && scale.x  < 0) {
      flipHorizontallyAroundCenter();
    }

    //check if moving set running
    if (velocity.x > 0 ||  velocity.x < 0 ) playerState = PlayerState.running;
     //check if moving set jumping
    if(velocity.y > 0) playerState = PlayerState.falling;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {

    if (hasJumped && isOnGround) _playerJump(dt);

    if(velocity.y > _gravity) isOnGround = false;
 

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt; 
  }
  void _playerJump(double dt) {
    velocity.y = -_jumpforce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }
  
  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      // handle collision
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - width;
            break;
           
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + width ;
            break;
            
          }
            
          }
        }
      }
    }
    
      void _applyGravity(double dt) {
        velocity.y += _gravity;
        velocity.y = velocity.y.clamp(-_jumpforce, _terminalVelocity);
        position.y += velocity.y * dt;
      }
      
        void _checkVerticalCollisions() {
          for(final block in collisionBlocks) { 
            if (block.isPlatform) {
             if (checkCollision(this, block)) {
              if(velocity.y > 0){
                  velocity.y = 0;
                  position.y = block.y - width;
                  isOnGround = true;
                  break;
             }
             }

            } else {
              if(checkCollision(this, block)){
                if(velocity.y > 0){
                  velocity.y = 0;
                  position.y = block.y - width;
                  isOnGround = true;
                  break;
                }
                if(velocity.y <0) {
                  velocity.y = 0;
                  position.y = block.y + block.height ;
                }
              }
            }
          }
        }
        
          
  }
  
  
  
  
   

