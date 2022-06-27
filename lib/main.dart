import 'package:flutter/material.dart';
import 'package:okta_saml_new/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /// call inti function from auth service chapter-7 min 30.50
  await AuthService.instance.init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // const MyApp({Key? key}) : super(key: key);
  /// Will go to landing page
  // MyApp() {
  //   AuthService.instance.init();
  // }
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

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
        primarySwatch: Colors.blue,
      ),
      home: SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (() async {
                    final result = await AuthService.instance.login();
                    if(result != 'Success') {
                      final snackBar = SnackBar(content: Text(result));

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }

                    // final message = await AuthService.instance.login();
                    // if (message == 'Success') {
                    //   print('Yes');
                    // } else {
                    //   print('No');
                    // }
                  }),
                  child: const Text('Sing In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

