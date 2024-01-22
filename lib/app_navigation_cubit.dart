import 'package:bloc/bloc.dart';

enum AppScreen { hikes, events, profile }

class ScreenCubit extends Cubit<AppScreen> {
  ScreenCubit() : super(AppScreen.hikes);

  void setScreen(AppScreen screen) {
    emit(screen);
  }
}
