import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'config/app_features.dart';
import 'data/study_store.dart';
import 'firebase_options.dart';
import 'studymate_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kUseFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await StudyStore.instance.load();
  runApp(const StudyMateApp());
}
