import 'package:flutter/material.dart';

class Pause extends StatelessWidget {
  const Pause({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guten Appetit'),
        automaticallyImplyLeading: false, // Standard-Zurück-Pfeil ausblenden
      ),
      body: Center(
        child: 
            const Text(
              textAlign:TextAlign.center, 
              'Vielen Dank,\ndass Sie die Riege durch den Wettbewerb führen.\n\nDie Mittagspause haben Sie und Ihre Riegenkinder verdient.\n\nSie können die App jetzt schließen.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

}