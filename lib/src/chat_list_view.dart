import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_loader/screen_loader.dart';

import '../tnexchat.dart';
export './floating_circle_button.dart';
import './room_model.dart';
import './chat_list_item.dart';
import './channel_manager.dart';
import 'dart:convert';

enum SelectMode { normal, share }

class ChatList extends StatefulWidget {

  final Function(String roomId)? didTapRoom;

  const ChatList({this.didTapRoom, Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> with ScreenLoader {
  bool get searchMode => searchController.text?.isNotEmpty ?? false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? coolDown;
  bool loadingPublicRooms = false;
  List<RoomModel> rooms = [];
  final ScrollController _scrollController = ScrollController();
  Future<void> waitForFirstSync(BuildContext context) async {
    // var client = Matrix.of(context).client;
    // if (client.prevBatch?.isEmpty ?? true) {
    //   await client.onFirstSync.stream.first;
    // }
    // return true;
  }

  bool _scrolledToTop = true;
  static bool _firstTime = true;
  loader() {
    // here any widget would do
    return AlertDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Container(
          width: 1,
          height: 1,
        ),
        content: Container(
          width: 100,
          height: 100,

        ));
  }

  @override
  void initState() {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels > 0 && _scrolledToTop) {
        setState(() => _scrolledToTop = false);
      } else if (_scrollController.position.pixels == 0 && !_scrolledToTop) {
        setState(() => _scrolledToTop = true);
      }
    });
    searchController.addListener(() {
      coolDown?.cancel();
      if (searchController.text.isEmpty) {
        setState(() {
          loadingPublicRooms = false;
        });
        return;
      }
    });
    super.initState();
    getListRoom();
    if (_firstTime) waitingInitFirstTime();
  }

  void getListRoom() async {
    final roomsNative = await ChatIOSNative.instance.getRooms();
    List<RoomModel> roomModels = [];
    for (final room in roomsNative) {
      final roomString = json.encode(room);
      final roomDic = json.decode(roomString);
      final roomModel = RoomModel(
          id: roomDic["id"],
          displayname: roomDic["displayname"],
          unreadCount: 0,
          lastMessage: roomDic["lastMessage"],
          timeCreated: roomDic["timeCreated"],
          avatarUrl: roomDic["avatarUrl"]
      );
      roomModels.add(roomModel);
    }
    setState(() {
      rooms = roomModels;
    });

  }

  @override
  Widget screen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat list'),
      ),
      backgroundColor: Color(0xFF011830),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            print("fsdfsdfd");
          },
        ),
      body: ListView.separated(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          itemCount: rooms.length,
          // The list items
          itemBuilder: (context, index) {
            return ChatListItem(rooms[index], didTapRoom: widget.didTapRoom);
          },
          // The separators
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 8,
            );
          }),
    );

  }

  waitingInitFirstTime () async {
    startLoading();
    Future.delayed(Duration(seconds: 3));
    _firstTime = false;
    stopLoading();
  }

  StreamSubscription? _intentDataStreamSubscription;

  StreamSubscription? _intentFileStreamSubscription;

  void _processIncomingSharedText(String text) {

  }

  void _drawerTapAction(Widget view) {
    //Navigator.of(context).pop();

  }

  void _setStatus(BuildContext context) async {

  }

  Widget searchBar() {
    return Container(
      child: Row(
          children: <Widget>[
            Expanded(child: TextField(
              autocorrect: false,
              controller: searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                if (value.length > 0) setState(() {

                });
              },
              style: TextStyle(
                  color: Colors.white,
                  ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets
                    .all(9),
                filled: true,
                fillColor: Colors.cyan,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF14C8FA), width: 1.5),
                    borderRadius: BorderRadius.circular(8)
                ),
                hintText: 'Tìm kiếm bằng từ khóa' /*L10n
                                                      .of(context)
                                                      .searchForAChat*/,
                prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.youtube_searched_for,
                        color: Colors.white)
                ),
                suffixIcon: searchMode
                    ? IconButton(
                  icon: Icon(Icons.backspace,
                      color: Colors.white),
                  onPressed: () =>
                      setState(() {
                        searchController
                            .clear();
                        _searchFocusNode
                            .unfocus();
                      }),
                )
                    : null,
              ),
            ),
            )
          ])
    );
  }
}

