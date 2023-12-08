import 'dart:convert';

import 'package:flutter_simple_app/models/peonani_ai_manager_model.dart';
import 'package:http/http.dart' as http;

class PeonaniAiManagerdApi {
  static Future<PeonaniAiManagerPrevChat?> getPrevChatList({
    required String token,
    required int size,
    required int page,
  }) async {
    Uri uri = Uri.https(
      'api.peonani.com',
      '/d/v1/portal/chat/ai',
      {
        "page": page.toString(),
        "size": size.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
    );
    final statusCode = response.statusCode;

    if (statusCode == 200) {
      final List<dynamic> content =
          jsonDecode(utf8.decode(response.bodyBytes))["result"]["content"];
      final int totalPages =
          jsonDecode(utf8.decode(response.bodyBytes))["result"]["totalPages"] ??
              0;
      final int totalElements =
          jsonDecode(utf8.decode(response.bodyBytes))["result"]
                  ["totalElements"] ??
              0;

      return PeonaniAiManagerPrevChat(
        totalPages: totalPages,
        totalElements: totalElements,
        chatContent:
            content.map<ChatItem>((chat) => ChatItem.fromMap(chat)).toList(),
      );
    }

    return null;
  }
}
