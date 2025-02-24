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
      'Zonenweitsprung': () => const Zonenweitsprung(),
      'Schlagwurf': () => const Schlagwurf(),
      'Drehwurf': () => const Drehwurf(),
      'Druckwurf': () => const Druckwurf(),
      'Sprint': () => Sprint(riegenNummer: riegenNummer),
      '30m Banankartons': () => Bananenkartons(riegenNummer: riegenNummer),
      '30 sec Lauf': () => Lauf(
            riegenNummer: riegenNummer,
          ),
      'Stabfliegen': () => const Stabfliegen(),
      'Hoch-Weitsprung': () => const Weitsprung(),
      'Stadionrunde': () => const Stadionrunde(),
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
