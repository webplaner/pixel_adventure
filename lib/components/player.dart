import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collisionblock.dart';
import 'package:pixel_adventure/components/customhitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

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

enum PlayerFacing {
  left,
  right,
}

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

  double horizontalMovement = 0;
  PlayerDirection palyerdirection = PlayerDirection.none;
  PlayerFacing playerFacing = PlayerFacing.right;

  double moveSpeed = 100.0;
  Vector2 velocity = Vector2.zero();
  // bool isFacingRight = true;
  // bool isFacingLeft = false;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    loadAllAnimaions();

    // startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    updatePlayerMovement(dt);
    // updatePlayerState();

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
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    // if (isLeftKeyPressed && isRightKeyPressed) {
    //   palyerdirection = PlayerDirection.none;
    // } else
    if (isLeftKeyPressed) {
      // palyerdirection = PlayerDirection.left;
      horizontalMovement = -1;
    } else if (isRightKeyPressed) {
      // palyerdirection = PlayerDirection.right;
      horizontalMovement = 1;
    } else {
      horizontalMovement = 0;
      // palyerdirection = PlayerDirection.none;
    }

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
    velocity.x = horizontalMovement * moveSpeed;
    updatePlayerState();

    position.x += velocity.x * dt;
  }

  void updatePlayerState() {
    if (velocity.x > 0) {
      if (playerFacing == PlayerFacing.left) {
        flipHorizontallyAroundCenter();
      }
      playerFacing = PlayerFacing.right;
    } else if (velocity.x < 0) {
      if (playerFacing == PlayerFacing.right) {
        flipHorizontallyAroundCenter();
      }
      playerFacing = PlayerFacing.left;
    }

    if (velocity.y > 0) {
      current = PlayerState.falling;
    } else if (velocity.y < 0) {
      current = PlayerState.jumping;
    } else if (velocity.x > 0 || velocity.x < 0) {
      current = PlayerState.running;
    } else {
      current = PlayerState.idle;
    }
  }
}
