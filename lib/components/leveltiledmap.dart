import 'dart:async';

import 'package:flame/components.dart';
// import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/backgroundtile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
// import 'package:flutter/painting.dart';
// import 'package:pixel_adventure/components/backgroundtile.dart';
import 'package:pixel_adventure/components/collisionblock.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class LevelTilledmap extends World with HasGameRef<PixelAdventure> {
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

    scrollingBackground();
    addSpawnObjects();
    addCollisions();

    return super.onLoad();
  }

  void addCollisions() {
    player.collisionBlocks.clear();
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
            player.size.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;

          default:
            break;
        }
      }
    }
  }

  void scrollingBackground() {
    final backgroundLayer = levetilemap.tileMap.getLayer('Background');
    const tileSize = 64;

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      for (double iy = 0; iy < game.size.y / tileSize; iy++) {
        for (double ix = 0; ix < game.size.x / tileSize; ix++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
            position: Vector2(ix * tileSize, iy * tileSize - tileSize),
          );

          add(backgroundTile);
        }
      }
    }
  }
}
