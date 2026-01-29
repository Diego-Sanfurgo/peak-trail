import 'package:flutter/material.dart';
import 'package:peak_trail/widgets/animated_search_text.dart';

class MockedSearchBar extends StatelessWidget {
  const MockedSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded),
          const SizedBox(width: 8),
          AnimatedSearchText(),
        ],
      ),
    );
  }
}
