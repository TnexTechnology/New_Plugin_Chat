import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import './channel_manager.dart';
import 'package:flutter/services.dart';


class RoomAvatar extends StatefulWidget {
  final String roomId;
  String? avatarUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Function? onTap;
  static const double defaultSize = 44;

  RoomAvatar({
    this.roomId = "",
    this.avatarUrl,
    this.name,
    this.backgroundColor,
    this.size = defaultSize,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _RoomAvatarState createState() => _RoomAvatarState();
}

class _RoomAvatarState extends State<RoomAvatar> {
  static const _methodChannel =
  const MethodChannel('tnex_chat');
  @override
  void initState() {
    super.initState();
    if (widget.avatarUrl == "") {
      handleMethod();
      ChatIOSNative.instance.getMembersInRoom(widget.roomId);

    }
  }

  void handleMethod() {
    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == "listMember") {
        final userId = call.arguments["avatarUrl"].toString();
        final roomId = call.arguments["roomId"].toString();
        print(widget.roomId);
        if (roomId == widget.roomId) {
          widget.avatarUrl = userId;
          setState(() {
            print(userId);
            widget.avatarUrl = userId;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var fallbackLetters = '@';
    if ((widget.name?.length ?? 0) >= 2) {
      fallbackLetters = widget.name!.substring(0, 2);
    } else if ((widget.name?.length ?? 0) == 1) {
      fallbackLetters = widget.name!;
    }
    final noPic = widget.avatarUrl == null || widget.avatarUrl == "";
    return InkWell(
      child: CircleAvatar(
        radius: widget.size / 2,
        backgroundImage: !noPic
            ?
        AdvancedNetworkImage(
          widget.avatarUrl!,
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