import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:ichat/screens/chat.dart';
import 'package:pointycastle/pointycastle.dart';
import 'screens/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login.dart';
import 'screens/retrieve.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

final iv = IV.fromLength(16);
Encrypter? encrypter;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'badrustuts', // id
    'High Importance Notifications', // title
    //'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// Firebase local notification plugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

//Firebase messaging
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // RSA keys
  RSAPublicKey pubkey = parsePublicKeyFromPem('''YOUR PUBLIC KEY HERE''');
  RSAPrivateKey privkey =
      parsePrivateKeyFromPem('''YOUR RSA PRIVATE KEY HERE''');

  encrypter = Encrypter(RSA(privateKey: privkey, publicKey: pubkey));

  runApp(App());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "MainNavigator");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,

      // Specify Darkmode and Lightmode themes
      theme: ThemeData(
        brightness: Brightness.light,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness:
              Brightness.light, // Ensure this matches ThemeData.brightness
        ).copyWith(surface: Colors.white),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness:
              Brightness.dark, // Ensure this matches ThemeData.brightness
        ).copyWith(surface: Colors.grey[900]),
      ),
      themeMode: ThemeMode.system,
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            if (FirebaseAuth.instance.currentUser?.uid == null) {
              // Show Login screen
              return Login();
            } else {
              // Return message screen
              return chatSc();
            }
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return const Loading();
        },
      ),
    );
  }
}
