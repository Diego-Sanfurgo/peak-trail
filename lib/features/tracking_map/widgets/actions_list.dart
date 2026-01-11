import 'package:flutter/material.dart';

class ActionsListWidget extends StatelessWidget {
  const ActionsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ListItem(Icons.directions_run, "Actividad"),
        _ListItem(Icons.share_location, "Compartir en vivo"),
        _ListItem(Icons.terrain, "Condiciones de la ruta"),
        _ListItem(Icons.add_road, "Añadir ruta"),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(text),
      onTap: () {},
    );
  }
}
