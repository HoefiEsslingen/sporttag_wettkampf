import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporttag/src/klassen/kind_klasse.dart';
import 'package:sporttag/src/hilfs_widgets/rueck_sprung_button.dart';

import '../hilfs_widgets/meine_appbar.dart';

import 'logger.util.dart';

class MyStopUhr extends StatefulWidget {
  /// *************************************
  /// Der Stopuhr werden Personen übergeben, für die die verbleibdene (alsTimer == true)
  /// oder benötigte (alsTimer == false, also StopUhr) Zeit ermittelt wird.
  ///
  /// Die Zeit sollte an das rufende Widget zurück gegeben werden, damit diese dort ausgewertet wird.
  const MyStopUhr({
    super.key,
    required this.teilNehmer,
    required this.alsTimer,
    required this.timerZeit,
    required this.testLauf,
    required this.auswertenDerZeiten, // Callback-Funktion zur Rückgabe der Zeiten
  });

  final List<Kind> teilNehmer;
  final bool alsTimer;
  final int timerZeit;
  final bool testLauf;
  final Function(Map<Kind, int>)?
      auswertenDerZeiten; // Callback für das rufende Widget

  @override
  State<MyStopUhr> createState() => _MyStopUhrState();
}

class _MyStopUhrState extends State<MyStopUhr> {
  String appBarTitle = ''; // Titel für die AppBar (falls dynamisch angepasst)
  late Stopwatch
      stopwatch; // Stoppuhr-Objekt zur Messung der verstrichenen Zeit
  late Timer t; // Periodischer Timer zur Aktualisierung der UI
  late Duration timerDuration = Duration.zero; // Gesamtdauer des Timers
  late Duration remainingTime =
      Duration.zero; // Verbleibende Zeit im Timer-Modus
  Duration aenderungsIntervall = const Duration(
      milliseconds: 100); // Update-Intervall für den Timer (100 ms)
  get alsTimer => widget
      .alsTimer; // Steuerung: true => Timer-Modus, false => Stoppuhr-Modus
  get teilNehmer => widget.teilNehmer; // Liste der teilnehmenden Personen
  get testLauf => widget
      .testLauf; // Steuerung: true => Testlauf, false => regulärer Lauf

  bool alleGestoppt = false; // Überwacht, ob alle Teilnehmer gestoppt wurden
  bool isBlinking = false; // Für Blinke-Effekt
  double opacity = 1.0; // Steuerung der Sichtbarkeit beim Blinken

  // Map zur Speicherung der gestoppten Zeiten für jeden Teilnehmer
  final Map<Kind, int> _kindMitZeit = {};

  final log = getLogger();

  @override
  void initState() {
    // TODO: Countdown mit Zehntelsekunden; Was wird zurückgegeben, wenn der Countdown abgelaufen ist? --> Auswertung der Punktzahl; Probedurchgang???
    super.initState();

    // Initialisiert die Stoppuhr
    stopwatch = Stopwatch();

    // Timer-Werte aus den Widget-Parametern initialisieren
    timerDuration =
        Duration(seconds: widget.timerZeit); // Gesamtdauer des Timers
    remainingTime = timerDuration; // Verbleibende Zeit im Timer-Modus

    // Startet einen periodischen Timer, der alle 100 Millisekunden ausgeführt wird
    t = Timer.periodic(aenderungsIntervall, (timer) {
      setState(() {
        if (alsTimer) {
          _updateTimer(); // Reduziert die verbleibende Zeit im Timer-Modus
        } else {
          _updateStopwatch(); // Aktualisiert die verstrichene Zeit im Stoppuhr-Modus
        }
      });
    });

    // Blinke-Timer starten (nur wenn als Timer verwendet)
    if (widget.alsTimer) {
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (remainingTime.inSeconds <= 2) {
          setState(() {
            opacity = opacity == 1.0 ? 0.5 : 1.0; // Blinken
          });
        }
      });
    }
  }

  // Methode zur Freigabe von Ressourcen beim Schließen des Widgets
  @override
  void dispose() {
    t.cancel(); // Timer beenden, wenn das Widget zerstört wird
    super.dispose();
  }

  // Timer-Logik: Countdown
  void _updateTimer() {
    if (remainingTime > Duration.zero && stopwatch.isRunning) {
      remainingTime -= aenderungsIntervall; // Reduzieren der verbleibenden Zeit
      if (remainingTime <= Duration.zero - aenderungsIntervall) {
        stopwatch.stop(); // Timer stoppen, wenn die Zeit abgelaufen ist
        remainingTime = Duration.zero -
            aenderungsIntervall; // Sicherstellen, dass keine negative Zeit angezeigt wird
      }
    }
  }

  // Stoppuhr-Logik: Verstrichene Zeit
  void _updateStopwatch() {
    if (stopwatch.isRunning) {
      // Kein spezifisches Update erforderlich, da `stopwatch.elapsed` verwendet wird
    }
  }

  void handleStartStop() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
    } else {
      stopwatch.start();
      if (alsTimer) {
        remainingTime = timerDuration; // Timer zurücksetzen bei Start
      }
    }
  }

  void reset() {
    setState(() {
      stopwatch.reset();
      if (alsTimer) {
        remainingTime = timerDuration;
      }
    });
  }

  Color getUhrFarbe() {
    if (!widget.alsTimer) return Colors.white; 
    if (remainingTime.inSeconds > 2) return Colors.green; 
    if (remainingTime.inSeconds > 0) return Colors.orange;
    return Colors.red;
  }

  String returnFormattedText() {
    Duration duration = alsTimer ? remainingTime : stopwatch.elapsed;
    var milli = duration.inMilliseconds;

    String tenths = ((milli ~/ 100) % 10).toString(); // Zehntelsekunde
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0");

    return "$seconds.$tenths"; // Korrekte Ausgabe: Sekunden.Zehntelsekunden
  }

  void _stopForKind(Kind kind) {
    if (_kindMitZeit.containsKey(kind)) return; // Stop only once per child

    setState(() {
      _kindMitZeit[kind] = alsTimer
          ? remainingTime.inMilliseconds
          : stopwatch.elapsed.inMilliseconds;
      log.i(
          'Es wurde nicht gestoppt: remainingTime: ${(remainingTime.inMilliseconds).toStringAsFixed(1)}');
      if (_kindMitZeit.length == teilNehmer.length) {
        t.cancel();
        alleGestoppt = true; // Markiere, dass alle Teilnehmer gestoppt wurden
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeineAppBar(
        titel: 'Klick die Uhr zum Start.',
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            // this is the column
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                // Uhr starten mit Klick
                onPressed: () {
                  handleStartStop();
                },
                padding: const EdgeInsets.all(0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: remainingTime.inSeconds <= 2 ? opacity : 1.0,
                  child: Container(
                    height: 250,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // this one is use for make the circle on ui.
                      color: getUhrFarbe(),
                      border: Border.all(
                        color: const Color(0xff0395eb),
                        width: 4,
                      ),
                    ),
                    child: Text(
                      returnFormattedText(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                // Platzhalter
                height: 30,
                child: alsTimer
                    ? Text(
                        'Klicken Sie eine Teilnehmer:in, wenn sie vor Ablauf der Zeit im Ziel ist.')
                    : Text(
                        'Klicken Sie eine Teilnehmer:in um dessen Zeit zu stoppen.'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: teilNehmer.length,
                  itemBuilder: (context, index) {
                    final kind = teilNehmer[index];
                    return ListTile(
                      title: Text('${kind.vorname} ${kind.nachname}'),
                      // subtitle erscheint, wenn eine Zeit gestoppt wurde
                      subtitle: _kindMitZeit.containsKey(kind)
                          // Anzeigen sind unterscheidlich, je nachdem ob Timer oder Stoppuhr
                          ? (alsTimer
                              ? Text(
                                  'Noch verbleibende Zeit: ${(_kindMitZeit[kind]! / 1000).toStringAsFixed(1)} Sekunden')
                              : Text(
                                  'Gestoppte Zeit: ${(_kindMitZeit[kind]! / 1000).toStringAsFixed(1)} Sekunden'))
                          : null,
                      // nachdem eine Zeit gestoppt wurde, wird ein grüner Haken angezeigt
                      trailing: _kindMitZeit.containsKey(kind)
                          ? const Icon(Icons.check, color: Colors.green)
                          // sonst wird ein Button angezeigt, um die Zeit zu stoppen
                          : stopwatch.isRunning
                              ? ElevatedButton(
                                  onPressed: () => _stopForKind(kind),
                                  child: Text('${kind.vorname}'),
                                )
                              : null,
                    );
                  },
                ),
              ),
              if (alleGestoppt) // Beenden-Button anzeigen
                ZurueckButton(
                  label: 
                  !testLauf ?'Nächster Durchgang' : 'Testlauf beendet. \n Neue Auswahl der Hütchen ist möglich',
                  auswertenDerErgebnisse: 
                  !testLauf?
                  () {
                    log.i('rufe Callback auf');
                    widget.auswertenDerZeiten!(_kindMitZeit);
                  }
                  : null, // Callback nur aufrufen, wenn nicht im Testlauf
                ), // Callback ausführen
            ],
          ),
        ),
      ),
    );
  }
}
