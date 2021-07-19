part of 'edit_profile_cubit.dart';

enum LoadUserPhotoStatus {
  initial,
  loadInProgress,
  loadSuccess,
  loadFailure,
}

class EditProfileState extends Equatable {
  const EditProfileState({
    this.displayName = const Text.pure(),
    this.description = '',
    this.loadPhotoStatus = LoadUserPhotoStatus.initial,
    this.photoUrl = '',
    this.formStatus = FormzStatus.valid,
    this.error = '',
  });

  final Text displayName;
  final String description;
  final LoadUserPhotoStatus loadPhotoStatus;
  final String photoUrl;
  final FormzStatus formStatus;
  final String error;

  @override
  List<Object> get props =>
      [displayName, description, loadPhotoStatus, photoUrl, formStatus, error];

  EditProfileState copyWith({
    Text? displayName,
    String? description,
    LoadUserPhotoStatus? loadPhotoStatus,
    String? photoUrl,
    FormzStatus? formStatus,
    String? error,
  }) {
    return EditProfileState(
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      loadPhotoStatus: loadPhotoStatus ?? this.loadPhotoStatus,
      photoUrl: photoUrl ?? this.photoUrl,
      formStatus: formStatus ?? this.formStatus,
      error: error ?? this.error,
    );
  }
}
