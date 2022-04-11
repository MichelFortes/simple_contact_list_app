import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_contact_list_app/config/messages.dart';
import 'package:simple_contact_list_app/screen/login_screen.dart';

void main() {

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      translations: Messages(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale.fromSubtags(languageCode: "en", countryCode: "US"),
      theme: ThemeData(
        primarySwatch: Colors.brown,
        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.brown,
          centerTitle: true
        ),
        textTheme: GoogleFonts.petitFormalScriptTextTheme(Theme.of(context).textTheme.copyWith(
          headline1: const TextStyle(fontSize: 28),
          headline2: const TextStyle(fontSize: 22),
          subtitle1: const TextStyle(fontSize: 16),
          subtitle2: const TextStyle(fontSize: 16),
          button: const TextStyle(fontSize: 16),
        )),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 1, color: Colors.brown.shade500),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(width: 1, color: Colors.brown.shade300),
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(width: 1, color: Colors.brown.shade300),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

