import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).canvasColor,
            statusBarIconBrightness: Brightness.light),
        backgroundColor: Theme.of(context).canvasColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text('Coming Soon ...'),
      ),
    );
  }
}
