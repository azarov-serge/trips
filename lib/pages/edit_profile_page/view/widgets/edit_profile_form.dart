import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:formz/formz.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class EditProfileForm extends StatelessWidget {
  EditProfileForm({Key? key, required this.user}) : super(key: key);
  final User user;
  final _descriptionFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = BoxDecoration(
      border: Border.all(
        color: CupertinoTheme.of(context).barBackgroundColor,
        width: 2,
      ),
    );

    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.formStatus.isSubmissionFailure) {
          _showErrorAlert(context,
              'Edit profile failure ${state.error != '' ? state.error : ''}');
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UserPicEditor(user: user),
            SizedBox(height: 20),
            _DisplayNameInput(
              displayName: user.displayName,
              decoration: textFieldDecoration,
              focusNodeTo: _descriptionFocusNode,
            ),
            _DescriptionInput(
              description: user.description ?? '',
              decoration: textFieldDecoration,
              focusNode: _descriptionFocusNode,
            ),
            SizedBox(height: 20),
            _EditProfileButton(user.userId),
          ],
        ),
      ),
    );
  }

  Future _showErrorAlert(BuildContext context, String errorMessage) {
    return showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(errorMessage),
        actions: [
          CupertinoDialogAction(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _UserPicEditor extends StatefulWidget {
  _UserPicEditor({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _UserPicEditorState createState() => _UserPicEditorState();
}

class _UserPicEditorState extends State<_UserPicEditor> {
  final double _size = 150;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    context
        .read<EditProfileCubit>()
        .photoUrlChanged(widget.user.photoUrl ?? '');
    super.initState();
  }

  Future<void> _onImageButtonPressed() async {
    final imageFile = await _imagePicker.getImage(
      source: ImageSource.gallery,
    );
    await context
        .read<EditProfileCubit>()
        .updateUserPhoto(widget.user.userId, File(imageFile!.path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
        buildWhen: (previous, current) =>
            previous.loadPhotoStatus != current.loadPhotoStatus,
        builder: (context, state) {
          return Column(
            children: [
              Container(
                height: _size,
                width: _size,
                child:
                    state.loadPhotoStatus == LoadUserPhotoStatus.loadInProgress
                        ? CupertinoActivityIndicator()
                        : UserPic(
                            url: state.photoUrl != ''
                                ? state.photoUrl
                                : widget.user.photoUrl ?? '',
                            size: _size,
                          ),
              ),
              SizedBox(height: 10),
              CupertinoButton(
                child: Text('Edit user\'s photo'),
                onPressed:
                    state.loadPhotoStatus == LoadUserPhotoStatus.loadInProgress
                        ? null
                        : () async {
                            await _onImageButtonPressed();
                          },
              ),
            ],
          );
        });
  }
}

class _DisplayNameInput extends StatefulWidget {
  _DisplayNameInput({
    required this.displayName,
    required this.decoration,
    required this.focusNodeTo,
  });

  final String displayName;
  final BoxDecoration decoration;
  final FocusNode focusNodeTo;

  @override
  _DisplayNameInputState createState() => _DisplayNameInputState();
}

class _DisplayNameInputState extends State<_DisplayNameInput> {
  late TextEditingController _textController;
  @override
  void initState() {
    _textController = TextEditingController(text: widget.displayName);
    context.read<EditProfileCubit>().displayNameChanged(widget.displayName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      buildWhen: (previous, current) =>
          previous.displayName != current.displayName,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              decoration: widget.decoration,
              controller: _textController,
              placeholder: 'Display name',
              padding: EdgeInsets.all(15),
              onChanged: (displayName) {
                context
                    .read<EditProfileCubit>()
                    .displayNameChanged(displayName);
              },
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(widget.focusNodeTo);
              },
            ),
            const SizedBox(height: 5),
            Hint(
              state.displayName.invalid ? 'invalid display name' : '',
              type: HintType.error,
            ),
          ],
        );
      },
    );
  }
}

class _DescriptionInput extends StatefulWidget {
  _DescriptionInput({
    required this.description,
    required this.decoration,
    required this.focusNode,
  });

  final String description;
  final BoxDecoration decoration;
  final FocusNode focusNode;

  @override
  _DescriptionInputState createState() => _DescriptionInputState();
}

class _DescriptionInputState extends State<_DescriptionInput> {
  late TextEditingController _textController;
  @override
  void initState() {
    _textController = TextEditingController(text: widget.description);
    context.read<EditProfileCubit>().descriptionChanged(widget.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      buildWhen: (previous, current) =>
          previous.description != current.description,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              decoration: widget.decoration,
              controller: _textController,
              placeholder: 'Description',
              padding: EdgeInsets.all(15),
              maxLines: 5,
              onChanged: (description) {
                context
                    .read<EditProfileCubit>()
                    .descriptionChanged(description);
              },
              focusNode: widget.focusNode,
            ),
          ],
        );
      },
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  _EditProfileButton(this.userId);

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      buildWhen: (previous, current) =>
          previous.formStatus != current.formStatus,
      builder: (context, state) {
        return state.formStatus.isSubmissionInProgress
            ? const CupertinoActivityIndicator()
            : Container(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  child: Text(
                    'Save changes',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                  onPressed: !state.formStatus.isValidated
                      ? null
                      : () => context
                          .read<EditProfileCubit>()
                          .editProfileFormSubmitted(userId),
                ),
              );
      },
    );
  }
}
