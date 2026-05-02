import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';

class CustomNeumorphicField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomNeumorphicField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.onChanged,
    this.keyboardType,
    this.controller,
    this.validator,
  });

  @override
  State<CustomNeumorphicField> createState() => _CustomNeumorphicFieldState();
}

class _CustomNeumorphicFieldState extends State<CustomNeumorphicField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // إذا كان الحقل كلمة مرور، نجعله مخفياً كبداية
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -5,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(AppSizes.borderRadius),
        ),
        color: AppColors.background,
      ),
      child: TextFormField(
        // ✅ إضافة widget. قبل كل المتغيرات هنا
        controller: widget.controller,
        validator: widget.validator,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: widget.hint, // ✅ أضفنا widget.
          hintStyle: const TextStyle(
            color: AppColors.hintText,
            fontSize: AppSizes.hintFontSize,
          ),

         prefixIcon: Icon(widget.icon, color: AppColors.hintText, size: 20),
//           prefixIcon: Icon(widget.icon, color: AppColors.hintText, size: 20),

          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.hintText,
              size: 20,
            ),
            onPressed: () {
              // تغيير الحالة عند الضغط على العين
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,

          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          errorStyle: const TextStyle(fontSize: 12, height: 0.8),
        ),
      ),
    );
  }
}