import 'package:flutter/material.dart';

import '../hilfs_widgets/meine_appbar.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';

class Druckwurf extends StatefulWidget {
  const Druckwurf({super.key});

// final List<Kind> riegenKinder;

//  const Stossen({super.key, required this.riegenKinder});

  /// Aktivität vorbereiten
  @override
  DruckwurfState createState() => DruckwurfState();
}

class DruckwurfState extends State<Druckwurf> {
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
        titel: stationsName, stationsName: stationsName,),
      body: Center(
        child: 
        Column(children: [
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
