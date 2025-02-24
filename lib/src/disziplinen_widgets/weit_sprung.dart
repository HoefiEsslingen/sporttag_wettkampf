import 'package:flutter/material.dart';
import '../hilfs_widgets/meine_appbar.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';

//import '../tools/pdf_modal_inhalt.dart';

class Zonenweitsprung extends StatefulWidget {
  const Zonenweitsprung({super.key});

  /// Aktivität vorbereiten
  @override
  ZonenweitsprungState createState() => ZonenweitsprungState();
}

class ZonenweitsprungState extends State<Zonenweitsprung> {
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
        titel: stationsName,
        stationsName: stationsName,
      ),
      body: Center(
        child: Column(
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
