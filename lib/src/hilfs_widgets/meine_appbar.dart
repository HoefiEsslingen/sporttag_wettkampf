import 'package:flutter/material.dart';

import 'hilfe_button.dart';

class MeineAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titel;
  final String? stationsName;

  const MeineAppBar({super.key, required this.titel, this.stationsName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          titel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: stationsName != null
          ? [
              HelpIconButton(stationsName: stationsName!), // Action nur, wenn stationsName != null
            ]
          : null, // Keine Actions, wenn stationsName null ist
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Standardhöhe der AppBar
}
