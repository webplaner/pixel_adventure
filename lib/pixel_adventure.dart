import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
// import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/leveltiledmap.dart';
import 'package:pixel_adventure/components/player.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  PixelAdventure();

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late final CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    final world = LevelTilledmap(player: player, levelName: 'Level-01');
    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.priority = 1;

    addAll([
      cam,
      world,
    ]);

    addJoystick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateJoystick();
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      knobRadius: 36,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.palyerdirection = PlayerDirection.left;
        // player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        // player.horizontalMovement = 1;
        player.palyerdirection = PlayerDirection.right;
        break;
      default:
        player.palyerdirection = PlayerDirection.none;
        // player.horizontalMovement = 0;
        break;
    }
  }
}
