import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/collisionblock.dart';
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

    // final spawnPointsLayer =
    //     levetilemap.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    // if (spawnPointsLayer != null) {
    //   for (final spawnPoint in spawnPointsLayer.objects) {
    //     switch (spawnPoint.class_) {
    //       case 'Player':
    //         player.position = Vector2(spawnPoint.x, spawnPoint.y);
    //         add(player);
    //         break;

    //       default:
    //         break;
    //     }
    //   }
    // }

    addSpawnObjects();
    addCollisions();

    return super.onLoad();
  }

  void addCollisions() {
    final collisionsLayer =
        levetilemap.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            player.collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            player.collisionBlocks.add(block);
            add(block);
        }
      }
    }
    // player.collisionBlocks = collisionBlocks;
  }
  
  void addSpawnObjects() {
    final spawnPointsLayer =
        levetilemap.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;

          default:
            break;
        }
      }
    }  
  }
}
