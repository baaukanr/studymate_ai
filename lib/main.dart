import 'package:flutter/widgets.dart';

import 'data/study_store.dart';
import 'studymate_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StudyStore.instance.load();
  runApp(const StudyMateApp());
}
