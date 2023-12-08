import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PeonaniProgressIndicator extends StatelessWidget {
  const PeonaniProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PlatformWidget(
        material: (_, __) => const CircularProgressIndicator(),
        cupertino: (_, __) => const CupertinoActivityIndicator(),
      ),
    );
  }
}
