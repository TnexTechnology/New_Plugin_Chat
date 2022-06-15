import 'dart:async';
import './room_model.dart';

class ChatStreamController {
  List<RoomModel>? rooms;
  StreamController counterController = StreamController<List<RoomModel>>();
  Stream get counterStream => counterController.stream;

  void increment(List<RoomModel> newRooms) {
    rooms = newRooms;
    counterController.sink.add(rooms);
  }

  void dispose() {
    counterController.close();
  }
}