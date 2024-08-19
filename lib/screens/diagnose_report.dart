import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseReportScreen extends StatefulWidget {
  const DiagnoseReportScreen({super.key});

  @override
  State<DiagnoseReportScreen> createState() => _DiagnoseReportScreenState();
}

class _DiagnoseReportScreenState extends State<DiagnoseReportScreen> {
  // DECLARE INSTANCE VARIABLES
  late String quizType;

  // FUTURE THAT HOLDS THE STATE OF THE RESULT LOADING PROCESS
  late Future<void> _resultFuture;

  @override
  void initState() {
    super.initState();
    // LOAD THE RESULT OF QUIZES WHEN THE WIDGET IS INITIALIZED
    _resultFuture = _loadResult();
  }

  Future<void> _loadResult() async {
    switch (quizType) {
      case 'quiz1':
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    // RETRIEVE THE ARGUMENTS PASSED FROM THE PREVIOUS SCREEN
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // INITIALIZE INSTANCE VARIABLES WITH THE ARGUMENTS
    quizType = arguments['quizType'];

    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _resultFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return const Stack(children: []);
              },
            );
          },
        ),
      ),
    );
  }
}
