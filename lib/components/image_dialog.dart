import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ImageDialog extends StatelessWidget {
  const ImageDialog({Key? key, required this.image}) : super(key: key);
  final Image image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(
                5.0,
              ),
              child: Container(
                decoration: const BoxDecoration(),
                child: image,
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: 1,
            child: Align(
              alignment: Alignment.topRight,
              child: PlatformWidgetBuilder(
                material: (_, child, __) => Material(
                  color: Colors.transparent,
                  child: child,
                ),
                cupertino: (_, child, __) => child,
                child: PlatformIconButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  icon: const Icon(
                    Icons.close,
                    size: 35.0,
                    color: Colors.black,
                  ),
                  material: (_, __) => MaterialIconButtonData(
                    splashRadius: 20.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
