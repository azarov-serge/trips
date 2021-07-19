import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:trips/services/services.dart';

part 'trip_editor_state.dart';

class TripEditorCubit extends Cubit<TripEditorState> {
  TripEditorCubit(this.tripsService) : super(const TripEditorState());

  final TripsService tripsService;

  void titleChanged(String value) {
    final title = Text.dirty(value);
    emit(state.copyWith(
      title: title,
      formStatus: Formz.validate([
        title,
        state.cost,
      ]),
    ));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(
      description: value,
    ));
  }

  void costChanged(String value) {
    final cost = Text.dirty(value);
    emit(state.copyWith(
      cost: cost,
      formStatus: Formz.validate([
        state.title,
        cost,
      ]),
    ));
  }

  void photoUrlChanged(String value) {
    emit(state.copyWith(
      photoUrl: value,
    ));
  }

  Future<void> uploadTripPhoto(File photo) async {
    emit(state.copyWith(loadPhotoStatus: LoadTripPhotoStatus.loadInProgress));
    try {
      final photoUrl = await tripsService.uploadTripPhoto(photo);
      emit(
        state.copyWith(
          loadPhotoStatus: LoadTripPhotoStatus.loadSuccess,
          photoUrl: photoUrl,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loadPhotoStatus: LoadTripPhotoStatus.loadFailure,
          error: error.toString(),
        ),
      );
      return;
    }
  }

  Future<void> createTrip({bool? isPublic = false}) async {
    if (!state.formStatus.isValidated) {
      return;
    }
    emit(state.copyWith(formStatus: FormzStatus.submissionInProgress));
    try {
      await tripsService.createTrip(
        title: state.title.value,
        description: state.description,
        imageUrl: state.photoUrl,
        cost: state.cost.value,
        isPublic: isPublic,
      );
      emit(state.copyWith(formStatus: FormzStatus.submissionSuccess));
    } catch (error) {
      emit(state.copyWith(
        formStatus: FormzStatus.submissionFailure,
        error: error.toString(),
      ));
    }
  }

  Future<void> updateTrip({required String id, bool? isPublic = false}) async {
    if (!state.formStatus.isValidated) {
      return;
    }
    emit(state.copyWith(formStatus: FormzStatus.submissionInProgress));
    try {
      await tripsService.updateTrip(
        id: id,
        title: state.title.value,
        description: state.description,
        imageUrl: state.photoUrl,
        cost: state.cost.value,
        isPublic: isPublic,
      );
      emit(state.copyWith(formStatus: FormzStatus.submissionSuccess));
    } catch (error) {
      emit(state.copyWith(
        formStatus: FormzStatus.submissionFailure,
        error: error.toString(),
      ));
    }
  }

  Future<void> deleteTrip(String id) async {
    emit(state.copyWith(formStatus: FormzStatus.submissionInProgress));
    try {
      await tripsService.deleteTrip(id);
      emit(state.copyWith(formStatus: FormzStatus.submissionSuccess));
    } catch (error) {
      emit(state.copyWith(
        formStatus: FormzStatus.submissionFailure,
        error: error.toString(),
      ));
    }
  }
}
