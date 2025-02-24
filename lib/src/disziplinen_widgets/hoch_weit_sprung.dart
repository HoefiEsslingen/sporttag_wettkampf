import 'package:flutter/material.dart';
import 'package:sporttag/src/hilfs_widgets/rueck_sprung_button.dart';

import '../hilfs_widgets/meine_appbar.dart';

// Klasse für den Wettkanmpf: Hoch-Weitsprung
class Weitsprung extends StatefulWidget {
  const Weitsprung({super.key});

// final List<Kind> riegenKinder;
//  final String disziplin;

//  const Hochsprung({super.key, required this.riegenKinder ,required this.disziplin});

  /// Aktivität vorbereiten
  @override
  WeitsprungState createState() => WeitsprungState();
}

class WeitsprungState extends State<Weitsprung> {
  late String stationsName; // Variable für die zugewiesene Ausgabe

  @override
  void initState() {
    super.initState();
    // widget.toString() der Variable zuweisen
    stationsName = widget.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeineAppBar(
        titel: 'Hoch-$stationsName',
        stationsName: 'Hoch-$stationsName',
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Details zu Hoch-$stationsName',
              style: const TextStyle(fontSize: 24),
            ),
            ZurueckButton(label: 'Zurück zur Disziplinenauswahl'),
          ],
        ),
      ),
    );
  }
}
