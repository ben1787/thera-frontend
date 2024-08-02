enum MessageType {
  type0, // from server
  type1, // user to AI
  type2, // AI to user
  type3, // user to user
}

extension MessageTypeExtension on MessageType {
  String description() {
    switch (this) {
      case MessageType.type1:
        return '1';
      case MessageType.type2:
        return '2';
      case MessageType.type3:
        return '3';
      default:
        return '0';
    }
  }
}

class ChatMessage {
  // final String id;
  final String phone;
  final String msg;
  final MessageType type;

  ChatMessage({
    // required this.id,
    required this.phone,
    required this.msg,
    required this.type,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      // id: json['id'],
      phone: json['phone'] as String? ?? 'Unknown',
      msg: json['msg'] as String? ?? '',
      type: MessageType.values[int.parse(json['type'] as String)],
    );
  }
  
  @override
  String toString() {
    return 'ChatMessage{phone: $phone, msg: $msg, type: $type}';
  }
}