import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pesagem_frangos/models/peso_padrao.dart';
import 'package:pesagem_frangos/ui/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences mPrefs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  mPrefs = await SharedPreferences.getInstance();
  List<String> padraoMacho = mPrefs.getStringList("padraoMacho") ?? [];
  List<String> padraoFemea = mPrefs.getStringList("padraoFemea") ?? [];
  if(padraoMacho.length == 0) {
    mPrefs.setStringList("padraoMacho", PesoPadrao.padraoMacho);
  }

  if(padraoFemea.length == 0) {
    mPrefs.setStringList("padraoFemea", PesoPadrao.padraoFemea);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      title: 'Pesagem',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        Locale('pt', 'BR'),
      ],
    );
  }
}
