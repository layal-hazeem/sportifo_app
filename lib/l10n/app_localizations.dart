import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sportifo'**
  String get appName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone Number'**
  String get emailOrPhone;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password ?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive an OTP code'**
  String get forgotPasswordDesc;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code sent to your email or phone number'**
  String get otpSubtitle;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Successes'**
  String get loginSuccess;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'A verification code has been sent'**
  String get otpSentMessage;

  /// No description provided for @verifiedOtp.
  ///
  /// In en, this message translates to:
  /// **'The code was successfully verified'**
  String get verifiedOtp;

  /// No description provided for @enterFullCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter full code'**
  String get enterFullCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendCodeIn;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully! Please login with your new password.'**
  String get passwordChangedSuccess;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @myPlans.
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get myPlans;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout '**
  String get workout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account ?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field  is required'**
  String get fieldRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred, please try again later'**
  String get unexpectedError;

  /// No description provided for @completeProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile Information'**
  String get completeProfileInfo;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @messageOfIncompleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Please complete all of the following information (weight, height, gender, date of birth)'**
  String get messageOfIncompleteInfo;

  /// No description provided for @bodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get bodyMeasurements;

  /// No description provided for @shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// No description provided for @chestCircumference.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chestCircumference;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// No description provided for @hipCircumference.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get hipCircumference;

  /// No description provided for @thighCircumference.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get thighCircumference;

  /// No description provided for @armCircumference.
  ///
  /// In en, this message translates to:
  /// **'Hand'**
  String get armCircumference;

  /// No description provided for @startingTheSportsJourney.
  ///
  /// In en, this message translates to:
  /// **'Starting the sports journey'**
  String get startingTheSportsJourney;

  /// No description provided for @measuermentsHint.
  ///
  /// In en, this message translates to:
  /// **'These measurements help us provide a more accurate analysis of your physical progress (optional)'**
  String get measuermentsHint;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving....'**
  String get saving;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterLastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enterEmail;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get enterPhone;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture (Optional)'**
  String get profilePicture;

  /// No description provided for @chooseOtpMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose OTP Method'**
  String get chooseOtpMethod;

  /// No description provided for @viaEmail.
  ///
  /// In en, this message translates to:
  /// **'Via Email'**
  String get viaEmail;

  /// No description provided for @viaPhone.
  ///
  /// In en, this message translates to:
  /// **'Via Phone'**
  String get viaPhone;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms & Conditions and Privacy Policy'**
  String get termsText;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your Home, Your Gym'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Access ready-made workout plans and a wide range of training videos.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Coach'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Chat with your coach and improve faster. Expert guidance is always available.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Smart Nutrition Plans'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Track your nutrition and improve your daily habits.'**
  String get onboardingDesc3;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get chat;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @enterEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email or phone number'**
  String get enterEmailOrPhone;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get error;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'about us'**
  String get aboutUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogout;

  /// No description provided for @logoutApproval.
  ///
  /// In en, this message translates to:
  /// **'Yes, log out'**
  String get logoutApproval;

  /// No description provided for @agreed.
  ///
  /// In en, this message translates to:
  /// **'Agreed'**
  String get agreed;

  /// No description provided for @resistance_training.
  ///
  /// In en, this message translates to:
  /// **'Resistance Training'**
  String get resistance_training;

  /// No description provided for @target_muscle.
  ///
  /// In en, this message translates to:
  /// **'Target Muscle'**
  String get target_muscle;

  /// No description provided for @how_to_perform.
  ///
  /// In en, this message translates to:
  /// **'How to perform'**
  String get how_to_perform;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @no_exercises_found.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get no_exercises_found;

  /// No description provided for @burn_fat.
  ///
  /// In en, this message translates to:
  /// **'Burn Fat'**
  String get burn_fat;

  /// No description provided for @build_muscle.
  ///
  /// In en, this message translates to:
  /// **'Build Muscle'**
  String get build_muscle;

  /// No description provided for @start_training.
  ///
  /// In en, this message translates to:
  /// **'Start Training'**
  String get start_training;

  /// No description provided for @no_categories_found.
  ///
  /// In en, this message translates to:
  /// **'No categories found.'**
  String get no_categories_found;

  /// No description provided for @default_workout_name.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get default_workout_name;

  /// No description provided for @saved_exercises.
  ///
  /// In en, this message translates to:
  /// **'Saved Exercises'**
  String get saved_exercises;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get information;

  /// No description provided for @noBodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No body measurements yet'**
  String get noBodyMeasurements;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @termsPart1.
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to our '**
  String get termsPart1;

  /// No description provided for @termsPart2.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsPart2;

  /// No description provided for @termsPart3.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get termsPart3;

  /// No description provided for @termsPart4.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get termsPart4;

  /// No description provided for @coaches.
  ///
  /// In en, this message translates to:
  /// **'Coaches'**
  String get coaches;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get see_all;

  /// Error message when loading coaches fails
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {message}'**
  String coaches_error_loading(String message);

  /// No description provided for @no_coaches_found.
  ///
  /// In en, this message translates to:
  /// **'No matching coaches found'**
  String get no_coaches_found;

  /// No description provided for @coach_details_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {message}'**
  String coach_details_error(String message);

  /// No description provided for @biography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// No description provided for @no_biography.
  ///
  /// In en, this message translates to:
  /// **'No biography available for this coach.'**
  String get no_biography;

  /// No description provided for @qualifications_certifications.
  ///
  /// In en, this message translates to:
  /// **'QUALIFICATIONS & CERTIFICATIONS'**
  String get qualifications_certifications;

  /// No description provided for @book_consultation.
  ///
  /// In en, this message translates to:
  /// **'BOOK A CONSULTATION'**
  String get book_consultation;

  /// No description provided for @specialist_title.
  ///
  /// In en, this message translates to:
  /// **'Strength & Conditioning Specialist'**
  String get specialist_title;

  /// No description provided for @years_exp_badge.
  ///
  /// In en, this message translates to:
  /// **'{count} Years Exp'**
  String years_exp_badge(int count);

  /// No description provided for @age_badge.
  ///
  /// In en, this message translates to:
  /// **'Age {count}'**
  String age_badge(int count);

  /// No description provided for @filter_coaches.
  ///
  /// In en, this message translates to:
  /// **'Filter Coaches'**
  String get filter_coaches;

  /// No description provided for @coach_gender.
  ///
  /// In en, this message translates to:
  /// **'Coach Gender'**
  String get coach_gender;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @coach_male.
  ///
  /// In en, this message translates to:
  /// **'Male Coach'**
  String get coach_male;

  /// No description provided for @coach_female.
  ///
  /// In en, this message translates to:
  /// **'Female Coach'**
  String get coach_female;

  /// No description provided for @years_sports_exp.
  ///
  /// In en, this message translates to:
  /// **'Years of Sports Experience'**
  String get years_sports_exp;

  /// No description provided for @min_limit_year.
  ///
  /// In en, this message translates to:
  /// **'Min Limit (Year)'**
  String get min_limit_year;

  /// No description provided for @max_limit_year.
  ///
  /// In en, this message translates to:
  /// **'Max Limit (Year)'**
  String get max_limit_year;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// No description provided for @all_coaches.
  ///
  /// In en, this message translates to:
  /// **'All Coaches'**
  String get all_coaches;

  /// No description provided for @search_coach_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for your sports coach...'**
  String get search_coach_hint;

  /// No description provided for @years_of_exp_suffix.
  ///
  /// In en, this message translates to:
  /// **'Yrs Exp'**
  String get years_of_exp_suffix;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pendingApproval;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'ACTION REQUIRED'**
  String get actionRequired;

  /// No description provided for @noPendingSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No pending subscriptions'**
  String get noPendingSubscriptions;

  /// No description provided for @activeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get activeSubscriptions;

  /// No description provided for @noActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions found'**
  String get noActiveSubscriptions;

  /// No description provided for @subscription_payment_title.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get subscription_payment_title;

  /// No description provided for @subscription_payment_paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Pay via: Cham Cash'**
  String get subscription_payment_paymentMethod;

  /// No description provided for @subscription_payment_confirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get subscription_payment_confirmTransfer;

  /// No description provided for @subscription_payment_uploadReceiptFirst.
  ///
  /// In en, this message translates to:
  /// **'Please upload payment file first'**
  String get subscription_payment_uploadReceiptFirst;

  /// Request failure message with error reason
  ///
  /// In en, this message translates to:
  /// **'Request failed: {error}'**
  String subscription_payment_requestFailed(String error);

  /// Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred: {error}'**
  String subscription_payment_unexpectedError(String error);

  /// No description provided for @subscription_payment_successTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted Successfully'**
  String get subscription_payment_successTitle;

  /// Transaction reference ID
  ///
  /// In en, this message translates to:
  /// **'Transaction ID: {id}'**
  String subscription_payment_transactionId(String id);

  /// No description provided for @subscription_payment_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get subscription_payment_ok;

  /// No description provided for @subscription_payment_confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Submit'**
  String get subscription_payment_confirmButton;

  /// No description provided for @subscription_payment_accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get subscription_payment_accountNameLabel;

  /// No description provided for @subscription_payment_walletNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet Number'**
  String get subscription_payment_walletNumberLabel;

  /// No description provided for @subscription_payment_copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet number copied successfully'**
  String get subscription_payment_copySuccess;

  /// No description provided for @subscription_payment_orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get subscription_payment_orderSummary;

  /// No description provided for @subscription_payment_planLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get subscription_payment_planLabel;

  /// No description provided for @subscription_payment_durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get subscription_payment_durationLabel;

  /// No description provided for @subscription_payment_totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get subscription_payment_totalLabel;

  /// No description provided for @subscription_payment_uploadHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload payment file '**
  String get subscription_payment_uploadHint;

  /// File upload success message with file name
  ///
  /// In en, this message translates to:
  /// **'File uploaded: {fileName}'**
  String subscription_payment_fileUploaded(String fileName);

  /// File selection message with file name
  ///
  /// In en, this message translates to:
  /// **'File selected: {fileName}'**
  String subscription_payment_fileSelected(String fileName);

  /// No description provided for @subscription_payment_noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get subscription_payment_noFileSelected;

  /// File selection error message
  ///
  /// In en, this message translates to:
  /// **'Error selecting file: {error}'**
  String subscription_payment_filePickError(String error);

  /// No description provided for @subscription_selectMonth_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription Duration'**
  String get subscription_selectMonth_title;

  /// No description provided for @subscription_selectMonth_availablePlans.
  ///
  /// In en, this message translates to:
  /// **'Available Plans'**
  String get subscription_selectMonth_availablePlans;

  /// No description provided for @subscription_selectMonth_continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get subscription_selectMonth_continueButton;

  /// No description provided for @subscription_selectMonth_choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to continue'**
  String get subscription_selectMonth_choosePlan;

  /// Month selection confirmation
  ///
  /// In en, this message translates to:
  /// **'{months} month(s) selected'**
  String subscription_selectMonth_monthSelected(int months);

  /// Month count label in card
  ///
  /// In en, this message translates to:
  /// **'{months} month(s)'**
  String subscription_selectMonth_monthsLabel(int months);

  /// Approximate price per month
  ///
  /// In en, this message translates to:
  /// **'{price} {currency} / month'**
  String subscription_selectMonth_pricePerMonth(double price, String currency);

  /// No description provided for @subscription_details_featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Features'**
  String get subscription_details_featuresTitle;

  /// No description provided for @subscription_details_subscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscription_details_subscribeButton;

  /// No description provided for @subscription_details_noFeatures.
  ///
  /// In en, this message translates to:
  /// **'No specific features for this plan'**
  String get subscription_details_noFeatures;

  /// No description provided for @subscription_payment_transaction_label.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get subscription_payment_transaction_label;

  /// No description provided for @subscription_payment_transaction_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the reference transaction ID'**
  String get subscription_payment_transaction_hint;

  /// No description provided for @subscription_selectMonth_continueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get subscription_selectMonth_continueToPayment;

  /// No description provided for @subscription_selectMonth_selectToContinue.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to continue'**
  String get subscription_selectMonth_selectToContinue;

  /// No description provided for @subscription_selectMonth_selectionConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{count} month(s) selected'**
  String subscription_selectMonth_selectionConfirmed(Object count);

  /// No description provided for @subscription_selectMonth_durationLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String subscription_selectMonth_durationLabel(Object count);

  /// No description provided for @subscription_selectMonth_monthlyPriceDetail.
  ///
  /// In en, this message translates to:
  /// **'{price} {currency} / month'**
  String subscription_selectMonth_monthlyPriceDetail(Object currency, Object price);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
