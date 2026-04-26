import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'study_store.dart';

/// Учёт секунд с открытым экраном плана или темы (обновление UI в реальном времени).
class PlanSessionTracker extends ChangeNotifier {
  PlanSessionTracker._();
  static final PlanSessionTracker instance = PlanSessionTracker._();

  String? _planId;
  String? _topic;
  DateTime? _started;
  Timer? _tick;

  String? get activePlanId => _planId;
  String? get activeTopic => _topic;

  int get liveElapsedSeconds {
    if (_started == null) return 0;
    return DateTime.now().difference(_started!).inSeconds;
  }

  void startPlanList(String planId) {
    _stopTick();
    _planId = planId;
    _topic = null;
    _started = DateTime.now();
    _startTick();
    _safeNotify();
  }

  void startTopic(String planId, String topic) {
    _stopTick();
    _planId = planId;
    _topic = topic;
    _started = DateTime.now();
    _startTick();
    _safeNotify();
  }

  void stop() {
    _stopTick();
    _planId = null;
    _topic = null;
    _started = null;
    _safeNotify();
  }

  void _startTick() {
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_planId == null || _started == null) return;
      StudyStore.instance.addEngagementTick(_planId!, topic: _topic);
      _safeNotify();
    });
  }

  void _stopTick() {
    _tick?.cancel();
    _tick = null;
  }

  void _safeNotify() {
    if (!hasListeners) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    final canNotifyNow =
        phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks;
    if (canNotifyNow) {
      notifyListeners();
      return;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }
}
