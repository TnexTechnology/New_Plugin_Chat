import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

class RoomAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Function? onTap;
  static const double defaultSize = 44;

  const RoomAvatar({
    this.avatarUrl,
    this.name,
    this.backgroundColor,
    this.size = defaultSize,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fallbackLetters = '@';
    if ((name?.length ?? 0) >= 2) {
      fallbackLetters = name!.substring(0, 2);
    } else if ((name?.length ?? 0) == 1) {
      fallbackLetters = name!;
    }
    final noPic = avatarUrl == null || avatarUrl == "";
    return InkWell(
      child: CircleAvatar(
        radius: size / 2,
        backgroundImage: !noPic
            ?
        AdvancedNetworkImage(
          avatarUrl!,
          useDiskCache: false/*!kIsWeb*/,
        )
            : null,
        backgroundColor: noPic
            ? Colors.yellow : Colors.blue,
        child: noPic
            ? Text(fallbackLetters, style: TextStyle(color: Colors.white), maxLines: 1,)
            : null,
      ),
    );
  }
}