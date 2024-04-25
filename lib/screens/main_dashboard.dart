import 'package:flutter/material.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Dashboard"),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
      ),
    );
  }
}
