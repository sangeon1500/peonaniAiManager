import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_simple_app/apis/peonani_ai_manager_api.dart';
import 'package:flutter_simple_app/models/peonani_ai_manager_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '펴나니',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  TextEditingController messageTextController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late WebSocket channel;

  static const String _userMessage = 'peonani ai manager';
  String get _currentUserMessage => _userMessage;

  final String token =
      'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJpanl6QTRFUmgxUU9aM24xeDRHd2ZpdUpHUVZBZVVJcGJpbUJwSTVzY0R3OUVVbmhtL1ozaHdkZ0dReEJJRkRlOGlQd01uS3Z1eUQyWkMzbmlwK1QxSGROYWVJTXliK21JOXJKOGc2VE9XZkwxdDZ6VEJjSXpYOW83Z29zZVZ1MXB0dnVvUnZuOUU5RTIzMTQ4L1VuTmVPNllDMXAxMVJCNDFHVnlueDJGNWN2SDVueGoxTGdOc1NHaGZVZ21ySFdNWFNYQ3QrUC9UTzFmd0RkQVgyVi9lWlZZYVpYOGFnRHVsTjRyRnVkang1akxlY1BzZFRMVEFsYm5tR2dMck5xd2dZdDhTNlErY2VQRis1ZXRUMkt5ZWc0VjdFRVByVFJrUG52MDVPSjRGekVSWHd4SFE4YUZDUm5qWGhEWkt5UGtkMFhBbUhVWTkzYzRnMFpkdmZyQm9Pb0pLVVFRN3plN0laamNUYUplcVA2aHZkZWRZaVV0RnJCVzlIakpqam9BRVVDTUVVcGNsRlJuZC9oai9EWkJEdy9MS1Q3VTh6NDVEZ3RDV2FvQzFVaXZWd0todTBKRUJ5aW5XYUM3d29JbFhLbjA0NnhWcEg1NTdvZ1B3ZjExeHczSU9LL1o3QUdjWnVsdUpGaEpIRDhzRVFuS0tIS2tKNFltQ3BVTWlzM0xJRmFuZjJuQUM5QkNaYmJFb0daejdSOFJMUDd4a0FYNUJpR3Zmd20wVlJFakh0S0ovVytTSVlxbWxDbG51Rndad1VSbE9SWXRUVEkvZmVIczNrbU9LWWFDVGNqWVdSRFdQVEFzeG1GT2ZOb0JrYUhUWmJhaGkwaGV0ZzJ1V0dQOUNIRHR0M0pCeVJLczMyS3BDL2FGOE9MSjkrK1Y1TTg1VUtrNmJiSUNHdz0iLCJpYXQiOjE3MDE1NjMzMjIsImV4cCI6MTc2NDYzNTMyMn0.i0ny9xne7Pvgqqas6hYpkli2Caf4GWX24GWlsGG-_xUMQdjQa0RJp6OmSVx5nhVpdkmlXa99key7g2PSBIuWdw';
  List<ChatItem> chatItemList = [];
  int requestSize = 10;
  int currentPage = 0;
  bool isLoading = true;
  bool isTopReached = false;

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(() async {
      final positions = itemPositionsListener.itemPositions.value;

      if (positions.isNotEmpty) {
        if (positions.last.index == chatItemList.length - 1 &&
            positions.last.itemTrailingEdge == 1.0 &&
            !isTopReached) {
          // 맨 위에 도달했을 때 실행할 코드

          isTopReached = true;
          int lastChatLength;

          PeonaniAiManagerdApi.getPrevChatList(
                  token: token, size: requestSize, page: currentPage + 1)
              .then((prevChat) => {
                    lastChatLength = chatItemList.length,
                    isTopReached = false,
                    setState(() {
                      currentPage = currentPage + 1;
                      chatItemList = [
                        ...chatItemList,
                        ...?prevChat?.chatContent.toList(),
                      ];
                    }),
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      itemScrollController.jumpTo(
                          index: lastChatLength, alignment: 1);
                    })
                  });
        }
      }
    });

    connectSocket('wss://api.peonani.com/d/v1/portal/ws', token);

    PeonaniAiManagerdApi.getPrevChatList(
            token: token, size: requestSize, page: currentPage)
        .then((prevChat) => {
              setState(() {
                chatItemList = prevChat?.chatContent.toList() ?? [];
              }),
              WidgetsBinding.instance.addPostFrameCallback((_) {
                isLoading = false;
              })
            });
  }

  Future<void> connectSocket(String url, String token) async {
    channel = await WebSocket.connect(url, headers: {
      'Authorization': 'Bearer $token',
    });

    channel.listen((event) => _handleSocketMessage(event));
  }

  bool checkScrollInBottom() {
    final positions = itemPositionsListener.itemPositions.value;
    return positions.first.index == 0 && positions.first.itemLeadingEdge == 0.0;
  }

  void scrollDown() {
    itemScrollController.scrollTo(
        index: 0, duration: const Duration(milliseconds: 4));
  }

  void _handleSocketMessage(String event) async {
    final data = json.decode(event);
    final type = data['type'];
    final message = data['message'];
    final relatedUrls = data['relatedUrls'];
    final imageUrls = data['imageUrls'];
    final relatedQuestion = data['relatedQuestion'];
    final answerId = data['answerId'];
    final questionId = data['questionId'];

    switch (type) {
      case 'url':
        print('url');
        setState(() {
          chatItemList.first.imageUrls = imageUrls;
          chatItemList.first.relatedUrls = relatedUrls;
        });
        break;
      case 'question':
        print('question');
        setState(() {
          chatItemList.first.relatedUrls = relatedQuestion;
        });
        break;
      case 'text':
        // print('text');

        setState(() {
          chatItemList.first.content += message;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 화면이 빌드된 후 실행될 콜백
          if (checkScrollInBottom()) {
            scrollDown();
          }
        });

        break;
      case 'end':
        print('end');
        break;
    }
  }

  void sendData(String sendMessage) {
    final Map<String, String> sendData = {
      'role': 'user',
      'message': sendMessage
    };

    setState(() {
      chatItemList.insert(
          0,
          ChatItem(
              id: '',
              content: sendMessage,
              created: '',
              nickname: '사용자',
              roomId: '',
              writerName: '사용자',
              imageUrls: [],
              relatedUrls: []));
    });

    setState(() {
      chatItemList.insert(
          0,
          ChatItem(
              id: '',
              content: '',
              created: '',
              nickname: '',
              roomId: '',
              writerName: '',
              imageUrls: [],
              relatedUrls: []));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (checkScrollInBottom()) {
        scrollDown();
      }
      // 화면이 빌드된 후 실행될 콜백
    });

    channel.add(json.encode(sendData));
  }

  @override
  void dispose() {
    messageTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('펴나니 AI 매니저'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    scrollOffsetListener: scrollOffsetListener,
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: chatItemList.length,
                    itemBuilder: (_, int index) {
                      final ChatItem chatItem = chatItemList[index];
                      final bool isCustomerQuestion = chatItem.writerName != '';

                      return Container(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                          alignment: (isCustomerQuestion
                              ? Alignment.topRight
                              : Alignment.topLeft),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (isCustomerQuestion
                                  ? Colors.grey.shade200
                                  : Colors.blue[200]),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              chatItem.content,
                              style: TextStyle(
                                fontSize: 15,
                                color: (isCustomerQuestion
                                    ? Colors.black
                                    : Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all()),
                          child: TextField(
                            controller: messageTextController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '궁금하신 내용을 입력하세요.',
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                          iconSize: 42,
                          onPressed: () async {
                            if (messageTextController.text.isEmpty) {
                              return;
                            }

                            try {
                              sendData(messageTextController.text.trim());
                              messageTextController.clear();
                            } catch (error) {
                              print(error.toString());
                            }
                          },
                          icon: const Icon(Icons.arrow_circle_up)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
