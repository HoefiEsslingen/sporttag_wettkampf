import '../klassen/kind_klasse.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class KindRepository {
  // Konstante für Back4App API-URL
  static const String baseUrl = 'https://parseapi.back4app.com/classes/Kind';

  // API-Schlüssel und IDs
  static const Map<String, String> headers = {
    'X-Parse-Application-Id': 'WLgenML3TwDSZ80DBWggNnJaNePhJ3RQgzdCvvv0',
    'X-Parse-REST-API-Key': 'J2d7lGWvOXMpyMe5NzOhWpmON7uheSNwQFxnHv5B',
    'Content-Type': 'application/json',
  };

  // Erstellt ein Kind-Objekt aus den JSON-Daten
  Kind createKindFromJson(Map<String, dynamic> json) {
    return Kind(
      objectId: json['objectId'] ?? '',
      vorname: json['Vorname'] ?? '',
      nachname: json['Nachname'] ?? '',
      jahrgang: json['Jahrgang'] ?? '',
      geschlecht: json['Geschlecht'] ?? '',
      erreichtePunkte: json['Punkte'] ?? 0,
      bezahlt: json['bezahlt'] ?? false,
      riegenNummer: json['RiegenNummer'] ?? 0,
    );
  }

  // Speichert ein Kind in die Datenbank
  Future<void> saveKindToDatabase(Kind kind) async {
    final url =
        kind.objectId.isNotEmpty ? '$baseUrl/${kind.objectId}' : baseUrl;
    final method = kind.objectId.isNotEmpty ? 'PUT' : 'POST';

    final response = http.Request(method, Uri.parse(url))
      ..headers.addAll(headers)
      ..body = jsonEncode({
        'Vorname': kind.vorname,
        'Nachname': kind.nachname,
        'Jahrgang': kind.jahrgang,
        'Geschlecht': kind.geschlecht,
        'Punkte': kind.erreichtePunkte,
        'bezahlt': kind.bezahlt,
        'RiegenNummer': kind.riegenNummer,
      });

    final streamedResponse = await response.send();
    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      print('Kind erfolgreich gespeichert.');
    } else {
      print('Fehler beim Speichern des Kinds: ${streamedResponse.statusCode}');
    }
  }

  // Lädt ein Kind aus der Datenbank basierend auf Vorname, Nachname und Jahrgang
  Future<Kind?> loadKindFromDatabase(
      String vorname, String nachname, String jahrgang) async {
    final response = await http.get(
      Uri.parse('$baseUrl?where=${Uri.encodeComponent(jsonEncode({
            'Vorname': vorname,
            'Nachname': nachname,
            'Jahrgang': jahrgang,
          }))}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['results'] != null &&
          jsonResponse['results'].isNotEmpty) {
        return createKindFromJson(jsonResponse['results'].first);
      }
    } else {
      print('Fehler beim Laden des Kindes: ${response.body}');
    }
    return null;
  }

  // Lädt alle Kinder aus der Datenbank
  Future<List<Kind>> loadAllKinder() async {
    List<Kind> alleKinder = [];
    int limit = 100;
    int skip = 0;

    bool hasMore = true;
    while (hasMore) {
      final response = await http.get(
        Uri.parse('$baseUrl?limit=$limit&skip=$skip'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['results'] != null &&
            jsonResponse['results'].isNotEmpty) {
          final kinderTeilListe = (jsonResponse['results'] as List)
              .map((json) => createKindFromJson(json))
              .toList();
          alleKinder.addAll(kinderTeilListe);
          skip += limit;
          if (kinderTeilListe.length < limit) {
            hasMore = false;
          }
        } else {
          hasMore = false;
        }
      } else {
        print('Fehler beim Laden aller Kinder: ${response.body}');
        hasMore = false;
      }
    }
    return alleKinder;
  }

  // Lädt alle Kinder einer bestimmten Riege
  Future<List<Kind>> ladeKinderDerRiege(int riegenNummer) async {
    final response = await http.get(
      Uri.parse('$baseUrl?where=${Uri.encodeComponent(jsonEncode({
            'RiegenNummer': riegenNummer,
          }))}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['results'] != null) {
        return (jsonResponse['results'] as List)
            .map((json) => createKindFromJson(json))
            .toList();
      }
    } else {
      print('Fehler beim Laden der Kinder einer Riege: ${response.body}');
    }
    return [];
  }

  // Speichert eine Liste von Kindern in die Datenbank
  Future<void> saveKinderListeToDatabase(List<Kind> kinderListe) async {
    for (final kind in kinderListe) {
      await saveKindToDatabase(kind);
    }
  }

  List<Kind> zurAnzeigeSortieren(
      List<Kind> riegenKinder, Set<Kind> ausgewerteteKinder) {
    List<Kind> kinder = List<Kind>.from(riegenKinder);
    return kinder
      ..sort((a, b) {
        final istAusgewertetA = ausgewerteteKinder.contains(a);
        final istAusgewertetB = ausgewerteteKinder.contains(b);

        // Noch nicht ausgewertete Kinder sollen oben stehen
        if (istAusgewertetA && !istAusgewertetB) return 1;
        if (!istAusgewertetA && istAusgewertetB) return -1;

        if (!istAusgewertetA && !istAusgewertetB) {
          // Innerhalb der nicht ausgewerteten Kinder nach Jahrgang, Geschlecht, und Nachnamen sortieren
          // JahrgangVergleich: Jüngere vor Älteren
          final jahrgangVergleich = b.jahrgang.compareTo(a.jahrgang);
          if (jahrgangVergleich != 0) return jahrgangVergleich;
          // GeschlechtVergleich: Weiblich vor Männlich
          final geschlechtVergleich = b.geschlecht.compareTo(a.geschlecht);
          if (geschlechtVergleich != 0) return geschlechtVergleich;

          return a.nachname.compareTo(b.nachname);
        }

        // Bereits ausgewertete Kinder: Nur nach Nachnamen sortieren
        return a.nachname.compareTo(b.nachname);
      });
  }
}


/****************************************
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class KindRepository {
  // Erstellt ein Kind-Objekt aus der Datenbank-Daten (ParseObject)
  Kind createKindFromParse(ParseObject parseObject) {
    return Kind(
      objectId: parseObject.get<String>('objectId') ?? '',
      vorname: parseObject.get<String>('Vorname') ?? '',
      nachname: parseObject.get<String>('Nachname') ?? '',
      jahrgang: parseObject.get<String>('Jahrgang') ?? '',
      geschlecht: parseObject.get<String>('Geschlecht') ?? '',
      erreichtePunkte: parseObject.get<int>('Punkte') ?? 0,
      bezahlt: parseObject.get<bool>('bezahlt') ?? false,
      riegenNummer: parseObject.get<int>('RiegenNummer') ?? 0,
    );
  }

  // Speichert ein Kind-Objekt in die Back4App-Datenbank
  Future<void> saveKindToDatabase(Kind kind) async {
    final ParseObject parseKind = ParseObject('Kind')
      ..set('Vorname', kind.vorname)
      ..set('Nachname', kind.nachname)
      ..set('Jahrgang', kind.jahrgang)
      ..set('Geschlecht', kind.geschlecht)
      ..set('Punkte', kind.erreichtePunkte)
      ..set('bezahlt', kind.bezahlt)
      ..set('RiegenNummer', kind.riegenNummer);

    if (kind.objectId.isNotEmpty) {
      // Wenn die objectID existiert, setze sie, um das bestehende Objekt zu aktualisieren
      parseKind.objectId = kind.objectId;
    }

    // Speichere das Kind-Objekt in die Datenbank
    final ParseResponse response = await parseKind.save();

    if (response.success) {
      print('Kind erfolgreich gespeichert.');
    } else {
      print('Fehler beim Speichern des Kinds: ${response.error?.message}');
    }
  }

  // Methode zum Laden eines Kindes anhand des Namens und Jahrgangs aus der Datenbank
  Future<Kind?> loadKindFromDatabase(
      String vorname, String nachname, String jahrgang) async {
    final QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('Kind'))
          ..whereEqualTo('Vorname', vorname)
          ..whereEqualTo('Nachname', nachname)
          ..whereEqualTo('Jahrgang', jahrgang);

    final ParseResponse response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      return createKindFromParse(response.results!.first);
    } else {
      print(
          'Kein Kind gefunden mit Vorname: $vorname, Nachname: $nachname, Jahrgang: $jahrgang');
      return null;
    }
  }

  // NEU: Methode um alle Datensätze der Kind-Tabelle zu laden
  Future<List<Kind>> loadAllKinder() async {
    List<Kind> alleKinder = [];
    List<Kind> kinderTeilListe = [];
    int limit = 100; // Anzahl der Datensätze pro Seite
    int skip = 0; // Anzahl der Datensätze, die übersprungen werden

    bool hasMore = true;

    while (hasMore) {
      final query = QueryBuilder<ParseObject>(ParseObject('Kind'))
        ..setLimit(limit) // Setzt das Limit auf 100
        ..setAmountToSkip(skip); // Überspringt die ersten 'skip' Datensätze

      final response = await query.query();

      if (response.success && response.results != null) {
        kinderTeilListe = response.results!
            .map((parseObject) =>
                createKindFromParse(parseObject as ParseObject))
            .toList();
        skip +=
            limit; // Überspringt für die nächste Anfrage die bereits geladenen Datensätze
        if (kinderTeilListe.length < limit) {
          hasMore =
              false; // Wenn weniger als 'limit' Datensätze zurückgegeben wurden, gibt es keine weiteren Datensätze
        }
      } else {
        hasMore = false; // Bei Fehler oder keinem Ergebnis beenden
      }
      alleKinder.addAll(kinderTeilListe);
    }
    return alleKinder;
  }

  // NEU: Methode um alle Datensätze einer Riege zu laden
  Future<List<Kind>> ladeKinderDerRiege(int riegenNummer) async {
    List<Kind> alleKinder = [];

    final query = QueryBuilder<ParseObject>(ParseObject('Kind'))
      ..whereEqualTo(
          'RiegenNummer', riegenNummer); // sucht nach übertragener Riegennummer

    final response = await query.query();

    if (response.success && response.results != null) {
      alleKinder = response.results!
          .map((parseObject) => createKindFromParse(parseObject as ParseObject))
          .toList();
    }
    return alleKinder;
  }

  // NEU: Methode, um eine Liste von Kindern als Ganzes in die Datenbank zu speichern
  Future<void> saveKinderListeToDatabase(List<Kind> kinderListe) async {
    for (var kind in kinderListe) {
      await saveKindToDatabase(kind); // Verwendet die vorhandene Methode zum Speichern eines einzelnen Kindes
    }
  }
}
****************************************/