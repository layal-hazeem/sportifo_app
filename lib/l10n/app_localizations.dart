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
  /// **'Kg'**
  String get kg;

  /// No description provided for @g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get g;

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
  /// **'About Us'**
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
  /// **'Action Required'**
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

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred app language'**
  String get chooseLanguageHint;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @deletedSucceful.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get deletedSucceful;

  /// No description provided for @deleteHint.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will permanently remove everything associated with it'**
  String get deleteHint;

  /// No description provided for @deleteHint2.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get deleteHint2;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @workoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Workout plans'**
  String get workoutPlans;

  /// No description provided for @continue1.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue1;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deletionConfirmationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deletionConfirmationQuestion;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;

  /// No description provided for @noCoachData.
  ///
  /// In en, this message translates to:
  /// **'No coach data available'**
  String get noCoachData;

  /// No description provided for @userInfo.
  ///
  /// In en, this message translates to:
  /// **'user information'**
  String get userInfo;

  /// No description provided for @coachInfo.
  ///
  /// In en, this message translates to:
  /// **'coach information'**
  String get coachInfo;

  /// No description provided for @chatAI.
  ///
  /// In en, this message translates to:
  /// **'Chat AI'**
  String get chatAI;

  /// No description provided for @sub.
  ///
  /// In en, this message translates to:
  /// **'Sub\'s'**
  String get sub;

  /// No description provided for @trainees.
  ///
  /// In en, this message translates to:
  /// **'Trainees'**
  String get trainees;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @checkYourNetwork.
  ///
  /// In en, this message translates to:
  /// **'Please check your network settings and try again'**
  String get checkYourNetwork;

  /// No description provided for @recentlyEnded.
  ///
  /// In en, this message translates to:
  /// **'Recently ended'**
  String get recentlyEnded;

  /// No description provided for @endedLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions that ended during the last month'**
  String get endedLastMonth;

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get editPlan;

  /// No description provided for @createNewDay.
  ///
  /// In en, this message translates to:
  /// **'Create New Day'**
  String get createNewDay;

  /// No description provided for @creatDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build a custom workout day'**
  String get creatDaySubtitle;

  /// No description provided for @addExistingDay.
  ///
  /// In en, this message translates to:
  /// **'Add Existing Day'**
  String get addExistingDay;

  /// No description provided for @addExistingDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reuse a saved day'**
  String get addExistingDaySubtitle;

  /// No description provided for @workoutDays.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT DAYS'**
  String get workoutDays;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'DAY'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @waitUpdatePlan.
  ///
  /// In en, this message translates to:
  /// **'Please wait while the plan is updated'**
  String get waitUpdatePlan;

  /// No description provided for @noWorkoutDaysYet.
  ///
  /// In en, this message translates to:
  /// **'No workout days yet'**
  String get noWorkoutDaysYet;

  /// No description provided for @hintForCreateDay.
  ///
  /// In en, this message translates to:
  /// **'Create a new workout day or reuse one from your saved workouts'**
  String get hintForCreateDay;

  /// No description provided for @tapPlus.
  ///
  /// In en, this message translates to:
  /// **'Tap + to get started'**
  String get tapPlus;

  /// No description provided for @stepOne.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Goal & Duration'**
  String get stepOne;

  /// No description provided for @stepTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Days & Exercises'**
  String get stepTwo;

  /// No description provided for @chooseGoalForTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a goal for this training plan'**
  String get chooseGoalForTrainingPlan;

  /// No description provided for @addAtLeastOneWorkoutDay.
  ///
  /// In en, this message translates to:
  /// **'Add at least one workout day'**
  String get addAtLeastOneWorkoutDay;

  /// No description provided for @everyWorkoutDayNeedsExercise.
  ///
  /// In en, this message translates to:
  /// **'Every workout day needs at least one exercise'**
  String get everyWorkoutDayNeedsExercise;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlan;

  /// No description provided for @addedToSaved.
  ///
  /// In en, this message translates to:
  /// **'Added to saved'**
  String get addedToSaved;

  /// No description provided for @removedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get removedFromSaved;

  /// No description provided for @tapToHideInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap to hide instructions'**
  String get tapToHideInstructions;

  /// No description provided for @tapToViewInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap to view instructions'**
  String get tapToViewInstructions;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @bodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body Part'**
  String get bodyPart;

  /// No description provided for @searchForExercises.
  ///
  /// In en, this message translates to:
  /// **'Search for exercises...'**
  String get searchForExercises;

  /// No description provided for @noSavedExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No saved exercises yet'**
  String get noSavedExercisesYet;

  /// No description provided for @savedExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'Exercises you save will appear here for quick access'**
  String get savedExercisesHint;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// No description provided for @trySearchingForSomethingElse.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else, like \'Shoulders\' or \'Yoga\'.'**
  String get trySearchingForSomethingElse;

  /// No description provided for @chooseYourWorkoutType.
  ///
  /// In en, this message translates to:
  /// **'Choose Your\nWorkout Type'**
  String get chooseYourWorkoutType;

  /// No description provided for @search_chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get search_chest;

  /// No description provided for @search_abs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get search_abs;

  /// No description provided for @search_legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get search_legs;

  /// No description provided for @search_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get search_back;

  /// No description provided for @search_biceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get search_biceps;

  /// No description provided for @search_shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get search_shoulders;

  /// No description provided for @search_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get search_running;

  /// No description provided for @search_jump_rope.
  ///
  /// In en, this message translates to:
  /// **'Jump Rope'**
  String get search_jump_rope;

  /// No description provided for @search_burpees.
  ///
  /// In en, this message translates to:
  /// **'Burpees'**
  String get search_burpees;

  /// No description provided for @search_cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get search_cycling;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @dailyNutritionTargets.
  ///
  /// In en, this message translates to:
  /// **'Daily Nutrition Targets'**
  String get dailyNutritionTargets;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight:'**
  String get currentWeight;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @selectFitnessGoal.
  ///
  /// In en, this message translates to:
  /// **'Select Your Fitness Goal ⚡'**
  String get selectFitnessGoal;

  /// No description provided for @goalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The system will automatically compute your tailored daily metrics'**
  String get goalSubtitle;

  /// No description provided for @bulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk / Gain Muscle'**
  String get bulkTitle;

  /// No description provided for @bulkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Increase calorie targets systematically to optimize lean muscle growth'**
  String get bulkSubtitle;

  /// No description provided for @cutTitle.
  ///
  /// In en, this message translates to:
  /// **'Cut / Lose Fat'**
  String get cutTitle;

  /// No description provided for @cutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Decrease calorie targets to accelerate smart fat burn and increase definition'**
  String get cutSubtitle;

  /// No description provided for @maintainTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintain / Stay Fit'**
  String get maintainTitle;

  /// No description provided for @maintainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stabilize current weight while steadily optimizing athletic stamina and recovery'**
  String get maintainSubtitle;

  /// No description provided for @confirmAndComputePlan.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Compute Plan'**
  String get confirmAndComputePlan;

  /// No description provided for @pleaseEnterWeightSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current weight in your profile so the system can compute your calories.'**
  String get pleaseEnterWeightSnackBar;

  /// No description provided for @updateWeight.
  ///
  /// In en, this message translates to:
  /// **'Update Weight'**
  String get updateWeight;

  /// No description provided for @activateSmartPlan.
  ///
  /// In en, this message translates to:
  /// **'Activate Your Smart Plan ⚡'**
  String get activateSmartPlan;

  /// No description provided for @activateSmartPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your main physical target now to dynamically evaluate your necessary daily calories and macronutrients.'**
  String get activateSmartPlanDesc;

  /// No description provided for @setMyGoalNow.
  ///
  /// In en, this message translates to:
  /// **'Set My Goal Now'**
  String get setMyGoalNow;

  /// No description provided for @bulkGoal.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get bulkGoal;

  /// No description provided for @cutGoal.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cutGoal;

  /// No description provided for @maintainGoal.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get maintainGoal;

  /// No description provided for @exercisesList.
  ///
  /// In en, this message translates to:
  /// **'Exercises List'**
  String get exercisesList;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @completedUppercase.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completedUppercase;

  /// No description provided for @noDaysCreated.
  ///
  /// In en, this message translates to:
  /// **'No days created yet.'**
  String get noDaysCreated;

  /// No description provided for @workoutSummary.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT SUMMARY'**
  String get workoutSummary;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout Completed'**
  String get workoutCompleted;

  /// No description provided for @sessionSummaryFor.
  ///
  /// In en, this message translates to:
  /// **'Session summary for'**
  String get sessionSummaryFor;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @performanceSummary.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE SUMMARY'**
  String get performanceSummary;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @noSetsLogged.
  ///
  /// In en, this message translates to:
  /// **'No sets logged'**
  String get noSetsLogged;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @of_word.
  ///
  /// In en, this message translates to:
  /// **'OF'**
  String get of_word;

  /// No description provided for @completeSet.
  ///
  /// In en, this message translates to:
  /// **'Complete Set'**
  String get completeSet;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remaining;

  /// No description provided for @logCompletedSet.
  ///
  /// In en, this message translates to:
  /// **'Log Completed Set'**
  String get logCompletedSet;

  /// No description provided for @new_word.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_word;

  /// No description provided for @yourPersonalCoach.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Coach'**
  String get yourPersonalCoach;

  /// No description provided for @openDuration.
  ///
  /// In en, this message translates to:
  /// **'Open Duration'**
  String get openDuration;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @daysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Days / Week'**
  String get daysPerWeek;

  /// No description provided for @wks.
  ///
  /// In en, this message translates to:
  /// **'Wks'**
  String get wks;

  /// No description provided for @viewDays.
  ///
  /// In en, this message translates to:
  /// **'View Days'**
  String get viewDays;

  /// No description provided for @coachPlan.
  ///
  /// In en, this message translates to:
  /// **'Coach Plan'**
  String get coachPlan;

  /// No description provided for @noCoachPlanFound.
  ///
  /// In en, this message translates to:
  /// **'No Coach Plan Found'**
  String get noCoachPlanFound;

  /// No description provided for @noCoachPlanSub.
  ///
  /// In en, this message translates to:
  /// **'Get a personalized workout routine from our expert coaches.'**
  String get noCoachPlanSub;

  /// No description provided for @exploreCoaches.
  ///
  /// In en, this message translates to:
  /// **'Explore Coaches'**
  String get exploreCoaches;

  /// No description provided for @noCustomPlans.
  ///
  /// In en, this message translates to:
  /// **'No Custom Plans Yet'**
  String get noCustomPlans;

  /// No description provided for @noCustomPlansSub.
  ///
  /// In en, this message translates to:
  /// **'Build your own custom plan and train on your schedule.'**
  String get noCustomPlansSub;

  /// No description provided for @createCustomPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Plan'**
  String get createCustomPlan;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @noSavedPlans.
  ///
  /// In en, this message translates to:
  /// **'No Saved Plans Yet'**
  String get noSavedPlans;

  /// No description provided for @noSavedPlansSub.
  ///
  /// In en, this message translates to:
  /// **'Plans you save from the platform library will show up here.'**
  String get noSavedPlansSub;

  /// No description provided for @exploreFreePlans.
  ///
  /// In en, this message translates to:
  /// **'Explore Sportifo Plans'**
  String get exploreFreePlans;

  /// No description provided for @createYourOwnPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Your Own Plan'**
  String get createYourOwnPlan;

  /// No description provided for @buildWorkoutPlanThatFitsYou.
  ///
  /// In en, this message translates to:
  /// **'Build Workout Plan That Fits You'**
  String get buildWorkoutPlanThatFitsYou;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @yourTrainees.
  ///
  /// In en, this message translates to:
  /// **'Your Trainees'**
  String get yourTrainees;

  /// No description provided for @noTraineesYet.
  ///
  /// In en, this message translates to:
  /// **'No Trainees Yet'**
  String get noTraineesYet;

  /// No description provided for @needs_a_plan.
  ///
  /// In en, this message translates to:
  /// **'Needs A Plan'**
  String get needs_a_plan;

  /// No description provided for @hasAnActivePlan.
  ///
  /// In en, this message translates to:
  /// **'has an active plan'**
  String get hasAnActivePlan;

  /// No description provided for @coach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @activeTrainees.
  ///
  /// In en, this message translates to:
  /// **'Active Trainees'**
  String get activeTrainees;

  /// No description provided for @totalTrainees.
  ///
  /// In en, this message translates to:
  /// **'Total Trainees'**
  String get totalTrainees;

  /// No description provided for @personalWorkout.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL WORKOUT'**
  String get personalWorkout;

  /// No description provided for @seeWhoNeedsANewTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'See who needs a new training plan'**
  String get seeWhoNeedsANewTrainingPlan;

  /// No description provided for @hintForCreatePlan.
  ///
  /// In en, this message translates to:
  /// **'Build a new training plan'**
  String get hintForCreatePlan;

  /// No description provided for @waitANewTrainee.
  ///
  /// In en, this message translates to:
  /// **'wait a new trainee'**
  String get waitANewTrainee;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @couldntLoadTrainees.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t Load Trainees'**
  String get couldntLoadTrainees;

  /// No description provided for @planActive.
  ///
  /// In en, this message translates to:
  /// **'Plan active'**
  String get planActive;

  /// No description provided for @oneMonthPlan.
  ///
  /// In en, this message translates to:
  /// **'1 month plan'**
  String get oneMonthPlan;

  /// Displays the duration of the trainee's plan in months
  ///
  /// In en, this message translates to:
  /// **'{count} months plan'**
  String monthsPlan(int count);

  /// No description provided for @trainee.
  ///
  /// In en, this message translates to:
  /// **'Trainee'**
  String get trainee;

  /// No description provided for @activePlan.
  ///
  /// In en, this message translates to:
  /// **'Active Plan'**
  String get activePlan;

  /// No description provided for @oneMonthProgram.
  ///
  /// In en, this message translates to:
  /// **'1M Program'**
  String get oneMonthProgram;

  /// Displays the trainee plan duration in months
  ///
  /// In en, this message translates to:
  /// **'{count}M Program'**
  String monthsProgram(int count);

  /// No description provided for @noTraineesFound.
  ///
  /// In en, this message translates to:
  /// **'No trainees found'**
  String get noTraineesFound;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @traineesHint.
  ///
  /// In en, this message translates to:
  /// **'Manage active training programs and monitor athlete progress seamlessly'**
  String get traineesHint;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noRecentExpiredPlansHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No recent expired plans history found'**
  String get noRecentExpiredPlansHistoryFound;

  /// Message showing the number of active subscribers who do not have a training plan
  ///
  /// In en, this message translates to:
  /// **'You have {count} active subscribers who don\'t have a training plan yet.'**
  String subscribersNeedPlan(int count);

  /// No description provided for @createTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Training Plan'**
  String get createTrainingPlan;

  /// No description provided for @defaultPlan.
  ///
  /// In en, this message translates to:
  /// **'Default Plan'**
  String get defaultPlan;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @unknownAthlete.
  ///
  /// In en, this message translates to:
  /// **'Unknown Athlete'**
  String get unknownAthlete;

  /// No description provided for @athlete.
  ///
  /// In en, this message translates to:
  /// **'ATHLETE'**
  String get athlete;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'STRENGTH'**
  String get strength;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @technicalNotes.
  ///
  /// In en, this message translates to:
  /// **'TECHNICAL NOTES'**
  String get technicalNotes;

  /// No description provided for @noExercisesAssigned.
  ///
  /// In en, this message translates to:
  /// **'No exercises assigned'**
  String get noExercisesAssigned;

  /// No description provided for @blueprint.
  ///
  /// In en, this message translates to:
  /// **'BLUEPRINT'**
  String get blueprint;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @createFirstWorkoutDay.
  ///
  /// In en, this message translates to:
  /// **'Create your first workout day and start building your personal plan.'**
  String get createFirstWorkoutDay;

  /// No description provided for @tapPlusToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Tap + to get started'**
  String get tapPlusToGetStarted;

  /// No description provided for @createSelfPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Self Plan'**
  String get createSelfPlan;

  /// No description provided for @creatingYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Creating your plan...'**
  String get creatingYourPlan;

  /// No description provided for @pleaseWaitWhileSavingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we save your workout'**
  String get pleaseWaitWhileSavingWorkout;

  /// No description provided for @planCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Plan created successfully'**
  String get planCreatedSuccessfully;

  /// No description provided for @createWorkoutDay.
  ///
  /// In en, this message translates to:
  /// **'Create Workout Day'**
  String get createWorkoutDay;

  /// No description provided for @giveTrainingDayName.
  ///
  /// In en, this message translates to:
  /// **'Give your training day a name'**
  String get giveTrainingDayName;

  /// No description provided for @exampleChestDay.
  ///
  /// In en, this message translates to:
  /// **'Example: Chest Day'**
  String get exampleChestDay;

  /// No description provided for @createDayButton.
  ///
  /// In en, this message translates to:
  /// **'Create Day'**
  String get createDayButton;

  /// No description provided for @noExercisesAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises added yet'**
  String get noExercisesAddedYet;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @workoutDaySettings.
  ///
  /// In en, this message translates to:
  /// **'Workout Day Settings'**
  String get workoutDaySettings;

  /// No description provided for @workoutDaySettingsHint.
  ///
  /// In en, this message translates to:
  /// **'These values will apply to all exercises unless customized.'**
  String get workoutDaySettingsHint;

  /// No description provided for @defaultSets.
  ///
  /// In en, this message translates to:
  /// **'Default Sets'**
  String get defaultSets;

  /// No description provided for @exampleSets.
  ///
  /// In en, this message translates to:
  /// **'Example: 4'**
  String get exampleSets;

  /// No description provided for @defaultReps.
  ///
  /// In en, this message translates to:
  /// **'Default Reps'**
  String get defaultReps;

  /// No description provided for @exampleReps.
  ///
  /// In en, this message translates to:
  /// **'Example: 12'**
  String get exampleReps;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @daySettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'These values will be used for resistance exercises without custom settings'**
  String get daySettingsDescription;

  /// No description provided for @applyToAllResistanceExercises.
  ///
  /// In en, this message translates to:
  /// **'Apply to all resistance exercises'**
  String get applyToAllResistanceExercises;

  /// No description provided for @applyToAllResistanceExercisesDescription.
  ///
  /// In en, this message translates to:
  /// **'Update sets and reps for every resistance exercise in this day'**
  String get applyToAllResistanceExercisesDescription;

  /// No description provided for @exerciseDefaultsInfo.
  ///
  /// In en, this message translates to:
  /// **'Leave Sets and Reps empty to use the workout day defaults.'**
  String get exerciseDefaultsInfo;

  /// No description provided for @customValues.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM VALUES'**
  String get customValues;

  /// No description provided for @customSets.
  ///
  /// In en, this message translates to:
  /// **'Custom Sets'**
  String get customSets;

  /// No description provided for @customReps.
  ///
  /// In en, this message translates to:
  /// **'Custom Reps'**
  String get customReps;

  /// No description provided for @useDayDefaults.
  ///
  /// In en, this message translates to:
  /// **'Use Day Defaults'**
  String get useDayDefaults;

  /// No description provided for @exampleDuration.
  ///
  /// In en, this message translates to:
  /// **'Example: 30 sec'**
  String get exampleDuration;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @exerciseOrder.
  ///
  /// In en, this message translates to:
  /// **'Exercise order'**
  String get exerciseOrder;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @customizeExerciseSettings.
  ///
  /// In en, this message translates to:
  /// **'Customize this exercise settings'**
  String get customizeExerciseSettings;

  /// No description provided for @saveExerciseSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Exercise Settings'**
  String get saveExerciseSettings;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get sec;

  /// No description provided for @selectExercises.
  ///
  /// In en, this message translates to:
  /// **'Select Exercises'**
  String get selectExercises;

  /// No description provided for @resistance.
  ///
  /// In en, this message translates to:
  /// **'Resistance'**
  String get resistance;

  /// No description provided for @addExercises.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String addExercises(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @mainGoalQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s the main goal?'**
  String get mainGoalQuestion;

  /// No description provided for @cutGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lose fat'**
  String get cutGoalSubtitle;

  /// No description provided for @bulkGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get bulkGoalSubtitle;

  /// No description provided for @maintainGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay balanced'**
  String get maintainGoalSubtitle;

  /// No description provided for @noExistingDaysFound.
  ///
  /// In en, this message translates to:
  /// **'No existing days found.'**
  String get noExistingDaysFound;

  /// No description provided for @addExistingDays.
  ///
  /// In en, this message translates to:
  /// **'Add Existing Days'**
  String get addExistingDays;

  /// No description provided for @availableDays.
  ///
  /// In en, this message translates to:
  /// **'Available Days'**
  String get availableDays;

  /// No description provided for @addSelectedDays.
  ///
  /// In en, this message translates to:
  /// **'Add Selected Days'**
  String get addSelectedDays;

  /// No description provided for @planUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Plan Updated Successfully'**
  String get planUpdatedSuccessfully;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @stop_sending_title.
  ///
  /// In en, this message translates to:
  /// **'Stop Sending?'**
  String get stop_sending_title;

  /// No description provided for @stop_sending_content.
  ///
  /// In en, this message translates to:
  /// **'Stopping will delete your message and it won\'t be saved.'**
  String get stop_sending_content;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @ai_coach_ready.
  ///
  /// In en, this message translates to:
  /// **'Your AI Coach is ready!'**
  String get ai_coach_ready;

  /// No description provided for @empty_chat_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about nutrition, workouts, or calories'**
  String get empty_chat_subtitle;

  /// No description provided for @meal_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Meal saved successfully'**
  String get meal_saved_success;

  /// No description provided for @view_meals.
  ///
  /// In en, this message translates to:
  /// **'View Meals'**
  String get view_meals;

  /// No description provided for @sending_hint.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending_hint;

  /// No description provided for @ask_ai_hint.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Coach...'**
  String get ask_ai_hint;

  /// No description provided for @cal.
  ///
  /// In en, this message translates to:
  /// **'Cal'**
  String get cal;

  /// No description provided for @press_again_to_exit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit the app'**
  String get press_again_to_exit;

  /// No description provided for @todays_meals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todays_meals;

  /// No description provided for @meal_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully'**
  String get meal_deleted_success;

  /// No description provided for @no_more_meals.
  ///
  /// In en, this message translates to:
  /// **'No more meals for today'**
  String get no_more_meals;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @no_meals_logged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged today'**
  String get no_meals_logged;

  /// No description provided for @ask_ai_or_add_manual.
  ///
  /// In en, this message translates to:
  /// **'Ask AI or add a meal manually'**
  String get ask_ai_or_add_manual;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @delete_meal_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal'**
  String get delete_meal_title;

  /// No description provided for @delete_meal_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meal?'**
  String get delete_meal_confirmation;

  /// No description provided for @add_meal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get add_meal;

  /// No description provided for @meal_added_success.
  ///
  /// In en, this message translates to:
  /// **'Meal added successfully'**
  String get meal_added_success;

  /// No description provided for @meal_details.
  ///
  /// In en, this message translates to:
  /// **'Meal Details'**
  String get meal_details;

  /// No description provided for @enter_nutritional_info_manually.
  ///
  /// In en, this message translates to:
  /// **'Enter nutritional information manually'**
  String get enter_nutritional_info_manually;

  /// No description provided for @meal_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Meal description (e.g. Chicken Rice)'**
  String get meal_description_hint;

  /// No description provided for @required_field.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required_field;

  /// No description provided for @enter_valid_number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enter_valid_number;

  /// No description provided for @invalid_value.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get invalid_value;

  /// No description provided for @protein_g.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get protein_g;

  /// No description provided for @carbs_g.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbs_g;

  /// No description provided for @fat_g.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fat_g;

  /// No description provided for @save_meal.
  ///
  /// In en, this message translates to:
  /// **'Save Meal'**
  String get save_meal;

  /// No description provided for @p_short.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get p_short;

  /// No description provided for @c_short.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get c_short;

  /// No description provided for @f_short.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get f_short;

  /// No description provided for @manual_tag.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual_tag;

  /// No description provided for @ai_tag.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai_tag;

  /// No description provided for @your_progress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get your_progress;

  /// No description provided for @exercises_count.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exercises_count(Object count);

  /// No description provided for @set_info.
  ///
  /// In en, this message translates to:
  /// **'Set {setNum}: {reps} reps , Weight: {weight}kg'**
  String set_info(Object reps, Object setNum, Object weight);

  /// No description provided for @workout_activity.
  ///
  /// In en, this message translates to:
  /// **'Workout Activity'**
  String get workout_activity;

  /// No description provided for @activity_timeline.
  ///
  /// In en, this message translates to:
  /// **'Activity Timeline'**
  String get activity_timeline;

  /// No description provided for @plan_prefix.
  ///
  /// In en, this message translates to:
  /// **'Plan {id}'**
  String plan_prefix(Object id);

  /// No description provided for @exercise_prefix.
  ///
  /// In en, this message translates to:
  /// **'Exercise #{id}'**
  String exercise_prefix(Object id);

  /// No description provided for @exercises_per_day.
  ///
  /// In en, this message translates to:
  /// **'Exercises Per Day'**
  String get exercises_per_day;

  /// No description provided for @filter_workouts.
  ///
  /// In en, this message translates to:
  /// **'Filter Workouts'**
  String get filter_workouts;

  /// No description provided for @all_plans.
  ///
  /// In en, this message translates to:
  /// **'All Plans'**
  String get all_plans;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @all_exercises.
  ///
  /// In en, this message translates to:
  /// **'All Exercises'**
  String get all_exercises;

  /// No description provided for @date_range.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get date_range;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clear_all;

  /// No description provided for @current_weight.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current_weight;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @weight_history.
  ///
  /// In en, this message translates to:
  /// **'Weight History'**
  String get weight_history;

  /// No description provided for @goal_bulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get goal_bulk;

  /// No description provided for @goal_cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get goal_cut;

  /// No description provided for @goal_maintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get goal_maintain;

  /// No description provided for @not_available_short.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get not_available_short;

  /// No description provided for @available_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Available Subscriptions'**
  String get available_subscriptions;

  /// No description provided for @month_single.
  ///
  /// In en, this message translates to:
  /// **'{count} Month'**
  String month_single(Object count);

  /// No description provided for @month_plural.
  ///
  /// In en, this message translates to:
  /// **'{count} Months'**
  String month_plural(Object count);

  /// No description provided for @months_range.
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} Months'**
  String months_range(Object max, Object min);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @aboutUsContent.
  ///
  /// In en, this message translates to:
  /// **'Sportifo is a smart fitness platform designed to support you throughout every stage of your fitness journey. Whether you are just getting started or working toward specific fitness goals, Sportifo provides the tools and support you need in one convenient place.\n\nThe platform brings together personalized workout programs, suitable alternative exercises, direct communication with coaches, subscription management, and AI-powered nutrition assistance. Our goal is to create a more flexible and personalized fitness experience that adapts to your individual needs.\n\nWith Sportifo, you can stay connected with your coach, explore workout alternatives that suit you, and get smart assistance with your nutrition to help you stay motivated and focused on your goals.\n\nSportifo is more than just a workout app — it is your smart companion for a better and more connected fitness journey.'**
  String get aboutUsContent;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @hereToHelp.
  ///
  /// In en, this message translates to:
  /// **'We are here to help you!'**
  String get hereToHelp;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions or encounter any problems, feel free to contact us through one of the following methods:'**
  String get helpSupportSubtitle;

  /// No description provided for @contactViaWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Contact via WhatsApp'**
  String get contactViaWhatsapp;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @cantOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get cantOpenWhatsapp;

  /// No description provided for @cantOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get cantOpenEmail;

  /// No description provided for @privacyTitle1.
  ///
  /// In en, this message translates to:
  /// **'1. Data We Collect'**
  String get privacyTitle1;

  /// No description provided for @privacyContent1.
  ///
  /// In en, this message translates to:
  /// **'We collect basic personal data such as name, email, and fitness data (like weight, height, and fitness goals) to provide you with a customized training and nutrition plan.'**
  String get privacyContent1;

  /// No description provided for @privacyTitle2.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Data'**
  String get privacyTitle2;

  /// No description provided for @privacyContent2.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to improve your app experience, communicate with your personal trainer, and provide meal and exercise recommendations using the smart assistant.'**
  String get privacyContent2;

  /// No description provided for @privacyTitle3.
  ///
  /// In en, this message translates to:
  /// **'3. Data Security & Protection'**
  String get privacyTitle3;

  /// No description provided for @privacyContent3.
  ///
  /// In en, this message translates to:
  /// **'We are committed to protecting your personal data using the latest encryption technologies. We will not sell or share your personal data with any third parties without your explicit consent.'**
  String get privacyContent3;

  /// No description provided for @privacyTitle4.
  ///
  /// In en, this message translates to:
  /// **'4. Your Rights with Sportifo'**
  String get privacyTitle4;

  /// No description provided for @privacyContent4.
  ///
  /// In en, this message translates to:
  /// **'You have the right at any time to modify your personal data or request restricting its use by contacting us through technical support.'**
  String get privacyContent4;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @termsTitle1.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get termsTitle1;

  /// No description provided for @termsContent1.
  ///
  /// In en, this message translates to:
  /// **'By using the Sportifo app, you agree to comply with these terms of use. If you do not agree to these terms, please do not use the app.'**
  String get termsContent1;

  /// No description provided for @termsTitle2.
  ///
  /// In en, this message translates to:
  /// **'2. Medical & Fitness Guidelines'**
  String get termsTitle2;

  /// No description provided for @termsContent2.
  ///
  /// In en, this message translates to:
  /// **'All exercises and nutritional tips provided in the app are for educational and general fitness purposes only. It is recommended to consult a doctor before starting any strenuous exercise program.'**
  String get termsContent2;

  /// No description provided for @termsTitle3.
  ///
  /// In en, this message translates to:
  /// **'3. Account Obligations & Subscriptions'**
  String get termsTitle3;

  /// No description provided for @termsContent3.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account information. Subscriptions grant you direct access to coaches and paid services according to your subscription package.'**
  String get termsContent3;

  /// No description provided for @termsTitle4.
  ///
  /// In en, this message translates to:
  /// **'4. Content Ownership'**
  String get termsTitle4;

  /// No description provided for @termsContent4.
  ///
  /// In en, this message translates to:
  /// **'All text, designs, images, and software in Sportifo are protected intellectual property of the app, and may not be reused without written permission.'**
  String get termsContent4;

  /// No description provided for @alternativeExercises.
  ///
  /// In en, this message translates to:
  /// **'Alternative Exercises'**
  String get alternativeExercises;

  /// No description provided for @noAlternativesFound.
  ///
  /// In en, this message translates to:
  /// **'No alternative exercises available for this workout right now.'**
  String get noAlternativesFound;
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
