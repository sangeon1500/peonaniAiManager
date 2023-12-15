import 'package:flutter/material.dart';

class PeonaniManagerMessage extends StatelessWidget {
  const PeonaniManagerMessage(
      {Key? key, required this.isCustomerQuestion, required this.content})
      : super(key: key);
  final bool isCustomerQuestion;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: isCustomerQuestion
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: !isCustomerQuestion
                    ? Border.all(
                        width: 1, color: const Color.fromRGBO(204, 204, 204, 1))
                    : null,
                borderRadius: BorderRadius.circular(20),
                color: (isCustomerQuestion
                    ? const Color.fromRGBO(100, 149, 237, 1)
                    : Colors.white),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  color: (isCustomerQuestion ? Colors.white : Colors.black),
                ),
              ),
            ),
          ),
          if (!isCustomerQuestion)
            Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/icon_copy.png') //로컬 이미지 로딩
                ),
        ]);
  }
}
