import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class LevelTilledmap extends World {
  final String levelName;
  final Player player;

  LevelTilledmap({
    required this.levelName,
    required this.player,
  });

  late TiledComponent levetilemap;
  late JoystickComponent joystick;

  @override
  FutureOr<void> onLoad() async {
    levetilemap = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(levetilemap);

    final spawnPointsLayer =
        levetilemap.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          // player = Player(
          //     character: 'Mask Dude',
          //     position: Vector2(spawnPoint.x, spawnPoint.y));
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;

        default:
          break;
      }
    }

    return super.onLoad();
  }
}
