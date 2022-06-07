
class RoomModel {
  final String id;
  final String? displayname;
  final int unreadCount;
  final String lastMessage;
  final int? timeCreated;
  final String? avatarUrl;
  RoomModel({required this.id, this.displayname, this.unreadCount = 0, this.lastMessage = "", this.timeCreated, this.avatarUrl});

}