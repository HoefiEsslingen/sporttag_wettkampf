import 'package:flutter/material.dart';
import '../klassen/kind_klasse.dart';

class TeilnehmerListe extends StatelessWidget {
  final List<Kind> teilNehmer;
  final Map<Kind, int> kindMitZeit;
  final bool alsTimer;
  final bool isRunning;
  final void Function(Kind kind) onStop;

  const TeilnehmerListe({
    super.key,
    required this.teilNehmer,
    required this.kindMitZeit,
    required this.alsTimer,
    required this.isRunning,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: teilNehmer.length,
      itemBuilder: (context, index) {
        final kind = teilNehmer[index];
        final gestoppteZeit = kindMitZeit[kind];

        return ListTile(
          title: Text('${kind.vorname} ${kind.nachname}'),
          subtitle: gestoppteZeit != null
              ? Text(
                  alsTimer
                      ? 'Noch verbleibende Zeit: ${(gestoppteZeit / 1000).toStringAsFixed(1)} Sekunden'
                      : 'Gestoppte Zeit: ${(gestoppteZeit / 1000).toStringAsFixed(1)} Sekunden',
                )
              : null,
          trailing: gestoppteZeit != null
              ? const Icon(Icons.check, color: Colors.green)
              : isRunning
                  ? ElevatedButton(
                      onPressed: () => onStop(kind),
                      child: Text(kind.vorname),
                    )
                  : null,
        );
      },
    );
  }
}