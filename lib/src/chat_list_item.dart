import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../tnexchat.dart';
export './floating_circle_button.dart';
import './room_model.dart';
import './avatar_room.dart';
import './channel_manager.dart';
import 'package:intl/intl.dart';

class ChatListItem extends StatelessWidget {
  final RoomModel room;
  final bool activeChat;
  final Function? onForget;
  final Function(String roomId)? didTapRoom;
  const ChatListItem(this.room, {this.activeChat = false, this.onForget, this.didTapRoom});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Slidable(
            key: Key(room.id),
            actionExtentRatio: 0.15,
            secondaryActions: <Widget>[
              IconSlideAction(
                // caption: L10n
                //     .of(context)
                //     .delete,
                color: Colors.transparent,
                iconWidget: Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child:
                    Icon(Icons.add,
                        color: Colors.white)),
                onTap: () => {
                  print("tapppp icon")
                },
              ),
              ],
            actionPane: SlidableDrawerActionPane(),
            child: Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFF1A2F45),
                  border: null),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                    leading: RoomAvatar(
                      roomId: room.id,
                      name: room.displayname,
                      avatarUrl: room.avatarUrl,
                    ),
                    title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.displayname ?? "",
                              style: TextStyle(
                                  color: Color(0xFFF7F8F9),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                          SizedBox(width: 4),
                          room.unreadCount > 0 ?
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            height: 20,
                            decoration: BoxDecoration(
                              color: Color(0xFFFF2D18),
                              shape: BoxShape.circle,
                            ),
                          ) : SizedBox()
                        ]
                    ),
                    subtitle: Row(children: [
                    Expanded(
                        child: Column(children: [
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  room.lastMessage,
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: room.unreadCount > 0
                                        ? Colors.white
                                        : Colors.white60,
                                    fontWeight: room.unreadCount > 0 ? FontWeight.w500: FontWeight.w300,
                                    fontSize: 16
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(children: [
                            Text(
                              DateFormat('dd/mm - kk:mm').format(DateTime.fromMillisecondsSinceEpoch((room.timeCreated ?? 0)*1000)),
                              // DateTime.fromMillisecondsSinceEpoch(room.timeCreated ?? 0 * 1000).localizedTimeShort(context),
                              style: const TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12
                              ),
                            ),
                          ])
                        ])),
                    Container(
                      height: 20,
                    )
                  ]),
                    onTap: () {
                      ChatIOSNative.instance.gotoChatDetail(room.id);
                    }
                )
              ),
            )
        )

    );
  }
}

extension DateTimeExtension on DateTime {
  String localizedTimeShort(BuildContext context) {
    var now = DateTime.now();

    var sameYear = now.year == year;

    var sameDay = sameYear && now.month == month && now.day == day;

    var sameWeek = sameYear &&
        !sameDay &&
        now.millisecondsSinceEpoch - millisecondsSinceEpoch <
            1000 * 60 * 60 * 24 * 7;
    if (sameDay) {
      return localizedTimeOfDay(context);
    } else if (sameWeek) {
      switch (weekday) {
        case 1:
          return 'Thứ 2';//L10n.of(context).monday;
        case 2:
          return 'Thứ 3';//L10n.of(context).tuesday;
        case 3:
          return 'Thứ 4';//L10n.of(context).wednesday;
        case 4:
          return 'Thứ 5';//L10n.of(context).thursday;
        case 5:
          return 'Thứ 6';//L10n.of(context).friday;
        case 6:
          return 'Thứ 7';//L10n.of(context).saturday;
        case 7:
          return 'Chủ nhật';//L10n.of(context).sunday;
      }
    } else if (sameYear) {
      return "L10n.of(context)";
    }
    return this.toString();
  }

  String localizedTimeOfDay(BuildContext context) {
    return 'pm';
  }
}