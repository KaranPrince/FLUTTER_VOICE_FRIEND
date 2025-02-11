import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/screens/main_screen.dart';
import 'package:flutter_voice_friend/services/animation_controller_service.dart';
import 'package:flutter_voice_friend/services/connection_service.dart';
import 'package:flutter_voice_friend/services/session_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

import 'package:flutter_voice_friend/activities.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:flutter_voice_friend/models/session.dart';
import 'package:flutter_voice_friend/services/audio_service.dart';
import 'package:flutter_voice_friend/services/speech_service.dart';
import 'package:flutter_voice_friend/services/user_service.dart';
import 'package:flutter_voice_friend/services/llm_service.dart';

late Isar isar;

Random random = Random();
const infoColor = Color.fromRGBO(69, 0, 0, 1);
const textColor = Color.fromRGBO(255, 255, 255, 1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  final docsDir = await getApplicationDocumentsDirectory();

  Config.openaiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  Config.deepgramApiKey = dotenv.env['DEEPGRAM_API_KEY'] ?? '';

  if (Config.openaiApiKey.isEmpty || Config.deepgramApiKey.isEmpty) {
    throw Exception('API keys are missing in the .env file');
  }

  isar = await Isar.open([ActivitySchema, SessionSchema],
      directory: docsDir.path, name: "demo");
  await syncActivities(isar);

  runApp(
    Phoenix(
      child: const FlutterVoiceFriendDemoApp(),
    ),
  );
}

class FlutterVoiceFriendDemoApp extends StatelessWidget {
  const FlutterVoiceFriendDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SessionService>(
          create: (_) => SessionService(isar: isar),
        ),
        Provider<AudioService>(
          create: (_) => AudioService(),
        ),
        Provider<SpeechService>(
          create: (_) => SpeechService(),
        ),
        ChangeNotifierProvider<UserService>(
          create: (_) => UserService(),
        ),
        Provider<LLMService>(
          create: (_) => LLMService(),
        ),
        Provider<AnimationControllerService>(
          create: (_) => AnimationControllerService(),
        ),
        Provider<ConnectionService>(
          create: (_) => ConnectionService(),
        ),
      ],
      child: MaterialApp(
        title: 'FlutterVoiceFriend',
        debugShowCheckedModeBanner: false, // Disable the debug banner

        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: MainScreen(isar: isar),
      ),
    );
  }
}
