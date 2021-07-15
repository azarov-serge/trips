import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:trips/services/services.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this.usersService) : super(const EditProfileState());

  final UsersService usersService;

  void displayNameChanged(String value) {
    final displayName = Text.dirty(value);
    emit(state.copyWith(
      displayName: displayName,
    ));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(
      description: value,
    ));
  }

  void photoUrlChanged(String value) {
    emit(state.copyWith(
      photoUrl: value,
    ));
  }

  Future<void> updateUserPhoto(String userId, File photo) async {
    emit(state.copyWith(loadPhotoStatus: LoadPhotoStatus.loadInProgress));
    try {
      final photoUrl = await usersService.updateUserPhoto(userId, photo);
      emit(
        state.copyWith(
          loadPhotoStatus: LoadPhotoStatus.loadSuccess,
          photoUrl: photoUrl,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loadPhotoStatus: LoadPhotoStatus.loadFailure,
          error: error.toString(),
        ),
      );
      return;
    }
  }

  Future<void> editProfileFormSubmitted(String userId) async {
    if (!state.formStatus.isValidated) {
      return;
    }
    emit(state.copyWith(formStatus: FormzStatus.submissionInProgress));
    try {
      await usersService.updateUserProfile(
        userId: userId,
        photoUrl: state.photoUrl,
        displayName: state.displayName.value,
        description: state.description,
      );
      emit(state.copyWith(formStatus: FormzStatus.submissionSuccess));
    } catch (error) {
      emit(state.copyWith(
        formStatus: FormzStatus.submissionFailure,
        error: error.toString(),
      ));
    }
  }
}
