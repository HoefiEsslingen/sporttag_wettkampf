import 'package:flutter/material.dart';
import '../hilfs_widgets/mein_listen_eintrag.dart';
import '../hilfs_widgets/meine_appbar.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';
import '../klassen/kind_klasse.dart';
import '../tools/kind_repository.dart';
import '../tools/logger.util.dart';
import '../tools/stationen_repository.dart';
import '../tools/stop_uhr.dart';

class Sprint extends StatefulWidget {
  final int riegenNummer;

  const Sprint({super.key, required this.riegenNummer});

// const HuetchenSprint({super.key, required this.disziplin});
//  final String disziplin;

  /// Aktivität vorbereiten
  @override
  SprintState createState() => SprintState();
}

class SprintState extends State<Sprint> {
  late String stationsName; // Variable für die zugewiesene Ausgabe

  // Repository-Objekte
  final KindRepository kindRepository = KindRepository();
  final StationenRepository stationenRepository = StationenRepository();
  bool testLauf = true; // Kinder dürfen zuerst ihre Entscheidung testen

  late int riegenNummer;
  List<Kind> riegenKinder = [];
  List<Kind> selectedKinder = [];
  List<Kind> kinderZurAnzeige = []; // Speichert anzuzeigende Teilnehmer
  Set<Kind> ausgewerteteKinder = {}; // Speichert ausgewertete Teilnehmer
  Map<Kind, int> kinderMitZeiten = {}; // Speichert gestoppte Zeiten
  Map<Kind, int> gewaehlteHuetchen =
      {}; // Speichert die gewählte Hütchen-Nummer

  final log = getLogger();

  @override
  initState() {
    super.initState();
    // widget.toString() der Variable zuweisen
    stationsName = widget.toString();
    riegenNummer = widget.riegenNummer;
    _loadData();
  }

  Future<void> _loadData() async {
    riegenKinder = await kindRepository.ladeKinderDerRiege(riegenNummer);
    // Liste zur Anzeige aufbereiten -> nicht ausgewertete Kinder oben
    kinderZurAnzeige =
        kindRepository.zurAnzeigeSortieren(riegenKinder, ausgewerteteKinder);
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
        final punkte = _werteZeitenAus(zeit, kind); // Punkte berechnen
        log.i('in auswerten $zeit für ${kind.nachname}');
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

  int _werteZeitenAus(int zeitInMillis, Kind kind) {
    if (zeitInMillis > 0) {
      return gewaehlteHuetchen[kind] ??
          0; // Wenn 'kind' nicht in der Map enthalten ist, dann 0 zurückgeben
    } else {
      return 0;
    }
  }

  bool alleHuetchenGewaehlt() {
    return selectedKinder.every((kind) => gewaehlteHuetchen[kind] != null);
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
              'Die Kinder führen nach Wahl der Hütchen einen Probedurchgang durch. \nDanach kann die Hütchenwahl geändert werden.\nBitte selektieren Sie die an der nächsten Runde teilnehmenden Kinder,\nwählen Sie die gewünschten Hütchen aus.',
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
                      final laufStatus = testLauf;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyStopUhr(
                            teilNehmer: selectedKinder,
                            alsTimer: true,
                            timerZeit: 10,
                            testLauf: laufStatus,
                            auswertenDerZeiten: !laufStatus
                                ? auswerten
                                : null, // Ergebnisse verarbeiten)
                          ),
                        ),
                      ).then((_) {
                        setState(() {
                          testLauf = !testLauf; // Jetzt toggeln
                        });
                      });
                    }
                  : null,
              child: Text(
                testLauf
                    ? 'Testlauf mit ausgewählten Namen'
                    : 'Wertungslauf mit ausgewählten Namen',
                textAlign: TextAlign.center,
              ),
            ),
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
                  return Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Platzierung der Widgets
                    children: [
                      Expanded(
                        flex: 3, // 3 Teile für den Listeneintrag
                        child: MeinListenEintrag(
                          kind: kind,
                          istAusgewertet: istAusgewertet,
                          istSelektiert: istSelektiert,
                          zeit: zeit,
                          onSelectionChanged: (Kind kind, bool istSelektiert) {
                            setState(() {
                              if (istSelektiert) {
                                selectedKinder.add(kind);
                                gewaehlteHuetchen.putIfAbsent(kind, () => 1);
                              } else {
                                selectedKinder.remove(kind);
                                gewaehlteHuetchen.remove(kind);
                              }
                            });
                          },
                        ),
                      ),
                      if (istSelektiert &&
                          !istAusgewertet) // Dropdown nur anzeigen, wenn Kind selektiert und nicht ausgewertet
                        Expanded(
                          flex: 1, // 1 Teil für das Dropdown-Menü
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: DropdownButton<int>(
                              value: gewaehlteHuetchen[kind],
                              items: [1, 2, 3, 4].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('Hütchen $value'),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    gewaehlteHuetchen[kind] = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (riegenKinder.length ==
                ausgewerteteKinder.length) // Beenden-Button anzeigen
              ZurueckButton(label: 'Nächste Disziplin steht an'),
          ],
        ),
      ),
    );
  }
}
