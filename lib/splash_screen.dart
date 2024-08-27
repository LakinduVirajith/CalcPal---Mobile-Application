import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // SET CUSTOM STATUS BAR COLOR
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset('assets/icons/app-icon.jpg'),
                ),
              ),
              const SizedBox(height: 64.0),
              const SpinKitWave(
                color: Colors.black,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
