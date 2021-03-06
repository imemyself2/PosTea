import 'package:flutter/material.dart';
import 'package:postea_frontend/colors.dart';
import 'package:postea_frontend/data_models/process_theme.dart';
import 'package:postea_frontend/pages/homepage.dart';
// import 'package:postea_frontend/pages/loggedIn.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'data_models/timer.dart';
// import 'pages/homepage.dart';
import 'data_models/route_generator.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

int profileId = 0;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  profileId = prefs.getInt('profileID') ?? 0;
  await Firebase.initializeApp();
  print(profileId);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => ProcessTheme(),
      lazy: false,
    ),
  ], child: PosTea()));
}

class PosTea extends StatefulWidget {
  @override
  _PosTeaState createState() => _PosTeaState();
}

class _PosTeaState extends State<PosTea> {
  var firstScreen = '/login';

  void checkUserLoggedIn() async {
    User user = FirebaseAuth.instance.currentUser;
    // print("UID IS: " + user.uid);

    if (user != null) {
      setState(() {
        firstScreen = '/home';
      });
    } else {
      setState(() {
        firstScreen = '/login';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ThemeData lightTheme = ThemeData(
    //   canvasColor: bgColor,
    //   cardColor: Colors.white,
    //   primaryColorLight: topicPillLight1,
    //   primaryColorDark: topicPillLight2,
    //   buttonColor: Colors.blueGrey[800],
    //   bottomAppBarColor: Colors.grey[300],
    //   accentColor: Colors.white,
    //   textTheme: TextTheme(
    //       headline1: TextStyle(
    //           fontSize: 16, color: Colors.black, fontWeight: FontWeight.normal),
    //       headline2: TextStyle(
    //           fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
    //       headline3: TextStyle(fontSize: 13, color: Colors.black),
    //       headline4: TextStyle(fontSize: 18, color: Colors.black),
    //       headline5: TextStyle(fontSize: 16, color: Colors.black),
    //       headline6: TextStyle(fontSize: 16, color: Colors.white),),
    // );

    // ThemeData darkTheme = ThemeData(
    //   canvasColor: bgColorDark,
    //   cardColor: postTileDark,
    //   primaryColorLight: topicPillDark1,
    //   primaryColorDark: topicPillDark2,
    //   bottomAppBarColor: topicPillDark1,
    //   buttonColor: topicPillDark1,
    //   accentColor: topicPillDark1,
    //   hintColor: Colors.grey[800],
    //   textTheme: TextTheme(
    //       headline1: TextStyle(
    //           fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
    //       headline2: TextStyle(
    //           fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
    //       headline3: TextStyle(fontSize: 13, color: Colors.white),
    //       headline4: TextStyle(fontSize: 18, color: Colors.white),
    //       headline5: TextStyle(fontSize: 16, color: Colors.white),
    //       headline6: TextStyle(fontSize: 16, color: Colors.white),)
    // );

    return Consumer<ProcessTheme>(
      builder: (context, value, child) {
        ThemeData lightTheme = ThemeData(
      canvasColor: bgColor,
      cardColor: Colors.white,
      primaryColorLight: topicPillLight1,
      primaryColorDark: topicPillLight2,
      buttonColor: Colors.blueGrey[800],
      bottomAppBarColor: Colors.grey[300],
      accentColor: Colors.white,
      textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 16 * value.fontSize.toDouble(), color: Colors.black, fontWeight: FontWeight.normal),
          headline2: TextStyle(
              fontSize: 15 * value.fontSize.toDouble(), fontWeight: FontWeight.bold, color: Colors.black),
          headline3: TextStyle(fontSize: 13 * value.fontSize.toDouble(), color: Colors.black),
          headline4: TextStyle(fontSize: 18 * value.fontSize.toDouble(), color: Colors.black),
          headline5: TextStyle(fontSize: 16 * value.fontSize.toDouble(), color: Colors.black),
          headline6: TextStyle(fontSize: 16 * value.fontSize.toDouble(), color: Colors.white),),
    );

    ThemeData darkTheme = ThemeData(
      canvasColor: bgColorDark,
      cardColor: postTileDark,
      primaryColorLight: topicPillDark1,
      primaryColorDark: topicPillDark2,
      bottomAppBarColor: topicPillDark1,
      buttonColor: topicPillDark1,
      accentColor: topicPillDark1,
      hintColor: Colors.grey[800],
      textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 16 * value.fontSize.toDouble(), color: Colors.white, fontWeight: FontWeight.bold),
          headline2: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          headline3: TextStyle(fontSize: 13 * value.fontSize.toDouble(), color: Colors.white),
          headline4: TextStyle(fontSize: 18 * value.fontSize.toDouble(), color: Colors.white),
          headline5: TextStyle(fontSize: 16 * value.fontSize.toDouble(), color: Colors.white),
          headline6: TextStyle(fontSize: 16 * value.fontSize.toDouble(), color: Colors.white),)
    );
        return MaterialApp(
          darkTheme: darkTheme,
          theme: value.themeData == 1 ? lightTheme : darkTheme,
          debugShowCheckedModeBanner: false,
          title: "PosTea app",
          initialRoute: firstScreen,
          onGenerateRoute: Router.generateRoute,
          onGenerateInitialRoutes: (initialRoute) {
            return [
              Router.generateRoute(RouteSettings(
                  name: firstScreen, arguments: HomePage(profileID: profileId)))
            ];
          },
        );
      },
    );
  }
}
