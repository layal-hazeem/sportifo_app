import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/plan_progress_model.dart';
import '../../data/repository/my_plans_repository.dart';
import '../../../workout/data/models/exercise_model.dart';
import 'active_workout_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
class ActiveWorkoutCubit extends Cubit<ActiveWorkoutState> {
  final MyPlansRepository _repository; // 👈 حقنا الـ Repo هنا

  ActiveWorkoutCubit(this._repository) : super(ActiveWorkoutInitial());

  List<ExerciseModel> _exercises = [];
  int _currentIndex = 0;
  final List<LoggedSetModel> _currentExerciseLoggedSets = [];
  final Map<int, List<LoggedSetModel>> _allWorkoutsLoggedSets = {};

  // 🔥 طابور بسيط لدفعات التمارين يلي فشل إرسالها للسيرفر (مافي نت مثلاً)
  // منحاول نعيد إرسالهن لاحقاً بدل ما تضيع
  final List<Map<String, dynamic>> _pendingSyncQueue = [];
  bool get hasPendingSyncs => _pendingSyncQueue.isNotEmpty;

  List<ExerciseModel> get exercises => _exercises;
  Map<int, List<LoggedSetModel>> get allLoggedSets => _allWorkoutsLoggedSets;

  void startWorkout(List<ExerciseModel> exercises, {int startIndex = 0}) {
    if (exercises.isEmpty) return;

    _exercises = exercises;
    _currentIndex = startIndex;

    // 🔥 إذا كان في سيتات قديمة محفوظة لهاد التمرين، رجعها!
    if (_allWorkoutsLoggedSets.containsKey(_currentIndex)) {
      _currentExerciseLoggedSets.clear();
      _currentExerciseLoggedSets.addAll(_allWorkoutsLoggedSets[_currentIndex]!);
    } else {
      _currentExerciseLoggedSets.clear();
    }

    emit(ActiveWorkoutInProgress(
      exercises: _exercises,
      currentIndex: _currentIndex,
      currentExercise: _exercises[_currentIndex],
      completedSets: List.from(_currentExerciseLoggedSets), // 👈 نمرر السيتات القديمة لتطلع عالشاشة
    ));
  }

  // 🔥 دالة تسجيل السيت: محلي فقط، بدون أي طلب سيرفر هون.
  // كل سيت بينحفظ بالذاكرة/الجلسة المحلية فوراً وبيحدّث الشاشة، وخلص.
  // الطلب الوحيد للسيرفر بيصير لما يخلص كل التمرين (شوف syncExerciseToServer).
  void logSet({required String weight, required String reps}) {
    _saveSetLocally(weight: weight, reps: reps, isSkipped: false);
  }

  // 🔥 بتنستدعى لما يخلص المستخدم كل سيتات التمرين. بتجمع كل السيتات
  // (غير المتخطاة - الباك إند ما بده يعرف عن الـ skip) بطلب واحد فقط
  // بصيغة sets[0], sets[1]... وترسله بالخلفية بدون ما توقف الشاشة.
  Future<void> syncExerciseToServer({required int planId, required ExerciseModel exercise}) async {
    final setsToSend = _currentExerciseLoggedSets.where((s) => !s.isSkipped).toList();
    if (setsToSend.isEmpty) return; // كل السيتات كانت skip، ما في شي نبعتو

    await _sendExerciseBatch(planId: planId, exercise: exercise, sets: setsToSend);
  }

  Future<void> _sendExerciseBatch({
    required int planId,
    required ExerciseModel exercise,
    required List<LoggedSetModel> sets,
  }) async {
    if (sets.isEmpty) return;
    try {
      final Map<String, dynamic> formMap = {
        'plan_id': planId.toString(),
        'exercise_id': exercise.id.toString(),
      };
      // جوا دالة _sendExerciseBatch في ملف active_workout_cubit.dart
      for (int i = 0; i < sets.length; i++) {
        // 🔥 هاد السطر بيشيل أي نقطتين أو أحرف (مثل "1:00") وبيحولها لرقم صحيح إجباري ليرضى السيرفر
        formMap['sets[$i][reps]'] = int.tryParse(sets[i].reps.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        formMap['sets[$i][weight]'] = sets[i].weight;
      }

      final result = await _repository.logExerciseActivity(FormData.fromMap(formMap));
      if (result is! Success) {
        _pendingSyncQueue.add({'planId': planId, 'exercise': exercise, 'sets': sets});
      }
    } catch (e) {
      // ⚠️ فشل الإرسال (مثلاً مافي نت) - منحتفظ بالدفعة كاملة بالطابور لنعيد المحاولة لاحقاً
      _pendingSyncQueue.add({'planId': planId, 'exercise': exercise, 'sets': sets});
    }
  }

  // 🔥 نقطة أمان: تحاول تبعت أي دفعات تمارين ما وصلت السيرفر قبل. لازم
  // تنستدعى عند نقاط مهمة (Save & Exit، Finish Workout) حتى ما تضيع الداتا.
  Future<void> retryPendingSync() async {
    if (_pendingSyncQueue.isEmpty) return;

    final itemsToRetry = List<Map<String, dynamic>>.from(_pendingSyncQueue);
    _pendingSyncQueue.clear();

    for (final item in itemsToRetry) {
      await _sendExerciseBatch(
        planId: item['planId'] as int,
        exercise: item['exercise'] as ExerciseModel,
        sets: item['sets'] as List<LoggedSetModel>,
      );
    }
  }

  // 🔥 دالة التخطي (Skip) لا تكلم السيرفر أبداً! (تلبية لطلب الباك إند)
  void skipSet() {
    _saveSetLocally(weight: "0", reps: "0", isSkipped: true);
  }

  // حفظ داخلي
  void _saveSetLocally({required String weight, required String reps, required bool isSkipped}) {
    int setIndex = _currentExerciseLoggedSets.length;
    _currentExerciseLoggedSets.add(LoggedSetModel(
      setIndex: setIndex,
      weight: weight,
      reps: reps,
      isSkipped: isSkipped,
    ));

    _allWorkoutsLoggedSets[_currentIndex] = List.from(_currentExerciseLoggedSets);

    if (state is ActiveWorkoutInProgress) {
      emit(ActiveWorkoutInProgress(
        exercises: _exercises,
        currentIndex: _currentIndex,
        currentExercise: _exercises[_currentIndex],
        completedSets: List.from(_currentExerciseLoggedSets),
      ));
    }
  }

  void nextExercise() {
    _allWorkoutsLoggedSets[_currentIndex] = List.from(_currentExerciseLoggedSets);
    if (_currentIndex < _exercises.length - 1) {
      _currentIndex++;
      _currentExerciseLoggedSets.clear();
      emit(ActiveWorkoutInProgress(
        exercises: _exercises,
        currentIndex: _currentIndex,
        currentExercise: _exercises[_currentIndex],
        completedSets: [],
      ));
    } else {
      emit(ActiveWorkoutCompleted());
    }
  }

  // 🔥 الدالة المحدثة مع "الفحص الذكي" لمنع التحايل
  Future<void> completeWorkout({required int planId, required int planDayId}) async {
    // 1. حفظ سيتات التمرين الحالي
    _allWorkoutsLoggedSets[_currentIndex] = List.from(_currentExerciseLoggedSets);
    await retryPendingSync();

    // 🛑 السحر هنا: الفحص الذكي 🛑
    // هل عدد التمارين اللي تفاعل معها المتدرب (لعبها أو تخطاها) يساوي إجمالي تمارين اليوم؟
    bool isDayFullyCompleted = _allWorkoutsLoggedSets.length == _exercises.length;

    if (isDayFullyCompleted) {
      // ✅ لعب كل التمارين -> نلون اليوم أخضر
      try {
        final progressResult = await _repository.fetchPlanProgress(planId);
        int realPlanDayId = planDayId;

        if (progressResult is Success<PlanProgressModel>) {
          final correctDay = progressResult.data.days.firstWhere(
                  (d) => d.id == planDayId,
              orElse: () => ProgressDayModel(id: 0, planDayId: planDayId, name: '', completed: false)
          );
          if (correctDay.id != 0) {
            realPlanDayId = correctDay.planDayId;
          }
        }

        // إرسال طلب الإنهاء للباك إند
        await _repository.markDayAsDone(planId: planId, planDayId: realPlanDayId);
        print("✅ API MARK-DONE SUCCESS: المتدرب أنهى جميع التمارين بشكل شرعي!");
      } catch (e) {
        print("Error marking day as done: $e");
      }
    } else {
      // ❌ نط لآخر تمرين بدون ما يلعب الباقي -> لا نلون اليوم!
      print("⚠️ تنبيه: المتدرب أنهى ${_allWorkoutsLoggedSets.length} تمارين فقط من أصل ${_exercises.length}. لن يتم تلوين اليوم بالأخضر!");
    }

    // تنظيف الذاكرة والانتقال للملخص في كلتا الحالتين
    await clearSessionLocally();
    emit(ActiveWorkoutCompleted());
  }
// =======================================================
  // 🔥 دوال الذاكرة المحلية (Session Management) 🔥
  // =======================================================

  // 1. دالة حفظ الجلسة (مع حفظ الأوزان والسيتات)
  Future<void> saveSessionLocally(int planId, int dayId, int exerciseIndex) async {
    // 🔥 نقطة أمان: منحاول نبعت أي سيتات فاتت المزامنة قبل ما نطلع من الشاشة
    retryPendingSync();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_plan_id', planId);
    await prefs.setInt('active_day_id', dayId);
    await prefs.setInt('active_exercise_index', exerciseIndex);

    // نحفظ السيتات اللي سجلناها حالياً
    _allWorkoutsLoggedSets[_currentIndex] = List.from(_currentExerciseLoggedSets);

    // تحويل كل السيتات لـ نص JSON لنقدر نحفظها بالموبايل
    Map<String, dynamic> dataToSave = {};
    _allWorkoutsLoggedSets.forEach((key, value) {
      dataToSave[key.toString()] = value.map((set) => {
        'setIndex': set.setIndex,
        'weight': set.weight,
        'reps': set.reps,
        'isSkipped': set.isSkipped,
      }).toList();
    });

    await prefs.setString('active_session_data', json.encode(dataToSave));
  }

  // 2. دالة فحص إذا في جلسة قديمة
  Future<Map<String, int>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    int? pId = prefs.getInt('active_plan_id');
    int? dId = prefs.getInt('active_day_id');
    int? eIndex = prefs.getInt('active_exercise_index');

    if (pId != null && dId != null && eIndex != null) {
      return {'plan_id': pId, 'day_id': dId, 'exercise_index': eIndex};
    }
    return null;
  }

  // 3. دالة استرجاع الجلسة والسيتات
  Future<void> restoreSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('active_session_data');

    _allWorkoutsLoggedSets.clear();
    _currentExerciseLoggedSets.clear();

    if (dataString != null) {
      Map<String, dynamic> decoded = json.decode(dataString);
      decoded.forEach((key, value) {
        int exIndex = int.parse(key);
        List<dynamic> setsList = value;
        _allWorkoutsLoggedSets[exIndex] = setsList.map((s) => LoggedSetModel(
          setIndex: s['setIndex'],
          weight: s['weight'].toString(),
          reps: s['reps'].toString(),
          isSkipped: s['isSkipped'] == true,
        )).toList();
      });
    }
  }

  // 4. دالة مسح الجلسة وتنظيف الكيوبيت
  Future<void> clearSessionLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_plan_id');
    await prefs.remove('active_day_id');
    await prefs.remove('active_exercise_index');
    await prefs.remove('active_session_data');

    _allWorkoutsLoggedSets.clear();
    _currentExerciseLoggedSets.clear();
  }
}