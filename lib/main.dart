import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_simple_app/apis/peonani_ai_manager_api.dart';
import 'package:flutter_simple_app/components/peonani_manager_message.dart';
import 'package:flutter_simple_app/components/related_image_box.dart';
import 'package:flutter_simple_app/components/related_question_box.dart';
import 'package:flutter_simple_app/components/related_url_box.dart';
import 'package:flutter_simple_app/models/peonani_ai_manager_model.dart';
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

  final String token =
      'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJpanl6QTRFUmgxUU9aM24xeDRHd2ZpdUpHUVZBZVVJcGJpbUJwSTVzY0R3OUVVbmhtL1ozaHdkZ0dReEJJRkRlOGlQd01uS3Z1eUQyWkMzbmlwK1QxSGROYWVJTXliK21JOXJKOGc2VE9XZkwxdDZ6VEJjSXpYOW83Z29zZVZ1MXB0dnVvUnZuOUU5RTIzMTQ4L1VuTmVPNllDMXAxMVJCNDFHVnlueDJGNWN2SDVueGoxTGdOc1NHaGZVZ21ySFdNWFNYQ3QrUC9UTzFmd0RkQVgyVi9lWlZZYVpYOGFnRHVsTjRyRnVkang1akxlY1BzZFRMVEFsYm5tR2dMck5xd2dZdDhTNlErY2VQRis1ZXRUMkt5ZWc0VjdFRVByVFJrUG52MDVPSjRGekVSWHd4SFE4YUZDUm5qWGhEWkt5UGtkMFhBbUhVWTkzYzRnMFpkdmZyQm9Pb0pLVVFRN3plN0laamNUYUplcVA2aHZkZWRZaVV0RnJCVzlIakpqam9BRVVDTUVVcGNsRlJuZC9oai9EWkJEdy9MS1Q3VTh6NDVEZ3RDV2FvQzFVaXZWd0todTBKRUJ5aW5XYUM3d29JbFhLbjA0NnhWcEg1NTdvZ1B3ZjExeHczSU9LL1o3QUdjWnVsdUpGaEpIRDhzRVFuS0tIS2tKNFltQ3BVTWlzM0xJRmFuZjJuQUM5QkNaYmJFb0daejdSOFJMUDd4a0FYNUJpR3Zmd20wVlJFakh0S0ovVytTSVlxbWxDbG51Rndad1VSbE9SWXRUVEkvZmVIczNrbU9LWWFDVGNqWVdSRFdQVEFzeG1GT2ZOb0JrYUhUWmJhaGkwaGV0ZzJ1V0dQOUNIRHR0M0pCeVJLczMyS3BDL2FGOE9MSjkrK1Y1TTg1VUtrNmJiSUNHdz0iLCJpYXQiOjE3MDE1NjMzMjIsImV4cCI6MTc2NDYzNTMyMn0.i0ny9xne7Pvgqqas6hYpkli2Caf4GWX24GWlsGG-_xUMQdjQa0RJp6OmSVx5nhVpdkmlXa99key7g2PSBIuWdw';
  List<ChatItem> chatItemList = [];
  int requestSize = 10;
  int currentPage = 0;
  List<dynamic> relatedQuestionList = [];
  bool isLoading = false;
  bool isProgressAnswer = false;
  bool isConnectError = false;
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
          int lastChatLength;

          // 맨 위에 도달했을 때 실행할 코드
          setState(() {
            isLoading = true;
          });
          isTopReached = true;

          PeonaniAiManagerdApi.getPrevChatList(
                  token: token, size: requestSize, page: currentPage + 1)
              .then((prevChat) => {
                    lastChatLength = chatItemList.length,
                    isTopReached = false,
                    setState(() {
                      isLoading = false;
                      currentPage = currentPage + 1;
                      final newChatList = [
                        ...chatItemList,
                        ...?prevChat?.chatContent.toList(),
                      ];

                      sortChatList(newChatList);
                      chatItemList = newChatList;
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
                isLoading = false;
                final newChatList = (prevChat?.chatContent ?? []).toList();
                sortChatList(newChatList);
                chatItemList = newChatList;
              }),
              WidgetsBinding.instance.addPostFrameCallback((_) {
                isLoading = false;
              })
            });
  }

  void sortChatList(List<ChatItem> chatLst) {
    chatLst.sort((a, b) {
      int dateComparison = b.created.compareTo(a.created);
      if (dateComparison != 0) {
        return dateComparison;
      }
      int nicknameComparison =
          (a.nickname != '' ? 1 : 0) - (b.nickname != '' ? 1 : 0);
      return nicknameComparison;
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
    isProgressAnswer = true;

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
        print(relatedQuestion);
        relatedQuestionList = relatedQuestion;
        break;
      case 'text':
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
        setState(() {
          isProgressAnswer = false;
        });
        break;
      case 'error':
        print('error');
        setState(() {
          isProgressAnswer = false;
          isConnectError = true;
        });
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
    });

    channel.add(json.encode(sendData));
  }

  void sendDataByRelatedQuestion(String question) {
    sendData(question);
    setState(() {
      relatedQuestionList = [];
    });
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
              if (isLoading)
                const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 15),
                    child: CircularProgressIndicator()),
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

                    final relatedUrls =
                        chatItem.relatedUrls.where((relatedUrl) {
                      return relatedUrl['description'] != '' ||
                          relatedUrl['url'] != '';
                    }).toList();

                    final imageUrls = chatItem.imageUrls.where((imgUrl) {
                      return imgUrl.isNotEmpty;
                    }).toList();

                    return Container(
                      padding: EdgeInsets.only(
                          left: 14,
                          right: isCustomerQuestion ? 20 : 40,
                          top: 10,
                          bottom: 10),
                      child: Column(children: <Widget>[
                        PeonaniManagerMessage(
                            isCustomerQuestion: isCustomerQuestion,
                            content: chatItem.content),
                        if (!isCustomerQuestion && relatedUrls.isNotEmpty)
                          RelatedUrlBox(relatedUrls: relatedUrls),
                        if (!isCustomerQuestion && imageUrls.isNotEmpty)
                          RelatedImageBox(imageUrls: imageUrls),
                        if (index == 0 &&
                            !isProgressAnswer &&
                            relatedQuestionList.isNotEmpty)
                          RelatedQuestionBox(
                              relatedQuestionList: relatedQuestionList,
                              sendDataByRelatedQuestion:
                                  sendDataByRelatedQuestion)
                      ]),
                    );
                  },
                ),
              ),
              if (isConnectError)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                        text: '[알림]',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent)),
                    TextSpan(
                        text:
                            '서버와의 연결이 원활하지 않습니다. 잠시 후에 재시도하거나 네트워크 연결 상태를 확인해주세요.'),
                  ])),
                ),
              SizedBox(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color:
                                    const Color.fromRGBO(145, 158, 171, 0.3))),
                        child: TextField(
                          controller: messageTextController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '궁금하신 내용을 입력하세요.',
                          ),
                        ),
                      ),
                    ),
                    isProgressAnswer
                        ? const SizedBox(
                            width: 50,
                            height: 50,
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child:
                                    CircularProgressIndicator(strokeWidth: 3)),
                          )
                        : IconButton(
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: const Alignment(1.0, 0.7),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 1.8,
          onPressed: () {
            itemScrollController.jumpTo(index: 0, alignment: 0);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: const Icon(
            Icons.arrow_drop_down,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
