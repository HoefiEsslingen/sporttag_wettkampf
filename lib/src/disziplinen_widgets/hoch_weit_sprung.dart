import 'package:flutter/material.dart';
import '../hilfs_widgets/mein_listen_eintrag.dart';
import '../hilfs_widgets/meine_appbar.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';
import '../klassen/kind_klasse.dart';
import '../tools/kind_repository.dart';
import '../tools/logger.util.dart';

class HochWeitSprung extends StatefulWidget {
  final int riegenNummer;

  const HochWeitSprung({super.key, required this.riegenNummer});

  @override
  HochWeitSprungState createState() => HochWeitSprungState();
}

class HochWeitSprungState extends State<HochWeitSprung> {
  final KindRepository kindRepository = KindRepository();
  final log = getLogger();

  late int riegenNummer;
  List<Kind> riegenKinder = [];
  List<Kind> kinderZurAnzeige = [];
  Map<Kind, int> kinderPunkte = {};
  Map<Kind, int> kinderVersuche = {};
  Set<Kind> ausgeschiedeneKinder = {};
  bool istAusgewertet = false;

  @override
  void initState() {
    super.initState();
    riegenNummer = widget.riegenNummer;
    _loadData();
  }

  Future<void> _loadData() async {
    riegenKinder = await kindRepository.ladeKinderDerRiege(riegenNummer);
    kinderZurAnzeige = List.from(riegenKinder);
    for (var kind in riegenKinder) {
      kinderPunkte[kind] = 0;
      kinderVersuche[kind] = 0;
    }
    setState(() {});
  }

  void _naechsterDurchgang() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Durchgang starten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: kinderZurAnzeige.map((kind) {
            bool istAusgeschieden = ausgeschiedeneKinder.contains(kind);
            bool hatErstenVersuchBestanden = kinderVersuche[kind]! % 2 == 1;
            return ListTile(
              title: Text('${kind.vorname} ${kind.nachname}'),
              subtitle: Text(
                  'Punkte: ${kinderPunkte[kind]}, Versuche: ${kinderVersuche[kind]}'),
              trailing: istAusgeschieden
                  ? Text('Ausgeschieden')
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: hatErstenVersuchBestanden
                              ? null
                              : () {
                                  _verarbeiteVersuch(kind, true);
                                },
                          child: Text('Drüber'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: hatErstenVersuchBestanden
                              ? null
                              : () {
                                  _verarbeiteVersuch(kind, false);
                                },
                          child: Text('Gerissen'),
                        ),
                      ],
                    ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pruefeAusscheiden();
            },
            child: Text('Durchgang beenden'),
          ),
        ],
      ),
    );
  }

  void _verarbeiteVersuch(Kind kind, bool bestanden) {
    setState(() {
      kinderVersuche[kind] = kinderVersuche[kind]! + 1;
      if (bestanden) {
        kinderPunkte[kind] = kinderPunkte[kind]! + 1;
      }
    });
  }

  void _pruefeAusscheiden() {
    setState(() {
      for (var kind in kinderZurAnzeige) {
        if (kinderVersuche[kind]! >= 2 &&
            kinderPunkte[kind]! == 0 &&
            !ausgeschiedeneKinder.contains(kind)) {
          ausgeschiedeneKinder.add(kind);
        }
      }
      if (ausgeschiedeneKinder.length == riegenKinder.length) {
        _auswertungAbschliessen();
      }
    });
  }

  Future<void> _auswertungAbschliessen() async {
    setState(() {
      istAusgewertet = true;
    });
    for (var kind in riegenKinder) {
      kind.erreichtePunkte += kinderPunkte[kind]! * 2;
      await kindRepository.saveKindToDatabase(kind);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeineAppBar(
        titel: 'Hoch-Weit-Sprung',
        stationsName: 'Hoch-Weit-Sprung',
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Jedes Kind hat pro Durchgang zwei Versuche.\nBestandene Versuche erhöhen den Punktestand um 1.\nEs gibt so viele Durchgänge, bis alle Kinder ausgeschieden sind.\nAm Ende werden die Punkte verdoppelt.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 10),
            if (!istAusgewertet)
              ElevatedButton(
                onPressed: _naechsterDurchgang,
                child: Text('Ersten Durchgang starten'),
              ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: kinderZurAnzeige.length,
                itemBuilder: (context, index) {
                  final kind = kinderZurAnzeige[index];
                  final punkte = kinderPunkte[kind];
                  final istAusgeschieden =
                      ausgeschiedeneKinder.contains(kind);
                  return MeinListenEintrag(
                    kind: kind,
                    istAusgewertet: istAusgeschieden,
                    istSelektiert: false,
                    erreichtePunkte: punkte,
                    onSelectionChanged: (Kind kind, bool istSelektiert) {},
                  );
                },
              ),
            ),
            if (istAusgewertet)
              ZurueckButton(label: 'Nächste Disziplin steht an'),
          ],
        ),
      ),
    );
  }
}
/********************************************************************
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
*********************************************************************/