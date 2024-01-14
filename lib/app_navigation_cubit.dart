import 'package:bloc/bloc.dart';

enum AppScreen { hikes, events, map, connect, profile }

class ScreenCubit extends Cubit<AppScreen> {
  ScreenCubit() : super(AppScreen.hikes);

  void setScreen(AppScreen screen) {
    emit(screen);
  }
}
