import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class CustomNeumorphicField extends StatefulWidget {
  final String hint;
  final IconData? icon;
  final String? iconPath;
  final bool isPassword;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomNeumorphicField({
    super.key,
    required this.hint,
    this.icon,
    this.isPassword = false,
    this.iconPath,
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
        color: context.backgroundColor,
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
          hintStyle: TextStyle(
            color: AppColors.hintText,
            fontSize: AppSizes.hintFontSize,
          ),

          prefixIcon: widget.iconPath != null
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    widget.iconPath!,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryBtn,
                      BlendMode.srcIn,
                    ),
                    width: 15,
                    height: 15,
                  ),
                )
              : widget.icon != null
              ? Icon(widget.icon, color: AppColors.hintText, size: 20)
              : null,

          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.hintText,
                    size: 20,
                  ),
                  onPressed: () {
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
