class ApiConstants {
  static const String domainUrl = "https://sportifo.moayadismail.com";
  static const String baseUrl = "$domainUrl/api/app/";

  static const String register = "register";
  static const String login = "login";
  static const String forgotPassword = "forgot-password";
  static const String verifyOtp = "verify-otp";
  static const String verifyResetOtp = "verify-reset-otp";
  static const String resendOtp = "resend-otp";
  static const String resetPassword = "reset-password";
  static const String exercise = "exercise";
  static const String saveExercise = "savedExercise";
  static const String getSavedExercises = "savedExercise";

  static const String getProfile = "profile";
  static const String profile = "profile";
  static const String editProfile = "profile/edit";
  static const String logout = "logout";

  static const String categories = "categories";
  static const String advertisement = "advertisement";
  static const String targets = "targets";
  static const String coaches = "coaches";
  static const String usersSubscribed = "users-subscribed";
  static const String createPlan = "plans";
  static const String getUserPlans = "plans/user";

  static const String plansSubscribedCoach = "plans/subscribed-coach";
  static const String plansSelf = "plans/self";
  static const String plansPlatformSaved = "plans/platform/saved";

  static String planProgress(int planId) => "plans/$planId/progress";
  static String planProgressMarkDone(int planId) => "plans/$planId/progress/mark-done";
  static String toggleSavePlatformPlan(int planId) => "plans/platform/$planId";

  static const String existingDays = 'coaches-days';
  static const String exerciseLogs = "exercise-logs";
  static const String exerciseLogsActivity = "exercise-logs/activity";
  static const String subscribe = "subscriptions/subscribe";
  static const String plans = "plans";

  static const String platformPlans = "plans/platform";

  static const String savedPlatformPlans = "plans/platform/saved";

  static const String exerciseActivity = "exercise-logs/activity";
  static const String weightProgress = "targets/weight-progress";

static const String aiChatMessages = 'ai-chat/messages';

static const String todayFoodLogs = 'food-logs/today';
static const String addMealFromAi = 'food-logs/from-ai'; 
static const String deleteMeal = 'food-logs';
static const String addManualMeal = 'food-logs/manual'; 
  static const String trainees = "plans/coach";
  static const String planDetails = "/plans";
  static const String editCoachPlan = "/plans";
  static const String createSelfPlan = "/plans/create/self";
}
