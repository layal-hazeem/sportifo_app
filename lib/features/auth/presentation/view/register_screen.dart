import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/app_image_picker.dart';
import '../../../../core/helpers/app_validators.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';
import '../view_model/register/register_cubit.dart';
import '../view_model/register/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// Form keys for validation
final _step1FormKey = GlobalKey<FormState>();
final _step2FormKey = GlobalKey<FormState>();

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  // Text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _selectedProfilePic;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void login() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  // Go to next step or OTP selection
  void nextStep() {
    if (currentPage == 0) {
      if (_step1FormKey.currentState!.validate()) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (_step2FormKey.currentState!.validate()) {
        showOtpChoice();
      }
    }
  }

  // Send data to Cubit
  void _submitRegistration(String otpMethod) {
    Navigator.pop(context);

    context.read<RegisterCubit>().registerUser(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      otpMethod: otpMethod,
      profilePic: _selectedProfilePic,
    );
  }

  // OTP method bottom sheet
  void showOtpChoice() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.chooseOtpMethod,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(l10n.viaEmail),
                onTap: () => _submitRegistration('email'),
              ),

              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(l10n.viaPhone),
                onTap: () => _submitRegistration('phone'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.otpScreen,
              arguments: _emailController.text.trim(),
            );
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        builder: (context, state) {
          return SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      Text(
                        l10n.createAccount,
                        style: const TextStyle(
                          fontSize: AppSizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Expanded(
                        child: PageView(
                          controller: _controller,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => currentPage = index);
                          },
                          children: [

                            /// STEP 1
                            SingleChildScrollView(
                              child: Form(
                                key: _step1FormKey,
                                child: Column(
                                  children: [
                                    buildField(
                                      l10n.firstName,
                                      l10n.enterFirstName,
                                      Icons.person_outline,
                                      controller: _firstNameController,
                                      validator: (val) =>
                                          AppValidators.validateRequired(val, message: "Required field"),
                                    ),
                                    buildField(
                                      l10n.lastName,
                                      l10n.enterLastName,
                                      Icons.person_outline,
                                      controller: _lastNameController,
                                      validator: (val) =>
                                          AppValidators.validateRequired(val, message: "Required field"),
                                    ),
                                    buildField(
                                      l10n.email,
                                      l10n.enterEmail,
                                      Icons.email_outlined,
                                      controller: _emailController,
                                      validator: (val) =>
                                          AppValidators.validateEmail(val, message: "Required field"),
                                    ),
                                    buildField(
                                      l10n.phone,
                                      l10n.enterPhone,
                                      Icons.phone_outlined,
                                      controller: _phoneController,
                                      validator: (val) =>
                                          AppValidators.validatePhone(val, message: "Required field"),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// STEP 2
                            SingleChildScrollView(
                              child: Form(
                                key: _step2FormKey,
                                child: Column(
                                  children: [
                                    buildField(
                                      l10n.password,
                                      l10n.passwordHint,
                                      Icons.visibility_off_outlined,
                                      isPassword: true,
                                      controller: _passwordController,
                                      validator: (val) =>
                                          AppValidators.validatePassword(val, message: "Required field"),
                                    ),

                                    buildField(
                                      l10n.confirmPassword,
                                      l10n.confirmPassword,
                                      Icons.visibility_off_outlined,
                                      isPassword: true,
                                      controller: _confirmPasswordController,
                                      validator: (val) =>
                                          AppValidators.validateConfirmPassword(
                                            val,
                                            _passwordController.text,
                                            message: "Required field",
                                          ),
                                    ),

                                    const SizedBox(height: 25),

                                    /// Profile Image (same style as CompleteProfile)
                                    Column(
                                      children: [
                                        Text(
                                          l10n.profilePicture,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),

                                        const SizedBox(height: 15),

                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 55,
                                              backgroundColor: AppColors.background,
                                              backgroundImage: _selectedProfilePic != null
                                                  ? FileImage(_selectedProfilePic!)
                                                  : null,
                                              child: _selectedProfilePic == null
                                                  ? const Icon(
                                                Icons.person,
                                                size: 55,
                                                color: AppColors.hintText,
                                              )
                                                  : null,
                                            ),

                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: CircleAvatar(
                                                backgroundColor: AppColors.primaryBtn,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  onPressed: () async {
                                                    final File? pickedImage = await AppImagePicker
                                                        .showImageSourceDialog(
                                                        context);

                                                    // إذا اختار صورة، نحدث المتغير ونعمل setState لكي تظهر الشاشة الصورة الجديدة
                                                    if (pickedImage != null) {
                                                      setState(() {
                                                        _selectedProfilePic =
                                                            pickedImage;
                                                      });
                                                    };
                                                  }
                                                ),

                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        l10n.termsText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.hintText,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBtn,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: nextStep,
                        child: Text(
                          currentPage == 0 ? l10n.next : l10n.register,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (currentPage == 1)
                        TextButton(
                          onPressed: () {
                            _controller.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(l10n.back),
                        ),
                    ],
                  ),
                ),

                if (state is RegisterLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBtn,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildField(
      String label,
      String hint,
      IconData icon, {
        bool isPassword = false,
        required TextEditingController controller,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        CustomNeumorphicField(
          hint: hint,
          icon: icon,
          isPassword: isPassword,
          controller: controller,
          validator: validator,
        ),
      ],
    );
  }
}