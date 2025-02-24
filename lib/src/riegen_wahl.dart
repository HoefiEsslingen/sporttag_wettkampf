import 'package:sporttag/src/hilfs_widgets/mein_listen_eintrag.dart';
import 'package:sporttag/src/klassen/kind_klasse.dart';
import 'package:sporttag/src/riege_bestaetigen.dart';
import 'package:sporttag/src/tools/kind_repository.dart';
import 'package:sporttag/src/tools/logger.util.dart';
import 'package:flutter/material.dart';

class Riegenwahl extends StatefulWidget {
  const Riegenwahl({super.key});

  @override
  State<Riegenwahl> createState() => _RiegenwahlState();
}

class _RiegenwahlState extends State<Riegenwahl> {
  final KindRepository kindRepository = KindRepository(); // Repository-Objekt
  List<int> riegenNummern = List.generate(8, (index) => index + 1); // 8 Riegen
  int riegenNummer = 1;
  List<Kind> riegenKinder = [];
  int? ausgewaehlteRiege;
  bool isLoading = false;

  var log = getLogger();

  @override
  initState() {
    super.initState();
    _loadKinderDerRiege(riegenNummer);
  }

  Future<void> _loadKinderDerRiege(int riegenNummer) async {
    setState(() {
      isLoading = true;
      ausgewaehlteRiege = riegenNummer;
      riegenKinder = [];
    });
    try {
      riegenKinder = await kindRepository.ladeKinderDerRiege(riegenNummer);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _berechneWettbewerbsTyp(List<Kind> kinder) {
    final int aktuellesJahr = DateTime.now().year;
    int hoechsterJahrgang = int.parse((riegenKinder
          ..sort((a, b) => a.jahrgang.compareTo(b.jahrgang)))
        .first
        .jahrgang);
    if (hoechsterJahrgang != 0) {
      int hoechstesAlter = aktuellesJahr - hoechsterJahrgang;
      return hoechstesAlter <= 5 ? 'Fünfkampf' : 'Zehnkampf';
    } else {
      return 'Zehnkampf';
    }
    /**
     * kürzer möglich:
     *    return (aktuellesJahr - hoechsterJahrgang) <= 5 ? 'Fünfkampf' : 'Zehnkampf';
     */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riegenwahl'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Riege:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: riegenNummer > 1
                          ? () {
                              setState(() {
                                riegenNummer--;
                                _loadKinderDerRiege(riegenNummer);
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$riegenNummer',
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: riegenNummer < 8
                          ? () {
                              setState(() {
                                riegenNummer++;
                                _loadKinderDerRiege(riegenNummer);
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const CircularProgressIndicator()
                : riegenKinder.isNotEmpty
                    ? ListView.builder(
                        itemCount: riegenKinder.length,
                        itemBuilder: (context, index) {
                          final kind = riegenKinder[index];
                          return MeinListenEintrag(
                            kind: kind,
                            istAusgewertet: false,
                            istSelektiert: false,
                            // keine Aktion bei Selektion
                            onSelectionChanged: (Kind kind, bool isSelected) {
                              setState(() {});
                            },
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'Keine Kinder in dieser Riege gefunden.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: (ausgewaehlteRiege != null && riegenKinder.isNotEmpty)
                  ? () async {
                      final wettbewerbsTyp =
                          _berechneWettbewerbsTyp(riegenKinder);
                      // weiter zur Bestätigung der Riege
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiegeBestaetigen(
                              riegenNummer: ausgewaehlteRiege!,
                              wettbewerbsTyp: wettbewerbsTyp),
                        ),
                      ).then((result) {
                        if (result == true) {
                          // Zustand zurücksetzen, wenn der Rücksprung erfolgt ist
                          setState(() {
//                            ausgewaehlteRiege = null;
//                            riegenKinder.clear();
                          });
                        }
                      });
                    }
                  : null,
              child: const Text('Riege auswählen'),
            ),
          ),
        ],
      ),
    );
  }
}
