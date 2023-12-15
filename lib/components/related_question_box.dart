import 'package:flutter/material.dart';

class RelatedQuestionBox extends StatelessWidget {
  const RelatedQuestionBox(
      {Key? key,
      required this.relatedQuestionList,
      required this.sendDataByRelatedQuestion})
      : super(key: key);
  final List<dynamic> relatedQuestionList;
  final Function sendDataByRelatedQuestion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
                spacing: 8.0, // 가로 간격
                runSpacing: 4.0, // 세로 간격
                children: relatedQuestionList.map((question) {
                  return TextButton(
                    style: TextButton.styleFrom(
                      side: const BorderSide(
                        color: Color.fromRGBO(204, 204, 204, 1),
                      ),
                    ),
                    onPressed: () {
                      sendDataByRelatedQuestion(question);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        question,
                        style: const TextStyle(
                          color: Color.fromRGBO(32, 101, 209, 1),
                        ),
                      ),
                    ),
                  );
                }).toList()),
          ),
        ],
      ),
    );
  }
}
