import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class CoachesFilterBottomSheet extends StatefulWidget {
  final int? initialGender;
  final int? initialMinExp;
  final int? initialMaxExp;
  final Function(int? gender, int? minExp, int? maxExp) onApply;

  const CoachesFilterBottomSheet({
    super.key,
    required this.initialGender,
    required this.initialMinExp,
    required this.initialMaxExp,
    required this.onApply,
  });

  @override
  State<CoachesFilterBottomSheet> createState() => _CoachesFilterBottomSheetState();
}

class _CoachesFilterBottomSheetState extends State<CoachesFilterBottomSheet> {
  int? _selectedGender;
  int? _minExp;
  int? _maxExp;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
    _minExp = widget.initialMinExp;
    _maxExp = widget.initialMaxExp;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.filter_coaches,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(l10n.coach_gender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildChipFilter(
                label: l10n.all,
                isSelected: _selectedGender == null,
                onTap: () => setState(() => _selectedGender = null),
              ),
              const SizedBox(width: 8),
              _buildChipFilter(
                label: l10n.coach_male,
                isSelected: _selectedGender == 1,
                onTap: () => setState(() => _selectedGender = 1),
              ),
              const SizedBox(width: 8),
              _buildChipFilter(
                label: l10n.coach_female,
                isSelected: _selectedGender == 2,
                onTap: () => setState(() => _selectedGender = 2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.years_sports_exp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _minExp?.toString(),
                  decoration: _buildInputDecoration(l10n.min_limit_year),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _minExp = int.tryParse(value),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  initialValue: _maxExp?.toString(),
                  decoration: _buildInputDecoration(l10n.max_limit_year),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _maxExp = int.tryParse(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onApply(null, null, null);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFFF6B35)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.reset, style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold)), // 🔥 إعادة تعيين
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedGender, _minExp, _maxExp);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFFF6B35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(l10n.apply_filters, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // 🔥 تطبيق الفلاتر
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipFilter({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.12) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[500]?.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6B35)),
      ),
    );
  }
}