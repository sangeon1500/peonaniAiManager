import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RelatedUrlBox extends StatelessWidget {
  const RelatedUrlBox({Key? key, required this.relatedUrls}) : super(key: key);
  final List<dynamic> relatedUrls;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 50, // 높이를 적절하게 조정
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // 가로 스크롤 설정
            shrinkWrap: true,
            itemCount: relatedUrls.length,
            itemBuilder: (_, int index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: const Color.fromRGBO(32, 101, 209, 1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 4), // 항목 사이 간격 추가
                margin: const EdgeInsets.only(top: 10),
                child: TextButton(
                  child: Text(
                    '${relatedUrls[index]['description']} : ${relatedUrls[index]['url']}',
                    style:
                        const TextStyle(color: Color.fromRGBO(32, 101, 209, 1)),
                  ),
                  onPressed: () async {
                    final url = Uri.parse(relatedUrls[index]['url']);
                    if (await canLaunchUrl(url)) {
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
