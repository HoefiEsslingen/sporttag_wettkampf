import 'package:flutter/material.dart';

import '../hilfs_widgets/mein_listen_eintrag.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';
import '../hilfs_widgets/meine_appbar.dart';
import '../klassen/kind_klasse.dart';
import '../tools/kind_repository.dart';
import '../tools/logger.util.dart';
import '../tools/stationen_repository.dart';
import '../tools/stop_uhr.dart';

class Stadionrunde extends StatefulWidget {
  final int riegenNummer;

  const Stadionrunde({super.key, required this.riegenNummer});

  /// Aktivität vorbereiten
  @override
  StadionrundeState createState() => StadionrundeState();
}

class StadionrundeState extends State<Stadionrunde> {
  late String stationsName; // Variable für die zugewiesene Ausgabe

// Repository-Objekte
  final KindRepository kindRepository = KindRepository();
  final StationenRepository stationenRepository = StationenRepository();

  late int riegenNummer;
  List<Kind> riegenKinder = [];
  List<Kind> selectedKinder = [];
  List<Kind> kinderZurAnzeige = []; // Speichert anzuzeigende Teilnehmer
  Set<Kind> ausgewerteteKinder = {}; // Speichert ausgewertete Teilnehmer
  Map<Kind, int> kinderMitZeiten = {}; // Speichert gestoppte Zeiten

  final log = getLogger();

  @override
  void initState() {
    super.initState();
    // widget.toString() der Variable zuweisen
    stationsName = widget.toString();
    riegenNummer = widget.riegenNummer;
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
    riegenKinder.clear();
    selectedKinder.clear();
    kinderZurAnzeige.clear();
    ausgewerteteKinder.clear();
    kinderMitZeiten.clear();
  }

  Future<void> _loadData() async {
    riegenKinder = await kindRepository.ladeKinderDerRiege(riegenNummer);
    // Liste zur Anzeige aufbereiten -> nicht ausgewertete Kinder oben
    kinderZurAnzeige =
        kindRepository.zurAnzeigeSortieren(riegenKinder, ausgewerteteKinder);
    // Kinder in die selektiert-Liste übernehmen
    for (var kind in riegenKinder) {
      selectedKinder.add(kind);
    }
    setState(() {}); // UI aktualisieren
  }

  Future<void> auswerten(Map<Kind, int> resultate) async {
    log.i(
        'in auswerten -> Ergebniss erstes Kind: ${resultate.values.first.toString()}');
    setState(() {
      kinderMitZeiten.addAll(resultate); // Gestoppte Zeiten hinzufügen
      // Gestoppte Zeiten hinzufügen und Punkte berechnen
      for (var entry in resultate.entries) {
        final kind = entry.key;
        final zeit = entry.value;

        kinderMitZeiten[kind] = zeit; // Zeit speichern
        log.i('in auswerten $zeit für ${kind.nachname}');
        // Punkte werden aufrund der erreichten Zeit berechnet
        final punkte = _werteZeitenAus(zeit); // Punkte berechnen
        // die an dieser Station erreichten Punkte werden gespeichert
        kinderMitZeiten[kind] = punkte;
        kind.erreichtePunkte += punkte; // Punkte zuweisen
      }

      // Teilnehmer als ausgewertet markieren
      ausgewerteteKinder.addAll(resultate.keys);

      // Auswahl nach der Auswertung zurücksetzen
      selectedKinder.clear();

      // Liste zur Anzeige aufbereiten -> nicht ausgewertete Kinder oben
      kinderZurAnzeige =
          kindRepository.zurAnzeigeSortieren(riegenKinder, ausgewerteteKinder);
    });

    // Speichern der ausgewerteten Kinder in der Datenbank
    final zuSpeicherndeKinder = resultate.keys.toList();
    for (var kind in zuSpeicherndeKinder) {
      await kindRepository.saveKindToDatabase(kind);
    }
  }

  int _werteZeitenAus(int zeitInMillis) {
    // Beispielhafte Bewertung basierend auf Zeit
    final seconds = zeitInMillis ~/ 1000;
    // > 3:20 min -> 0 Punkte
    if (seconds > 200) {
      return 0;
      // 2:40 min bis 3:20 min -> 1 Punkte
    } else if (seconds > 160) {
      return 1;
      // 2:00 min bis 2:40 min -> 2 Punkte
    } else if (seconds > 120) {
      return 2;
      // 1:40 min bis 2:00 min -> 3 Punkte
    } else if (seconds > 100) {
      return 3;
      // 1:20 min bis 1:40 min -> 4 Punkte
    } else if (seconds > 80) {
      return 4;
      // < 1:20 min -> 5 Punkte
    } else {
      return 5;
    }
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
          // Alle Kinder der Riege als selektiert anzeigen
          // Wertungslauf -Button anzeigen
          // in Stop-Uhr wechseln
          // Kinder mit Zeit speichern
          Text(
            'Alle Kinder nehmen an der Stadion-Runde teil.\nSolllten Kinder nicht teilnehmen, dann diese bitte abwählen.',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodySmall, // Verwenden des Themes
          ),
          // Abstandshalter
          SizedBox(height: 10),
          // Liste der Kinder in der ausgewählten Riege
          ElevatedButton(
            onPressed: (selectedKinder.isNotEmpty)
                // Wenn selektierte Kinder vorhanden sind, dann den Timer starten
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyStopUhr(
                          teilNehmer: selectedKinder,
                          rufendeStation: stationsName,
                          auswertenDerWerte:
                              auswerten, // Ergebnisse verarbeiten)
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text(
              'Starte Timer mit ausgewählten Namen',
              textAlign: TextAlign.center,
            ),
          ),
          // Liste aller Kinder in der ausgewählten Riege
          // Die Kinder können hier durch einen Klick auf den Namen für die Teilnahme an der nächsten Runde gewählt werden
          Expanded(
            child: ListView.builder(
              itemCount: riegenKinder.length,
              itemBuilder: (context, index) {
                final kind = kinderZurAnzeige[index];
                final zeit = kinderMitZeiten[kind]; // Gestoppte Zeit abrufen
                final istAusgewertet = ausgewerteteKinder.contains(kind);
                log.i(
                    'in ListViewBuilder ${kind.nachname} ist selektiert? -> ${selectedKinder.contains(kind).toString()}');
                final istSelektiert = selectedKinder.contains(kind);
                return MeinListenEintrag(
                  kind: kind,
                  istAusgewertet: istAusgewertet,
                  istSelektiert: istSelektiert,
                  erreichtePunkte: zeit,
                  onSelectionChanged: (Kind kind, bool istSelektiert) {
                    setState(() {
                      if (istSelektiert) {
                        selectedKinder.add(kind); // Hinzufügen, wenn ausgewählt
                      } else {
                        selectedKinder
                            .remove(kind); // Entfernen, wenn abgewählt
                      }
                    });
                  },
                );
              },
            ),
          ),
          if (riegenKinder.length ==
              ausgewerteteKinder.length) // Beenden-Button anzeigen
            ZurueckButton(label: 'Zurück zur Disziplinenauswahl'),
        ],
      )),
    );
  }
}
