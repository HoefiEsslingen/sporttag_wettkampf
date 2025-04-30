/** Version 3 in der der CupertinoPicker-Dialog direkt über der Teilnehmerliste angezeigt wird */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../hilfs_widgets/rueck_sprung_button.dart';
import '../hilfs_widgets/meine_appbar.dart';
import '../klassen/kind_klasse.dart';

class StationenInDurchgaengen extends StatefulWidget {
  final List<Kind> teilnehmer;
  final int anzahlDurchgaenge;
  final Function(Map<Kind, List<int>>) onErgebnisseAbschliessen;

  const StationenInDurchgaengen({
    super.key,
    required this.teilnehmer,
    required this.anzahlDurchgaenge,
    required this.onErgebnisseAbschliessen,
  });

  @override
  State<StationenInDurchgaengen> createState() => _MehrfacheEingabeDialogWidgetState();
}

class _MehrfacheEingabeDialogWidgetState extends State<StationenInDurchgaengen> {
  int aktuellerDurchgang = 1;
  final Map<Kind, List<int>> ergebnisse = {};
  final Map<Kind, int> aktuellerWert = {};
  final Set<Kind> bearbeitet = {};
  List<Kind> teilnehmerReihenfolge = [];

  Kind? aktivBearbeitetesKind;
  int selectedValue = 1;

  @override
  void initState() {
    super.initState();
    teilnehmerReihenfolge = List.from(widget.teilnehmer);
    for (final kind in widget.teilnehmer) {
      ergebnisse[kind] = List<int>.filled(widget.anzahlDurchgaenge, 0);
      aktuellerWert[kind] = 0;
    }
  }

  bool alleBearbeitet() => bearbeitet.length == widget.teilnehmer.length;

  void _bestaetigeWert() {
    if (aktivBearbeitetesKind == null) return;

    setState(() {
      aktuellerWert[aktivBearbeitetesKind!] = selectedValue;
      ergebnisse[aktivBearbeitetesKind!]![aktuellerDurchgang - 1] = selectedValue;
      bearbeitet.add(aktivBearbeitetesKind!);
      teilnehmerReihenfolge.remove(aktivBearbeitetesKind);
      teilnehmerReihenfolge.add(aktivBearbeitetesKind!);
      aktivBearbeitetesKind = null;

      if (alleBearbeitet()) {
        if (aktuellerDurchgang < widget.anzahlDurchgaenge) {
          aktuellerDurchgang++;
          bearbeitet.clear();
        } else {
          widget.onErgebnisseAbschliessen(ergebnisse);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeineAppBar(
        titel: 'Durchgang $aktuellerDurchgang von ${widget.anzahlDurchgaenge}',
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          if (aktivBearbeitetesKind != null)
            Container(
                color: Colors.white,
                height: 190,
              child: Expanded(
                child: Column(
                  children: [
                    Text('${aktivBearbeitetesKind!.vorname} ${aktivBearbeitetesKind!.nachname}: erreichte Zone',
                      style: const TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 100,
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(initialItem: 0),
                        onSelectedItemChanged: (value) {
                          setState(() {
                            selectedValue = value; // Werte ab 1
                          });
                        },
                        children: List<Widget>.generate(
                          7,
                          (index) => Center(child: Text('${index}')),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: _bestaetigeWert,
                      child: const Text('Bestätigen'),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: teilnehmerReihenfolge.length,
              itemBuilder: (context, index) {
                final kind = teilnehmerReihenfolge[index];
                return ListTile(
                  title: Text('${kind.vorname} ${kind.nachname}'),
                  subtitle: Text('Bisher erreicht: ${ergebnisse[kind]!.join(' | ')}'),
                  trailing: bearbeitet.contains(kind)
                      ? const Icon(Icons.check, color: Colors.green, size: 40)
                      : IconButton(
                          icon: const Icon(Icons.sports_handball),
                          tooltip: 'Nachdem die beim Wurf erzielte Zone erfasst und bestätigt wurde, wird der Teilnehmer an das Ende der Liste verschoben.',
                          iconSize: 40,
                          onPressed: () {
                            setState(() {
                              aktivBearbeitetesKind = kind;
                              selectedValue = 1 /* auskommentiert: aktuellerWert[kind] ?? 1*/ ;
                            });
                          },
                        ),
                );
              },
            ),
          ),

          if (aktuellerDurchgang == widget.anzahlDurchgaenge && alleBearbeitet())
            ZurueckButton(
              label: 'Ergebnisse auswerten und zurück',
              auswertenDerErgebnisse: () => widget.onErgebnisseAbschliessen(ergebnisse),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


/****************
Version 2
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporttag/src/hilfs_widgets/rueck_sprung_button.dart';
import '../hilfs_widgets/meine_appbar.dart';
import '../klassen/kind_klasse.dart';

class StationenInDurchgaengen extends StatefulWidget {
  final List<Kind> teilnehmer;
  final int anzahlDurchgaenge;
  final Function(Map<Kind, List<int>>) onErgebnisseAbschliessen;

  const StationenInDurchgaengen({
    super.key,
    required this.teilnehmer,
    required this.anzahlDurchgaenge,
    required this.onErgebnisseAbschliessen,
  });

  @override
  State<StationenInDurchgaengen> createState() => _MehrfacheEingabeDialogWidgetState();
}

class _MehrfacheEingabeDialogWidgetState extends State<StationenInDurchgaengen> {
  int aktuellerDurchgang = 1;
  final Map<Kind, List<int>> ergebnisse = {};
  final Map<Kind, int> aktuellerWert = {};
  final Set<Kind> bearbeitet = {}; // Merkt, wer in diesem Durchgang schon bearbeitet wurde
  List<Kind> teilnehmerReihenfolge = [];

  @override
  void initState() {
    super.initState();
    teilnehmerReihenfolge = List.from(widget.teilnehmer);
    for (final kind in widget.teilnehmer) {
      ergebnisse[kind] = List<int>.filled(widget.anzahlDurchgaenge, 0);
      aktuellerWert[kind] = 0;
    }
  }

  bool alleBearbeitet() {
    return bearbeitet.length == widget.teilnehmer.length;
  }

  void _zeigeWertEingabeDialog(Kind kind) {
    int selectedValue = aktuellerWert[kind] ?? 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 200,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(initialItem: 0),
                onSelectedItemChanged: (int value) {
                  selectedValue = value + 1; // Werte ab 1
                },
                children: List<Widget>.generate(
                  7,
                  (index) => Center(child: Text('${index + 1}')),
                ),
              ),
            ),
            Expanded(
              child: CupertinoButton(
                child: const Text('Bestätigen'),
                onPressed: () {
                  setState(() {
                    aktuellerWert[kind] = selectedValue;
                    ergebnisse[kind]![aktuellerDurchgang - 1] = selectedValue;
                    bearbeitet.add(kind);

                    // Nach Bearbeitung Teilnehmer nach hinten verschieben
                    teilnehmerReihenfolge.remove(kind);
                    teilnehmerReihenfolge.add(kind);

                    // Prüfen ob alle bearbeitet wurden
                    if (alleBearbeitet()) {
                      if (aktuellerDurchgang < widget.anzahlDurchgaenge) {
                        // Neuen Durchgang starten
                        aktuellerDurchgang++;
                        bearbeitet.clear();
                      } else {
                        // Alle Durchgänge abgeschlossen
                        widget.onErgebnisseAbschliessen(ergebnisse);
                      }
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeineAppBar(
        titel: 'Durchgang $aktuellerDurchgang von ${widget.anzahlDurchgaenge}',
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: teilnehmerReihenfolge.length,
              itemBuilder: (context, index) {
                final kind = teilnehmerReihenfolge[index];
                return ListTile(
                  title: Text('${kind.vorname} ${kind.nachname}'),
                  subtitle: Text('Bisher erreicht: ${ergebnisse[kind]!.join(' | ')}'),
                  trailing: bearbeitet.contains(kind)
                      ? const Icon(Icons.check, color: Colors.green, size: 40,)
                      : IconButton(
                          icon: const Icon(Icons.sports_handball),
                          tooltip: 'Nachdem die beim Wurf erzielte Zone erfasst und bestätigt wurde, wird der Teilnehmer an das Ende der Liste verschoben.',
                          iconSize: 40,
                          onPressed: () => _zeigeWertEingabeDialog(kind),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // TODO: mit Button den nächsten Durchgang starten - bisher automatisch
          // TODO: wenn letzter Durchgang abgeschlossen, dann Button "Ergebnisse abschließen" anzeigen
          if (aktuellerDurchgang > 1)    // zu Testzwecken:  widget.anzahlDurchgaenge)
            ZurueckButton(
              label: 'Ergebnisse auswerten und zurück',
              auswertenDerErgebnisse: () {
                widget.onErgebnisseAbschliessen(ergebnisse);
              }
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
**************************
Version 1
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../klassen/kind_klasse.dart';

class StationenInDurchgaengen extends StatefulWidget {
  final List<Kind> teilnehmer;
  final int anzahlDurchgaenge;
  final Function(Map<Kind, List<int>>) onErgebnisseAbschliessen;

  const StationenInDurchgaengen({
    super.key,
    required this.teilnehmer,
    required this.anzahlDurchgaenge,
    required this.onErgebnisseAbschliessen,
  });

  @override
  State<StationenInDurchgaengen> createState() => _MehrfacheEingabeDialogWidgetState();
}

class _MehrfacheEingabeDialogWidgetState extends State<StationenInDurchgaengen> {
  int aktuellerDurchgang = 1;
  final Map<Kind, List<int>> ergebnisse = {};
  final Map<Kind, int> aktuellerWert = {};

  @override
  void initState() {
    super.initState();
    for (final kind in widget.teilnehmer) {
//      ergebnisse[kind] = [];
      ergebnisse[kind] = List<int>.filled(widget.anzahlDurchgaenge, 0);
      aktuellerWert[kind] = 0;
    }
  }

  bool alleHabenWert() {
    return aktuellerWert.values.every((wert) => wert >= 0);
  }

  void _durchgangSpeichernUndWeiter() {
    for (final kind in widget.teilnehmer) {
//      ergebnisse[kind]!.add(aktuellerWert[kind]!);
      ergebnisse[kind]![aktuellerDurchgang -1] = aktuellerWert[kind]!;
      aktuellerWert[kind] = 0; // Reset für nächsten Durchgang
    }

    if (aktuellerDurchgang < widget.anzahlDurchgaenge) {
      setState(() {
        aktuellerDurchgang++;
      });
    } else {
      // Alle Durchgänge abgeschlossen
      widget.onErgebnisseAbschliessen(ergebnisse);
    }
  }

  void _zeigeWertEingabeDialog(Kind kind) {
    int selectedValue = aktuellerWert[kind] ?? 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 200,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(initialItem: selectedValue),
                onSelectedItemChanged: (int value) {
                  selectedValue = value+1; // +1, da Picker bei 0 beginnt
                },
                children: List<Widget>.generate(
                  7, // Wertebereich 0–100
                  (index) => Center(child: Text('${index+1}')),
                ),
              ),
            ),
            Expanded(
              child: CupertinoButton(
                child: const Text('Bestätigen'),
                onPressed: () {
                  // TODO: Nach der Bestätigung soll der aktuelle Wert in die Liste aller Ergebnisse übernommen werden
                  // TODO: die Liste der TEilnehmer soll neu sortiert werden: der aktuell erste Eintrag soll nach hinten verschoben werden
                  // TODO: außerdem soll das "Bearbeiten"-Symbol wegfallen
                  setState(() {
                    aktuellerWert[kind] = selectedValue;
                    ergebnisse[kind]![aktuellerDurchgang - 1] = selectedValue;
                  });
                  // Schließe den Dialog
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Durchgang $aktuellerDurchgang von ${widget.anzahlDurchgaenge}'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: widget.teilnehmer.length,
              itemBuilder: (context, index) {
                final kind = widget.teilnehmer[index];
                return ListTile(
                  title: Text('${kind.vorname} ${kind.nachname}'),
//                  subtitle: Text('Bisher erreicht: ${aktuellerWert[kind]}'),
                  subtitle: Text('Bisher erreicht: ${ergebnisse[kind]![0]} | ${ergebnisse[kind]![1]} | ${ergebnisse[kind]![2]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Wert: ${aktuellerWert[kind]}'),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _zeigeWertEingabeDialog(kind),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: alleHabenWert() ? _durchgangSpeichernUndWeiter : null,
            child: Text(aktuellerDurchgang < widget.anzahlDurchgaenge
                ? 'Nächster Durchgang starten'
                : 'Ergebnisse abschließen'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
*/