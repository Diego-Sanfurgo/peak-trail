import 'package:flutter/material.dart';

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
          Text(
            'Buscar montañas',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
