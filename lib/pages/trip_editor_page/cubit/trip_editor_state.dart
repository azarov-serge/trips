part of 'trip_editor_cubit.dart';

enum LoadTripPhotoStatus {
  initial,
  loadInProgress,
  loadSuccess,
  loadFailure,
}

class TripEditorState extends Equatable {
  const TripEditorState({
    this.title = const Text.pure(),
    this.description = '',
    this.cost = const Text.pure(),
    this.loadPhotoStatus = LoadTripPhotoStatus.initial,
    this.photoUrl = '',
    this.formStatus = FormzStatus.valid,
    this.error = '',
  });

  final Text title;
  final String description;
  final Text cost;
  final LoadTripPhotoStatus loadPhotoStatus;
  final String photoUrl;
  final FormzStatus formStatus;
  final String error;

  @override
  List<Object> get props =>
      [title, description, cost, loadPhotoStatus, photoUrl, formStatus, error];

  TripEditorState copyWith({
    Text? title,
    String? description,
    Text? cost,
    LoadTripPhotoStatus? loadPhotoStatus,
    String? photoUrl,
    FormzStatus? formStatus,
    String? error,
  }) {
    return TripEditorState(
      title: title ?? this.title,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      loadPhotoStatus: loadPhotoStatus ?? this.loadPhotoStatus,
      photoUrl: photoUrl ?? this.photoUrl,
      formStatus: formStatus ?? this.formStatus,
      error: error ?? this.error,
    );
  }
}
