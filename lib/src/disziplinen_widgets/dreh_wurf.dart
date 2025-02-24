import 'package:flutter/material.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';
import '../hilfs_widgets/meine_appbar.dart';

class Drehwurf extends StatefulWidget {
  const Drehwurf({super.key});

// const Schleudern({super.key, required this.disziplin});
//  final String disziplin;

  /// Aktivität vorbereiten
  @override
  DrehwurfState createState() => DrehwurfState();
}

class DrehwurfState extends State<Drehwurf> {
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
      appBar: MeineAppBar(titel: stationsName, stationsName: stationsName),
      body: Center(child:
        Column(
          children: [
            Text(
              'Details zu $stationsName',
              style: const TextStyle(fontSize: 24),
            ),
            ZurueckButton(label: 'Zurueck zur Disziplinwahl'),
          ],
        ),
       ),
    );
  }
}
