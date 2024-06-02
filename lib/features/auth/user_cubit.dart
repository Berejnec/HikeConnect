import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hike_connect/models/hiker_user.dart';

class UserState {
  final User? firebaseAuthUser;
  final HikerUser? hikerUser;

  UserState({required this.firebaseAuthUser, this.hikerUser});
}

class BackgroundImageUploading extends UserState {
  BackgroundImageUploading({
    required User? firebaseAuthUser,
    required HikerUser? hikerUser,
  }) : super(firebaseAuthUser: firebaseAuthUser, hikerUser: hikerUser);
}

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserState(firebaseAuthUser: FirebaseAuth.instance.currentUser, hikerUser: null));

  void setUser(User? user, HikerUser? hikerUser) {
    emit(UserState(firebaseAuthUser: user, hikerUser: hikerUser));
  }

  void setHikerUser(HikerUser? hikerUser) {
    emit(UserState(firebaseAuthUser: state.firebaseAuthUser, hikerUser: hikerUser));
  }

  HikerUser? getHikerUser() {
    return state.hikerUser;
  }

  Future<void> addImageAndUpdate(String imageUrl) async {
    try {
      HikerUser? updatedHikerUser = state.hikerUser?.copyWith(
        imageUrls: [...?state.hikerUser?.imageUrls, imageUrl],
      );

      emit(UserState(firebaseAuthUser: state.firebaseAuthUser, hikerUser: updatedHikerUser));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(state.firebaseAuthUser?.uid)
          .collection('images')
          .add({'imageUrl': imageUrl});
    } catch (error) {
      print('Error adding image and updating user details: $error');
    }
  }

  emitBackgroundImageUploading() {
    emit(BackgroundImageUploading(
      firebaseAuthUser: state.firebaseAuthUser,
      hikerUser: state.hikerUser,
    ));
  }

  Future<void> updateBackgroundUrl(String? backgroundUrl) async {
    try {
      User? currentUser = state.firebaseAuthUser;
      HikerUser? currentHikerUser = state.hikerUser;


      if (currentUser != null && currentHikerUser != null) {
        HikerUser updatedHikerUser = currentHikerUser.copyWith(backgroundUrl: backgroundUrl);

        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({'backgroundUrl': backgroundUrl});
        emit(UserState(firebaseAuthUser: currentUser, hikerUser: updatedHikerUser));
      }
    } catch (e) {
      print('Error updating backgroundUrl: $e');
    }
  }

  void printHikerUserDetails() {
    if (state.hikerUser != null) {
      print('Printing HikerUser details:');
      state.hikerUser!.printDetails();
    } else {
      print('HikerUser is null in the current state.');
    }
  }
}
