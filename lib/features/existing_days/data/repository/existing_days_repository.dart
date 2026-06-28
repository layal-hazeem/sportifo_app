import 'package:sportifo_app/features/existing_days/data/model/existing_days_model.dart';
import 'package:sportifo_app/features/existing_days/data/web_services/existing_days_web_services.dart';

class ExistingDaysRepository {
  final ExistingDaysWebService _webServices;

  ExistingDaysRepository(this._webServices);

  Future<List<ExistingDaysModel>> fetchExistingDays() async {
    try {
      final responseMap = await _webServices.getExistingDays();
      
      final List<dynamic> dataList = responseMap['data'] as List<dynamic>;
      
      final List<ExistingDaysModel> days = dataList
          .map((dayJson) => ExistingDaysModel.fromJson(dayJson as Map<String, dynamic>))
          .toList();
          
      return days;
    } catch (error) {
      throw Exception('Failed to load existing days: ${error.toString()}');
    }
  }
}