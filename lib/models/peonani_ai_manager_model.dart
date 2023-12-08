class Message {
  late final String role;
  late final String content;

  Message({required this.role, required this.content});

  Message.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['role'] = role;
    data['content'] = content;
    return data;
  }

  Map<String, String> toMap() {
    return {'role': role, 'content': content};
  }

  Message copyWith({String? role, String? content}) {
    return Message(role: role ?? this.role, content: content ?? this.content);
  }
}

class ChatCompletionModel {
  late final String model;
  late final List<Message> messages;
  late final bool stream;

  ChatCompletionModel({
    required this.model,
    required this.messages,
    required this.stream,
  });

  ChatCompletionModel.fromJson(Map<String, dynamic> json) {
    model = json['model'];
    messages =
        List.from(json['messages']).map((e) => Message.fromJson(e)).toList();
    stream = json['stream'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['model'] = model;
    data['messages'] = messages.map((e) => e.toJson()).toList();
    data['stream'] = stream;

    return data;
  }
}

class PeonaniAiManagerPrevChat {
  late int totalPages;
  late int totalElements;
  late List<ChatItem> chatContent;

  PeonaniAiManagerPrevChat({
    required this.totalPages,
    required this.totalElements,
    required this.chatContent,
  });
}

class ChatItem {
  late String id;
  late String content;
  late String created;
  late String nickname;
  late String roomId;
  late String? writerName;
  late int writerId;
  late List<dynamic> imageUrls;
  late List<dynamic> relatedUrls;

  ChatItem({
    required this.id,
    required this.content,
    required this.created,
    required this.nickname,
    required this.roomId,
    required this.writerName,
    required this.imageUrls,
    required this.relatedUrls,
  });

  ChatItem.fromMap(Map<String, dynamic>? map) {
    id = map?["id"] ?? "";
    content = map?["content"] ?? "";
    created = map?["created"] ?? "";
    nickname = map?["nickname"] ?? "";
    roomId = map?["roomId"] ?? "";
    writerName = map?["writerName"] ?? "";
    content = map?["content"] ?? "";
    writerId = map?["writerId"] ?? 0;
    imageUrls = map?["imageUrls"] ?? [];
    relatedUrls = map?["relatedUrls"] ?? [];
  }
}

class RelationUrl {
  late final String description;
  late final String url;

  RelationUrl({
    required this.description,
    required this.url,
  });
}

enum ChatItemType { intro, current, stream }
