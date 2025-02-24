import 'package:flutter/material.dart';
import 'package:sporttag/src/hilfs_widgets/meine_appbar.dart';
import 'package:sporttag/src/hilfs_widgets/rueck_sprung_button.dart';


class Lauf extends StatefulWidget {
  final int riegenNummer;

  const Lauf({super.key, required this.riegenNummer});

  /// Aktivität vorbereiten
  @override
  LaufState createState() => LaufState();
}

class LaufState extends State<Lauf> {
  int get riegenNummer => widget.riegenNummer;
  String get stationsName => widget.toString();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeineAppBar(
        titel: '30 sec $stationsName',
        stationsName: '30sec-$stationsName',
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Details zu 30 sec $stationsName',
              style: const TextStyle(fontSize: 24),
            ),
            ZurueckButton(label: 'Zurueck zur Disziplinwahl'),
          ],
        ),
      ),
    );
  }
}
