import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collisionblock.dart';
import 'package:pixel_adventure/components/customhitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/components/funcs.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
}

enum PlayerDirection {
  left,
  right,
  none,
}

// enum PlayerFacing {
//   left,
//   right,
// }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  final String character;
  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(position: position);

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  List<CollisionBlock> collisionBlocks = [];

  // Vector2 startingPosition = Vector2.zero();
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  late bool isLeftKeyPressed = false;
  late bool isRightKeyPressed = false;

  late double horizontalMovement = 0;
  late Vector2 velocity = Vector2.zero();

  final double moveSpeed = 100.0;
  final double gravity = 9.8;
  final double jumpForce = 280;
  final double terminalVelocity = 300;

  bool isOnGround = false;
  bool hasJumped = false;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    loadAllAnimaions();

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    updatePlayerState();
    updatePlayerMovement(dt);
    checkHorizontalCollisions();
    applyGravity(dt);
    checkVerticalCollisions();

    // accumulatedTime += dt;
    // while (accumulatedTime >= fixedDeltaTime) {
    //   if (!gotHit && !reachedCheckpoint) {
    //     _updatePlayerState();
    //     _updatePlayerMovement(fixedDeltaTime);
    //     _checkHorizontalCollisions();
    //     _applyGravity(fixedDeltaTime);
    //     _checkVerticalCollisions();
    //   }
    //   accumulatedTime -= fixedDeltaTime;
    // }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  void loadAllAnimaions() {
    idleAnimation = spriteAnimation('Idle', 11);
    runningAnimation = spriteAnimation('Run', 12);
    jumpingAnimation = spriteAnimation('Jump', 1);
    fallingAnimation = spriteAnimation('Fall', 1);
    hitAnimation = spriteAnimation('Hit', 7)..loop = false;
    appearingAnimation = specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = specialSpriteAnimation('Desappearing', 7);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void updatePlayerMovement(double dt) {
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    if (hasJumped && isOnGround) {
      playerJump(dt);
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    // isLeftKeyPressed = false;
    // isRightKeyPressed = false;
  }

  void playerJump(double dt) {
    if (game.playSounds) FlameAudio.play('jump.wav', volume: game.soundVolume);
    velocity.y -= jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void updatePlayerState() {
    if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }

    PlayerState playerState = PlayerState.idle;

    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    } else {
      playerState = PlayerState.idle;
    }

    if (velocity.y > 0) {
      playerState = PlayerState.falling;
    } else if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }

  void checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
    position.y += velocity.y * dt;
  }
}
