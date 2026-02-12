import 'package:flutter/material.dart';

class FloatingChips extends StatefulWidget {
  const FloatingChips({super.key});

  @override
  State<FloatingChips> createState() => _FloatingChipsState();
}

class _FloatingChipsState extends State<FloatingChips> {
  int? _selectedIndex;

  void _handleSelection(int index, bool selected) {
    if (selected) {
      _selectedIndex = index;
    } else if (_selectedIndex == index) {
      _selectedIndex = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height * 0.05;

    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          spacing: 4,
          children: [
            ChoiceChip(
              shape: StadiumBorder(),
              selected: _selectedIndex == 0,
              avatar: _selectedIndex == 0 ? null : Icon(Icons.volcano_outlined),
              onSelected: (value) => _handleSelection(0, value),
              label: Text("Cerros"),
            ),
            ChoiceChip(
              shape: StadiumBorder(),
              selected: _selectedIndex == 1,
              avatar: _selectedIndex == 1
                  ? null
                  : Icon(Icons.water_drop_outlined),
              onSelected: (value) => _handleSelection(1, value),
              label: Text("Lagos"),
            ),
            ChoiceChip(
              shape: StadiumBorder(),
              selected: _selectedIndex == 2,
              onSelected: (value) => _handleSelection(2, value),
              avatar: _selectedIndex == 2
                  ? null
                  : Icon(Icons.water_drop_outlined),
              label: Text("Cascadas"),
            ),
            ChoiceChip(
              shape: StadiumBorder(),
              selected: _selectedIndex == 3,
              onSelected: (value) => _handleSelection(3, value),
              avatar: _selectedIndex == 3 ? null : Icon(Icons.park_outlined),
              label: Text("Parques"),
            ),
          ],
        ),
      ),
    );
  }
}
