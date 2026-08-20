import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class TimedSetInputCard extends StatefulWidget {
  final int currentSet;
  final int totalSets;
  final String targetDuration; // Example: "1:00"
  final TextEditingController durationController;
  final bool isPaused;
  final bool isLoading;
  final VoidCallback onLogSet;
  final VoidCallback onSkipSet;
  final ValueChanged<bool>? onTimerStateChanged; // Notify screen of timer state to freeze GIF
  final bool autoStart; // Auto start after countdown

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

    // Enable auto start
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

    // Stop timer if user presses general Pause
    if (widget.isPaused && !oldWidget.isPaused && _isRunning) {
      _stopTimer();
    }

    // Resume timer automatically when Pause is lifted
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
          widget.durationController.text = _formatTime(
            actualPlayed > 0 ? actualPlayed : _targetSeconds,
          );
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
      if (widget.onTimerStateChanged != null)
        widget.onTimerStateChanged!(false);
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
    double progress = _targetSeconds > 0
        ? (_remainingSeconds / _targetSeconds)
        : 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBtn.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${l10n.set.toUpperCase()} ${widget.currentSet} /${widget.totalSets}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBtn,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: AppColors.hintText,
                  size: 22,
                ),
                onPressed: widget.isPaused || widget.isLoading
                    ? null
                    : widget.onSkipSet,
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
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: context.textColor,
                      height: 1.0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.remaining,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAdjustButton(l10n.minus15s, _subtract15Seconds, context),
              const SizedBox(width: 48), // Added spacing since center button was removed
              _buildAdjustButton(l10n.plus15s, _add15Seconds, context),
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
                // Calculate actual played time accurately
                int actualPlayed = _targetSeconds - _remainingSeconds;
                widget.durationController.text = _formatTime(
                  actualPlayed,
                );
                widget.onLogSet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn.withOpacity(0.12),
                foregroundColor: AppColors.primaryBtn,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.primaryBtn,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                l10n.logCompletedSet,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(String label, VoidCallback onTap, BuildContext context) {
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
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}