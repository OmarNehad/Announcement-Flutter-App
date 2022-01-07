import 'package:flutter/material.dart';
import './screens/create_announcements_screen.dart';
import './screens/creat_user_screen.dart';
import '/screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.blueGrey[900],
        colorScheme: Theme.of(context).colorScheme.copyWith(
              secondary: Colors.blueGrey,
              primary: Colors.blueGrey[900],
              onSecondary: Colors.white,
              onPrimary: Colors.white,
            ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); //splashscreen
          }
          if (userSnapshot.hasData) {
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get(),
                builder: (cntx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  DocumentSnapshot data = snapshot.data!;
                  return HomeScreen(data['role'], data['grade']);
                });
          }
          return const AuthScreen();
        },
      ),
      routes: {
        CreatUserScreen.routeName: (ctx) => const CreatUserScreen(),
        CreateAnnouncement.routeName: (ctx) => const CreateAnnouncement(),
      },
    );
  }
}
