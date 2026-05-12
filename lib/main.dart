import 'package:flutter/material.dart';
import 'menu.dart';
import 'Providers/app_settings.dart';
import "update_dialog.dart";

/*

https://chatgpt.com/c/69d23001-809c-8331-beb7-4958ff1124e8
https://chatgpt.com/c/69e68b54-fa70-8331-a748-dfa8ca8893d8
https://chatgpt.com/c/69ff32fd-abf0-83eb-bb5a-5750d70868fa
https://chatgpt.com/c/69e88532-edec-83eb-a681-6abb557f8100
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ////////////////////////////////////////////////////////////
  /// 🔥 INIT SETTINGS AVANT APP
  ////////////////////////////////////////////////////////////
  final settings = AppSettings();
  await settings.load();

  runApp(MyApp(settings: settings));
}

////////////////////////////////////////////////////////////
/// 🔥 ROOT APP
////////////////////////////////////////////////////////////
class MyApp extends StatefulWidget {
  final AppSettings settings;

  const MyApp({super.key, required this.settings});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppSettings settings;

  @override
  void initState() {
    super.initState();
    settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Big@Maths',

          ////////////////////////////////////////////////////////////
          /// 🌙 THEME
          ////////////////////////////////////////////////////////////
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.grey.shade100,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
          ),

          ////////////////////////////////////////////////////////////
          /// 🔠 TEXT SCALE GLOBAL
          ////////////////////////////////////////////////////////////
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(settings.textScale)),
              child: child!,
            );
          },
          initialRoute: '/',
          routes: {
            '/home': (context) => MyHomePage(), // MyHomePage(title: 'Accueil')
          },
          home: MyHomePage(),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔥 HOME PAGE
////////////////////////////////////////////////////////////
///
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      // Vérifie la mise à jour à l’ouverture de la page
      UpdateDialog(
        context: context,
        versionUrl:
            'https://backend-mega-maths-nodejs.vercel.app/version_json_apk',
      ).show();
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Big@Maths"),
      ),
      drawer: const SideMenu(),
      body: const Center(
        child: Text(
          "Bienvenue dans Big@Maths 📚",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
