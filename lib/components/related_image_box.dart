import 'package:flutter/material.dart';
import 'package:flutter_simple_app/utils/dialog.dart';

class RelatedImageBox extends StatelessWidget {
  const RelatedImageBox({Key? key, required this.imageUrls}) : super(key: key);
  final List<dynamic> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 80, // 높이를 적절하게 조정
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // 가로 스크롤 설정
            shrinkWrap: true,
            itemCount: imageUrls.length,
            itemBuilder: (_, int index) {
              return GestureDetector(
                onTap: () {
                  PeonaniDialog.showImage(
                    context: context,
                    image: Image.network(
                      imageUrls[index],
                      fit: BoxFit.contain,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: const Color.fromRGBO(204, 204, 204, 1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 10),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
