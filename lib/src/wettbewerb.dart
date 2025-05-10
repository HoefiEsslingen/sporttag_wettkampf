import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pause.dart';
import 'dankeschoen.dart';
import 'disziplinen_widgets/hoch_weit_sprung.dart';
import 'disziplinen_widgets/bananen_kartons.dart';
import 'disziplinen_widgets/sprint.dart';
import 'disziplinen_widgets/lauf.dart';
import 'disziplinen_widgets/schlag_wurf.dart';
import 'disziplinen_widgets/dreh_wurf.dart';
import 'disziplinen_widgets/stab_fliegen.dart';
import 'disziplinen_widgets/druck_wurf.dart';
import 'disziplinen_widgets/weit_sprung.dart';
import 'disziplinen_widgets/stadion_runde.dart';
import 'klassen/kind_klasse.dart';
import 'tools/kind_repository.dart';
import 'tools/logger.util.dart';
import 'hilfs_widgets/meine_appbar.dart';

class Wettbewerb extends StatefulWidget {
  final int riegenNummer;
  final String wettbewerbsTyp;

  const Wettbewerb(
      {super.key, required this.riegenNummer, required this.wettbewerbsTyp});

  @override
  WettbewerbState createState() => WettbewerbState();
}

class WettbewerbState extends State<Wettbewerb> {
  final KindRepository kindRepository = KindRepository();
  List<Kind> riegenKinder = [];
  final log = getLogger();
  final bool isDevelopment = true;
  late Map<String, Widget Function()> disziplinPages;
  final Set<String> besuchteDisziplinen = {};
  bool pauseGemacht = false;

  int get riegenNummer => widget.riegenNummer;
  String get wettbewerbsTyp => widget.wettbewerbsTyp;

  @override
  void initState() {
    super.initState();

    disziplinPages = {
      'Schlagwurf': () => Schlagwurf(riegenNummer: riegenNummer),
      'Drehwurf': () => Drehwurf(riegenNummer: riegenNummer),
      'Druckwurf': () => Druckwurf(riegenNummer: riegenNummer),
      'Sprint': () => Sprint(riegenNummer: riegenNummer),
      '30m Banankartons': () => Bananenkartons(riegenNummer: riegenNummer),
      '30 sec Lauf': () => Lauf(riegenNummer: riegenNummer),
      'Stabfliegen': () => Stabfliegen(riegenNummer: riegenNummer),
      'Hoch-Weitsprung': () => HochWeitSprung(riegenNummer: riegenNummer),
      'Zonenweitsprung': () => Zonenweitsprung(riegenNummer: riegenNummer),
      'Stadionrunde': () => Stadionrunde(riegenNummer: riegenNummer),
    };

    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDisziplinen = prefs.getStringList('besuchteDisziplinen');
    if (savedDisziplinen != null) {
      setState(() {
        besuchteDisziplinen.addAll(savedDisziplinen);
      });
    }
    final savedPause = prefs.getBool('pauseGemacht');
    if (savedPause != null) {
      setState(() {
        pauseGemacht = savedPause;
      });
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'besuchteDisziplinen',
      besuchteDisziplinen.toList(),
    );
    prefs.setBool('pauseGemacht', pauseGemacht);
  }

  Future<void> _clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget Function()> angeboteneDisziplinen =
        wettbewerbsTyp != 'Zehnkampf'
            ? Map.fromEntries(disziplinPages.entries.take(5))
            : disziplinPages;
    // Hier wird die letzte Station ermittelt, diese sollte am Ende auswählbaren Disziplinen stehen
    // und ist erst dann auswählbar, wenn alle anderen Disziplinen besucht wurden
    final String dieLetzeStation = angeboteneDisziplinen.keys.last; // hier: Stadionrunde
    final List<String> disziplinNamen = angeboteneDisziplinen.keys.toList();

    return Scaffold(
      appBar: MeineAppBar(
        titel: 'Wettbewerbe Sporttag: Riege $riegenNummer',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...disziplinNamen.map((disziplin) {
              // Überprüft, ob die Disziplin bereits besucht wurde
              final istBesucht = besuchteDisziplinen.contains(disziplin);
              // Überprüft, ob es sich bei der 'disziplin' um 'dieLetzteStation' handelt. Diese soll erst ganz am Ende auswählbar sein.
              final istLetzteStation = disziplin == dieLetzeStation;
              // Stellt sicher, dass alle anderen Disziplinen außer dieLetzeStation bereits abgeschlossen sind.
              final alleAnderenBesucht = besuchteDisziplinen.length ==
                  angeboteneDisziplinen.length - 1;

              // Logik zur Aktivierung des Buttons: Der Button darf nur aktiv sein, wenn die Disziplin noch nicht besucht wurde
              // Und: Falls es sich um dieLetzeStation handelt, darf er nur aktiv sein, 
              // wenn alle anderen Disziplinen bereits besucht wurden
              final istAktiv = !istBesucht &&
                  (!istLetzteStation || alleAnderenBesucht);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: istAktiv
                      ? () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  angeboteneDisziplinen[disziplin]?.call() ??
                                  const Center(
                                      child: Text('Disziplin nicht gefunden')),
                            ),
                          );
                          setState(() {
                            besuchteDisziplinen.add(disziplin);
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        istBesucht ? Colors.grey : Colors.red,
                  ),
                  child: Text(
                    istBesucht
                        ? '$disziplin (besucht)'
                        : disziplin,
                    style: TextStyle(
                      color: istBesucht ? Colors.black45 : Colors.white,
                    ),
                  ),
                ),
              );
//            }).toList(),
            }),
            const SizedBox(height: 20),
            if (besuchteDisziplinen.length == angeboteneDisziplinen.length)
              ElevatedButton(
                onPressed: () {
                  _clearState();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Dankeschoen(),
                    ),
                  );
                },
                child: const Text('Ende Sporttag'),
              )
              else if (!pauseGemacht &&
                wettbewerbsTyp == 'Zehnkampf' &&
                besuchteDisziplinen.length >= 4)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    pauseGemacht = true;
                  });
                  _saveState();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pause(),
                    ),
                  );
                },
                child: const Text('Pause'),
              ),             
          ],
        ),
      ),
    );
  }
}

/**** Test-Versionen
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pause.dart';
import 'dankeschoen.dart';
import 'disziplinen_widgets/hoch_weit_sprung.dart';
import 'disziplinen_widgets/bananen_kartons.dart';
import 'disziplinen_widgets/sprint.dart';
import 'disziplinen_widgets/lauf.dart';
import 'disziplinen_widgets/schlag_wurf.dart';
import 'disziplinen_widgets/dreh_wurf.dart';
import 'disziplinen_widgets/stab_fliegen.dart';
import 'disziplinen_widgets/druck_wurf.dart';
import 'disziplinen_widgets/weit_sprung.dart';
import 'disziplinen_widgets/stadion_runde.dart';
import 'klassen/kind_klasse.dart';
import 'tools/kind_repository.dart';
import 'tools/logger.util.dart';
import 'hilfs_widgets/meine_appbar.dart';

class Wettbewerb extends StatefulWidget {
  final int riegenNummer;
  final String wettbewerbsTyp;

  const Wettbewerb(
      {super.key, required this.riegenNummer, required this.wettbewerbsTyp});

  /// Aktivität vorbereiten
  @override
  WettbewerbState createState() => WettbewerbState();
}

class WettbewerbState extends State<Wettbewerb> {
  final KindRepository kindRepository = KindRepository(); // Repository-Objekt

  List<Kind> riegenKinder = [];
  final log = getLogger();
  final bool isDevelopment = true; // Setze auf `false` im Produktionsmodus
  late Map<String, Widget Function()> disziplinPages;
  // Speichert besuchte Disziplinen
  final Set<String> besuchteDisziplinen = {};
  bool pauseGemacht = false;

  int get riegenNummer => widget.riegenNummer;
  String get wettbewerbsTyp => widget.wettbewerbsTyp;

  @override
  initState() {
    super.initState();
//log.i('Ausgabe Riegenummer in initState(): $riegenNummer');

    // Map zur Zuordnung von Disziplinen zu ihren jeweiligen Widgets
    disziplinPages = {
      'Zonenweitsprung': () => Zonenweitsprung(riegenNummer: riegenNummer),
      'Schlagwurf': () => Schlagwurf(riegenNummer: riegenNummer),
      'Drehwurf': () => Drehwurf(riegenNummer: riegenNummer),
      'Druckwurf': () => Druckwurf(riegenNummer: riegenNummer),
      'Sprint': () => Sprint(riegenNummer: riegenNummer),
      '30m Banankartons': () => Bananenkartons(riegenNummer: riegenNummer),
      '30 sec Lauf': () => Lauf(
            riegenNummer: riegenNummer,
          ),
      'Stabfliegen': () => Stabfliegen(riegenNummer: riegenNummer),
      'Hoch-Weitsprung': () => HochWeitSprung(riegenNummer: riegenNummer),
      'Stadionrunde': () => Stadionrunde(riegenNummer: riegenNummer),
    };
    // den Zustand der App vor der Pause wiederherstellen
    _loadState();
  }

  // Wiederherstellen des App-Zustands der vor Eintritt in die Pause erreicht wurde
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDisziplinen = prefs.getStringList('besuchteDisziplinen');
    if (savedDisziplinen != null) {
      setState(() {
        besuchteDisziplinen.addAll(savedDisziplinen);
      });
    }
    final savedPause = prefs.getBool('pauseGemacht');
    if (savedPause != null) {
      setState(() {
        pauseGemacht = savedPause;
      });
    }
  }

  // Speichern des App-Zustands, wenn Pause gemacht wird
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'besuchteDisziplinen',
      besuchteDisziplinen.toList(),
    );
    prefs.setBool('pauseGemacht', pauseGemacht);
  }

  // App-Speicher löschen vor Beendigung der App
  Future<void> _clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    // FAlls wettbewerbstyp = 'Fuenfkampf' werden aus der Map nur die ersten 5 Disziplinen angezogen, sonnst alle
    final Map<String, Widget Function()> angeboteneDisziplinen =
        wettbewerbsTyp != 'Zehnkampf'
            ? Map.fromEntries(disziplinPages.entries.take(5))
            : disziplinPages;

    return Scaffold(
      appBar: MeineAppBar(
        titel: 'Wettbewerbe Sporttag: Riege $riegenNummer',
      ),
      body: Center(
        child: Column(
          children: angeboteneDisziplinen.keys.map((disziplin) {
            final istBesucht = besuchteDisziplinen.contains(disziplin);
            final istStadionrunde = disziplin == 'Stadionrunde';

            // Alle anderen Disziplinen müssen besucht sein, bevor Stadionrunde aktiviert wird
            final alleAnderenErledigt = angeboteneDisziplinen.keys
                .where((d) => d != 'Stadionrunde')
                .every((d) => besuchteDisziplinen.contains(d));

            final buttonAktiv = !istBesucht &&
                (!istStadionrunde || (istStadionrunde && alleAnderenErledigt));

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: buttonAktiv
                    ? () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                angeboteneDisziplinen[disziplin]?.call() ??
                                const Center(
                                    child: Text('Disziplin nicht gefunden')),
                          ),
                        );
                        setState(() {
                          besuchteDisziplinen.add(disziplin);
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: istBesucht ? Colors.grey : Colors.red,
                  minimumSize: const Size.fromHeight(
                      50), // optional: für Einheitlichkeit
                ),
                child: Text(
                  istBesucht ? '$disziplin (besucht)' : disziplin,
                  style: TextStyle(
                    color: istBesucht ? Colors.black45 : Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
*/
/*        Column(
          children: angeboteneDisziplinen.keys.map((disziplin) {
            final istBesucht = besuchteDisziplinen.contains(disziplin);
            final istStadionrunde = disziplin == 'Stadionrunde';
            final alleVorherigenBesucht = angeboteneDisziplinen.keys
                .where((d) => d != 'Stadionrunde')
                .every((d) => besuchteDisziplinen.contains(d));

            final buttonAktiv = !istBesucht &&
                (!istStadionrunde ||
                    (istStadionrunde && alleVorherigenBesucht));

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: buttonAktiv
                          ? () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      angeboteneDisziplinen[disziplin]
                                          ?.call() ??
                                      const Center(
                                          child:
                                              Text('Disziplin nicht gefunden')),
                                ),
                              );
                              setState(() {
                                besuchteDisziplinen.add(disziplin);
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: istBesucht ? Colors.grey : Colors.red,
                      ),
                      child: Text(
                        istBesucht ? '$disziplin (besucht)' : disziplin,
                        style: TextStyle(
                          color: istBesucht ? Colors.black45 : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ReorderableDragStartListener(
//                  ReorderableListView(
                    index:
                        angeboteneDisziplinen.keys.toList().indexOf(disziplin),
                    child: const Icon(null), //Icons.drag_handle),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
*/
/*        Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: angeboteneDisziplinen.keys.map((disziplin) {
                final istBesucht = besuchteDisziplinen.contains(disziplin);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: istBesucht
                        ? null // Deaktiviert, wenn die Disziplin bereits besucht wurde
                        : () async {
                            // Navigation zur Detailseite
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    angeboteneDisziplinen[disziplin]?.call() ??
                                    const Center(
                                        child:
                                            Text('Disziplin nicht gefunden')),
                              ),
                            );
                            // Nach Rücksprung: Disziplin als besucht markieren
                            setState(() {
                              besuchteDisziplinen.add(disziplin);
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          istBesucht ? Colors.grey : Colors.red, // Stil ändern
                    ),
                    child: Text(
                      istBesucht
                          ? '$disziplin (besucht)'
                          : disziplin, // Text anpassen
                      style: TextStyle(
                        color: istBesucht ? Colors.black45 : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // kleiner Platzhalter
            SizedBox(width: 10),
            // wurde im Zehnkampf noch keine Pause gemacht soll der Button "Pause" angezeigt werden,
            // sobald mindestens 4 Disziplinen besucht wurden ...
            (!pauseGemacht &&
                    wettbewerbsTyp == 'Zehnkampf' &&
                    besuchteDisziplinen.length >= 4)
                ? Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        pauseGemacht = true;
                        _saveState();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Pause(),
                          ),
                        );
                      },
                      child: const Text('Pause'),
                    ),
                  )
                // ... ist die Pause bereits gemacht worden, wird der Button "Ende Sporttag" angezeigt, wenn alle Disziplinen besucht wurden
                : (pauseGemacht &&
                        besuchteDisziplinen.length ==
                            angeboteneDisziplinen.length)
                    ? Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _clearState();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Dankeschoen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Ende Sporttag',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                // ... ansonsten wird ein leeres Widget angezeigt
                    : const SizedBox.shrink()
          ],
        ),

      ),
    );
  }
}
*/