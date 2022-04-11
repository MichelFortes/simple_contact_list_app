import 'package:flutter/material.dart';
import 'package:simple_contact_list_app/style/app_style.dart';

class FullErrorWidget extends StatelessWidget {
  final String text;
  final Function? tryAgain;

  const FullErrorWidget({Key? key, required this.text, this.tryAgain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradientBox,
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 28),
              child: Text(text, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 4),
            Visibility(
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => tryAgain?.call(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
