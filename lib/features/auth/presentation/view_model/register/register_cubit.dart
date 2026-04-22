import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  // عند تشغيل الكيوبت، نعطيه الحالة الابتدائية
  RegisterCubit() : super(RegisterInitial());
}
