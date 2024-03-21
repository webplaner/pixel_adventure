import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/parallax.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;
  BackgroundTile({
    this.color = 'Gray',
    position,
    // size,
  }) : super(
          position: position,
          // size: size,
        );

  final double scrollSpeed = 0.4;
  final double tileSize = 64;
  late final startPositionY = position.y;

  @override
  Future<void> onLoad() async {
    priority = -10;
    size = Vector2.all(tileSize);
    parallax = await game.loadParallax(
      [ParallaxImageData('Background/$color.png')],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;

    if (position.y > (game.size.y / tileSize).floor() * tileSize) {
      position.y = -tileSize;
    }
    super.update(dt);
  }
}
