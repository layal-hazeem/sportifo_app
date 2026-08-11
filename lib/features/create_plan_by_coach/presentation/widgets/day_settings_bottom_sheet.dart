import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';

class DaySettingsBottomSheet extends StatefulWidget {
  final PlanDayUiModel day;

  const DaySettingsBottomSheet({super.key, required this.day});

 static Future<bool?> show(
  BuildContext context,
  PlanDayUiModel day,
) async {
  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DaySettingsBottomSheet(day: day);
    },
  );
}

  @override
  State<DaySettingsBottomSheet> createState() => _DaySettingsBottomSheetState();
}

class _DaySettingsBottomSheetState extends State<DaySettingsBottomSheet> {
  late TextEditingController setsController;
  late TextEditingController repsController;
  bool applyToAll = false;

  @override
  void initState() {
    super.initState();

    setsController = TextEditingController(
      text: widget.day.defaultSets?.toString() ?? "",
    );

    repsController = TextEditingController(
      text: widget.day.defaultReps?.toString() ?? "",
    );
     applyToAll = false;
  }

  @override
  void dispose() {
    setsController.dispose();
    repsController.dispose();

    super.dispose();
  }

void save() {

  widget.day.defaultSets =
      int.tryParse(setsController.text.trim());

  widget.day.defaultReps =
      int.tryParse(repsController.text.trim());


  Navigator.pop(
    context,
    applyToAll,
  );
}

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextField(
        controller: controller,

        keyboardType: TextInputType.number,

        decoration: InputDecoration(
          labelText: label,

          filled: true,

          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),

            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 45,
              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,

                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(.12),

                borderRadius: BorderRadius.circular(22),
              ),

              child: const Icon(
                Icons.tune_rounded,

                size: 35,

                color: AppColors.primaryBtn,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "${widget.day.name} Settings",

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "These values will be used for resistance exercises without custom settings",

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 25),

            inputField("Default Sets", setsController),

            inputField("Default Reps", repsController),

            CheckboxListTile(
  value: applyToAll,

  activeColor: AppColors.primaryBtn,

  onChanged: (value){
    setState(() {
      applyToAll = value ?? false;
    });
  },

title: const Text(
  "Apply to all resistance exercises",
  style: TextStyle(
    fontWeight: FontWeight.w600,
  ),
),

subtitle: const Text(
  "Update sets and reps for every resistance exercise in this day",
),

  contentPadding: EdgeInsets.zero,
),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: save,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "Save Settings",

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
