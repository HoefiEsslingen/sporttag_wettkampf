import 'package:flutter/material.dart';
import '../hilfs_widgets/mein_listen_eintrag.dart';
import '../hilfs_widgets/meine_appbar.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';
import '../klassen/kind_klasse.dart';
import '../tools/stationen_in_durchgaengen.dart';
import '../tools/kind_repository.dart';
import '../tools/logger.util.dart';
import '../tools/stationen_repository.dart';

class Zonenweitsprung extends StatefulWidget {
  final int riegenNummer;

  const Zonenweitsprung({super.key, required this.riegenNummer});

  /// Aktivität vorbereiten
  @override
  ZonenweitsprungState createState() => ZonenweitsprungState();
}

class ZonenweitsprungState extends State<Zonenweitsprung> {
  late String stationsName; // Variable für die zugewiesene Ausgabe
  // Repository-Objekte
  final KindRepository kindRepository = KindRepository();
  final StationenRepository stationenRepository = StationenRepository();

  late int riegenNummer;
  List<Kind> riegenKinder = [];
  List<Kind> selectedKinder = [];
  List<Kind> kinderZurAnzeige = []; // Speichert anzuzeigende Teilnehmer
  Set<Kind> ausgewerteteKinder = {}; // Speichert ausgewertete Teilnehmer
  var istAusgewertet = false;
  Map<Kind, int> kinderMitErreichtenPunkten =
      {}; // Speichert die Summe der beiden besten Würfe

  final log = getLogger();

  @override
  void initState() {
    super.initState();
    // widget.toString() der Variable zuweisen
    stationsName = widget.toString();
    riegenNummer = widget.riegenNummer;
    _loadData();
  }

  Future<void> auswerten(Map<Kind, List<int>> resultate) async {
    // Auswertung zulassen, falls der Testlauf beendet ist
    setState(() {
      // resultate ist eine Liste von int-Werten
      // aus dieser Liste sollen die besten zwei Werte ermittelt und addiert werden
      // --> die Liste wird absteigend sortiert
      resultate.forEach((kind, listeDerErreichtenZonen) {
        listeDerErreichtenZonen
            .sort((a, b) => b.compareTo(a)); // Absteigend sortieren
        final besteZwei =
            listeDerErreichtenZonen.take(2).toList(); // Besten zwei Werte
        final summe = besteZwei.reduce((a, b) => a + b); // Addieren
        kinderMitErreichtenPunkten[kind] = summe; // Zeit speichern
        kind.erreichtePunkte += summe; // Punkte zuweisen
      });

      // alle Teilnehmer als ausgewertet markieren --> resultate.keys sind die Kinder, die ausgewertet wurden
      ausgewerteteKinder.addAll(resultate.keys);
      // Auswahl nach der Auswertung zurücksetzen
      selectedKinder.clear();

      // Liste zur Anzeige aufbereiten -> nicht ausgewertete Kinder oben
      kinderZurAnzeige =
          kindRepository.zurAnzeigeSortieren(riegenKinder, ausgewerteteKinder);

      // globale Variable 'istAusgewertet' setzen
      // damit die AppBar den Button "Nächste Disziplin steht an" anzeigen kann
      istAusgewertet = true;
    });

    // Speichern der ausgewerteten Kinder (hier: alle) in der Datenbank
    final zuSpeicherndeKinder = resultate.keys.toList();
    for (var kind in zuSpeicherndeKinder) {
      await kindRepository.saveKindToDatabase(kind);
    }
  }

  @override
  void dispose() {
    super.dispose();
    riegenKinder.clear();
    selectedKinder.clear();
    kinderZurAnzeige.clear();
    ausgewerteteKinder.clear();
    kinderMitErreichtenPunkten.clear();
  }

  Future<void> _loadData() async {
    riegenKinder = await kindRepository.ladeKinderDerRiege(riegenNummer);
    // Liste zur Anzeige aufbereiten -> nicht ausgewertete Kinder oben
    kinderZurAnzeige =
        kindRepository.zurAnzeigeSortieren(riegenKinder, ausgewerteteKinder);
    setState(() {}); // UI aktualisieren
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
              'Aus einem definierten Anlauf sollen die Kinder mit einem Bein abspringen und beidbeinig in einem Reifen landen.\nNach einem Probedurchgang, der nicht protokolliert wird, werden für jedes Kind drei Durchgänge gewertet.\nJeder Reifen entspricht einer Zone.\nDie zwei besten Sprünge werden addiert.',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall, // Verwenden des Themes
            ),
            // Abstandshalter
            SizedBox(height: 10),
            // Liste der Kinder in der ausgewählten Riege
            if (!istAusgewertet)
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StationenInDurchgaengen(
                            teilnehmer: kinderZurAnzeige,
                            anzahlDurchgaenge: 3,
                            onErgebnisseAbschliessen: auswerten,
                            iconWidget: Image.asset(
                              'assets/icons/weitsprung.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ));
                  },
                  child: Text(
                    'In den ersten gewerteten Durchgang starten',
                    textAlign: TextAlign.center,
                  )),
            // Abstandshalter
            SizedBox(height: 10),
            // Zeigt die Liste der Kinder in der Riege an
            // Hier können die Kinder, welche an der nächsten Runde teilnehmen sollen ausgewählt werden
            Expanded(
              child: ListView.builder(
                itemCount: riegenKinder.length,
                itemBuilder: (context, index) {
                  final kind = kinderZurAnzeige[index];
                  final zeit = kinderMitErreichtenPunkten[
                      kind]; // Gestoppte Zeit abrufen
                  final istAusgewertet = ausgewerteteKinder.contains(kind);
                  final istSelektiert = selectedKinder.contains(kind);
                  return MeinListenEintrag(
                    kind: kind,
                    istAusgewertet: istAusgewertet,
                    istSelektiert: istSelektiert,
                    erreichtePunkte: zeit,
                    onSelectionChanged: (Kind kind, bool istSelektiert) {
                      setState(() {
                        // Keine Aktion
                      });
                    },
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
