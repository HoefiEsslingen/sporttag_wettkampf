import 'package:flutter/material.dart';
import '../hilfs_widgets/meine_appbar.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';

class Schlagwurf extends StatefulWidget {
  const Schlagwurf({super.key});

// const Schlagball({super.key, required this.disziplin});
//  final String disziplin;


  /// Aktivität vorbereiten
  @override
  SchlagwurfState createState() => SchlagwurfState();
}

class SchlagwurfState extends State<Schlagwurf> {
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
