import 'package:flutter/material.dart';

import '../hilfs_widgets/meine_appbar.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';

class Stabfliegen extends StatefulWidget {
  const Stabfliegen({super.key});

// final List<Kind> riegenKinder;

//  const Stabfliegen({super.key, required this.riegenKinder});

  /// Aktivität vorbereiten
  @override
  StabfliegenState createState() => StabfliegenState();
}

class StabfliegenState extends State<Stabfliegen> {
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
