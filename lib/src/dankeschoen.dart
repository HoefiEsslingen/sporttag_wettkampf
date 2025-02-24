import 'package:flutter/material.dart';

class Dankeschoen extends StatelessWidget {
  const Dankeschoen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dankeschoen'),
        automaticallyImplyLeading: false, // Standard-Zurück-Pfeil ausblenden
      ),
      body: Center(
        child: 
            const Text(
              textAlign:TextAlign.center, 
              'Vielen Dank,\ndass Sie die Riege durch den Wettbewerb geführt haben.\n\n\nSie können die App jetzt schließen.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

}