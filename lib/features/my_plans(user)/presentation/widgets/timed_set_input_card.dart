import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
class TimedSetInputCard extends StatefulWidget {
  final int currentSet;
  final int totalSets;
  final String targetDuration; // مثال: "1:00"
  final TextEditingController durationController;
  final bool isPaused;
  final bool isLoading;
  final VoidCallback onLogSet;
  final VoidCallback onSkipSet;
  final ValueChanged<bool>? onTimerStateChanged; // 🔥 إخبار الشاشة بحالة المؤقت لتجميد الـ GIF
  final bool autoStart; // 🔥 تشغيل تلقائي بعد العد التنازلي

  const TimedSetInputCard({
    super.key,
    required this.currentSet,
    required this.totalSets,
    required this.targetDuration,
    required this.durationController,
    required this.isPaused,
    required this.isLoading,
    required this.onLogSet,
    required this.onSkipSet,
    this.onTimerStateChanged,
    this.autoStart = false,
  });

  @override
  State<TimedSetInputCard> createState() => _TimedSetInputCardState();
}

class _TimedSetInputCardState extends State<TimedSetInputCard> {
  late int _targetSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _initTime();

    // 🔥 تفعيل التشغيل التلقائي
    if (widget.autoStart && !widget.isPaused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startTimer();
      });
    }
  }

  @override
  void didUpdateWidget(covariant TimedSetInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentSet != widget.currentSet) {
      _stopTimer();
      _initTime();
      if (widget.autoStart && !widget.isPaused) {
        _startTimer();
      }
    }

    // إيقاف التايمر إذا كبس المتدرب Pause العام للتطبيق
    if (widget.isPaused && !oldWidget.isPaused && _isRunning) {
      _stopTimer();
    }

    // 🔥 ضفنا هاد الاتجاه الناقص: لما يرفع المتدرب الـ Pause (يعني isPaused
    // رجعت false)، لازم العداد يكمل لحاله فوراً - بدون هاد السطر، ما كان
    // في أي طريقة يرجع يشتغل غير زر التشغيل اليدوي (يلي هلق شلناه بالكامل
    // بناءً على طلبك: البوز العام هو المتحكم الوحيد).
    if (!widget.isPaused && oldWidget.isPaused && !_isRunning) {
      _startTimer();
    }
  }

  void _initTime() {
    _targetSeconds = _parseDuration(widget.targetDuration);
    _remainingSeconds = _targetSeconds;
    widget.durationController.text = _formatTime(_remainingSeconds);
  }

  int _parseDuration(String durationStr) {
    List<String> parts = durationStr.split(':');
    int m = int.tryParse(parts[0]) ?? 1;
    int s = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return (m * 60) + s;
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return "00:00";
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    if (widget.onTimerStateChanged != null) widget.onTimerStateChanged!(true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          int actualPlayed = _targetSeconds - _remainingSeconds;
          widget.durationController.text = _formatTime(actualPlayed > 0 ? actualPlayed : _targetSeconds);
        });
      } else {
        _stopTimer();
        widget.onLogSet();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() => _isRunning = false);
      if (widget.onTimerStateChanged != null) widget.onTimerStateChanged!(false);
    }
  }

  void _add15Seconds() {
    setState(() {
      _remainingSeconds += 15;
      _targetSeconds += 15;
    });
  }

  void _subtract15Seconds() {
    if (_remainingSeconds > 15) {
      setState(() {
        _remainingSeconds -= 15;
        _targetSeconds -= 15;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double progress = _targetSeconds > 0 ? (_remainingSeconds / _targetSeconds) : 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${l10n.set.toUpperCase()} ${widget.currentSet} /${widget.totalSets}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryBtn),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: AppColors.hintText, size: 22),
                onPressed: widget.isPaused || widget.isLoading ? null : widget.onSkipSet,
                tooltip: l10n.skip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 125,
                height: 125,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.primaryBtn.withOpacity(0.1),
                  color: AppColors.primaryBtn,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      height: 1.0,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.remaining,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAdjustButton("- 15s", _subtract15Seconds),
              const SizedBox(width: 24),
              // 🔥 شلنا زر التشغيل/الإيقاف اليدوي (كان دائرة بالنص) بناءً على
              // طلبك - البوز العام (Pause) تبع الشاشة هو المتحكم الوحيد
              // بالعداد هلق، بمقاومة ولا كارديو، بدون زر إضافي هون يلخبط.
              const SizedBox(width: 24),
              _buildAdjustButton("+ 15s", _add15Seconds),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                _stopTimer();
                // 🔥 حساب الوقت الفعلي اللي لعبه المتدرب بدقة تامة!
                int actualPlayed = _targetSeconds - _remainingSeconds;
                widget.durationController.text = _formatTime(actualPlayed);
                widget.onLogSet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn.withOpacity(0.12),
                foregroundColor: AppColors.primaryBtn,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: widget.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppColors.primaryBtn, strokeWidth: 2))
                  : Text(l10n.logCompletedSet, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: widget.isPaused ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }
}