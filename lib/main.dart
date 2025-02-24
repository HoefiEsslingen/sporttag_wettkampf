import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'src/riegen_wahl.dart';
import 'src/wettbewerb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Logging ermöglichen
  Logger.level = Level.debug;

  // Prüfen, ob gespeicherte Daten vorhanden sind
  final prefs = await SharedPreferences.getInstance();
  final savedRiegenNummer = prefs.getInt('riegenNummer');
  final savedWettbewerbsTyp = prefs.getString('wettbewerbsTyp');

  // möglicherweise gespeicherte Informationen an die App übergeben
  runApp(MainApp(
    savedRiegenNummer: savedRiegenNummer,
    savedWettbewerbsTyp: savedWettbewerbsTyp,
  ));
}

class MainApp extends StatelessWidget {
  final int? savedRiegenNummer;
  final String? savedWettbewerbsTyp;

  // falls keine gespeicherten Informationen vorhanden sind,
  // werden diese nicht übergeben, sind somit null
  const MainApp({super.key, this.savedRiegenNummer, this.savedWettbewerbsTyp});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Entfernt das "Debug"-Logo
      theme: ThemeData.light().copyWith(
          primaryColor: const Color.fromARGB(255, 241, 79, 15),
          scaffoldBackgroundColor: const Color.fromARGB(255, 246, 65, 10),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 246, 65, 10),    //Colors.amber, //
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 38.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              textStyle: const TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: Colors.green),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodySmall: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),  
          ),
     ),
     // nach der Pause im Zehnkampf soll die App wieder an der Stelle starten,
     // wo die Riege pausiert hat
      initialRoute: savedRiegenNummer != null && savedWettbewerbsTyp != null
          ? 'wettbewerb'
          : 'home',
      routes: {
        'home': (context) => const Riegenwahl(),
        'wettbewerb': (context) => Wettbewerb(
              riegenNummer: savedRiegenNummer ?? 1,
              wettbewerbsTyp: savedWettbewerbsTyp ?? 'Zehnkampf',
            ),
      },
    );
  }
}
