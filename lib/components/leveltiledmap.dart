import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/player.dart';

class LevelTilledmap extends World {
  final String levelName;

  LevelTilledmap({
    required this.levelName,
  });

  late TiledComponent level;
  late Player player;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          add(player = Player(
              character: 'Mask Dude',
              position: Vector2(spawnPoint.x, spawnPoint.y)));
          // player.position = Vector2(spawnPoint.x, spawnPoint.y);
          break;

        default:
          break;
      }
    }

    return super.onLoad();
  }
}
