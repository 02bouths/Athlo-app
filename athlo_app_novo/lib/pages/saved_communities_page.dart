import 'package:flutter/material.dart';

class SavedCommunitiesPage extends StatelessWidget {
  const SavedCommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Minhas Comunidades Salvas',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }
}
