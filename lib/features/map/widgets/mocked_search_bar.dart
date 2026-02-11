import 'package:flutter/material.dart';
import 'package:peak_trail/core/theme/colors.dart';
import 'package:peak_trail/widgets/animated_search_text.dart';

class MockedSearchBar extends StatelessWidget {
  const MockedSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outline),
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
