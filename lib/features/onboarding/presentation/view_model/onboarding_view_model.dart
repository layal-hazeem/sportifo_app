import '../../../../l10n/app_localizations.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String description;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
  });
}
List<OnboardingModel> onboardingPages(AppLocalizations l10n) {
  return [
    OnboardingModel(
      image: "assets/images/train.png",
      title: l10n.onboardingTitle1,
      description: l10n.onboardingDesc1,
    ),
    OnboardingModel(
      image: "assets/images/online.png",
      title: l10n.onboardingTitle2,
      description: l10n.onboardingDesc2,
    ),
    OnboardingModel(
      image: "assets/images/nutrition.png",
      title: l10n.onboardingTitle3,
      description: l10n.onboardingDesc3,
    ),
  ];
}