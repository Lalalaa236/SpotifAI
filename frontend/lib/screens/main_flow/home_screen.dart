import 'package:flutter/material.dart';

// Widget imports
import '../../components/header_footer/header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Header(),
      ),
      body: Center(child: Text('Home Screen')),
    );
  }
}
