import 'package:flutter/material.dart';
import 'package:sporttag/src/wettbewerb.dart';

class RiegeBestaetigen extends StatelessWidget {
  final int riegenNummer;
  final String wettbewerbsTyp;

  const RiegeBestaetigen({
    super.key,
    required this.riegenNummer,
    required this.wettbewerbsTyp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riege bestaetigen'),
        automaticallyImplyLeading: false, // Standard-Zurück-Pfeil ausblenden
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Riege: $riegenNummer',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Wettbewerbstyp: $wettbewerbsTyp',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Hier könnte der eigentliche RiegeBestaetigen gestartet werden
                Navigator.pop(context, true);
              },
              child: const Text('Riegenwahl korrigieren'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Wettbewerb(
                        riegenNummer: riegenNummer,
                        wettbewerbsTyp: wettbewerbsTyp),
                  ),
                );
              },
              child: Text(
                'Wettbewerb als $wettbewerbsTyp starten',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
