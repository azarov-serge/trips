import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:formz/formz.dart';
import 'package:trips/services/services.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class TripEditorForm extends StatelessWidget {
  TripEditorForm({Key? key, this.trip}) : super(key: key);
  final Trip? trip;

  final _descriptionFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final isEditMode = trip != null;
    final textFieldDecoration = BoxDecoration(
      border: Border.all(
        color: CupertinoTheme.of(context).barBackgroundColor,
        width: 2,
      ),
    );

    return BlocListener<TripEditorCubit, TripEditorState>(
      listener: (context, state) {
        if (state.formStatus.isSubmissionFailure) {
          _showErrorAlert(context,
              'Edit profile failure ${state.error != '' ? state.error : ''}');
        }
      },
      child: BlocBuilder<TripEditorCubit, TripEditorState>(
        buildWhen: (previous, current) =>
            previous.formStatus != current.formStatus,
        builder: (context, state) {
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: ListView(
              children: [
                _TitleInput(
                  title: isEditMode ? trip!.title : '',
                  decoration: textFieldDecoration,
                  focusNodeTo: _descriptionFocusNode,
                ),
                SizedBox(height: 5),
                _DescriptionInput(
                  description: isEditMode ? trip!.description : '',
                  decoration: textFieldDecoration,
                  focusNode: _descriptionFocusNode,
                ),
                SizedBox(height: 5),
                _CostInput(
                  cost: isEditMode ? trip!.cost.toStringAsFixed(2) : '',
                  decoration: textFieldDecoration,
                ),
                SizedBox(height: 5),
                _TripPhotoEditor(imageUrl: isEditMode ? trip!.imageUrl : ''),
                SizedBox(height: 25),
                CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  child: Text(
                    'Save',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                  onPressed: !state.formStatus.isValidated
                      ? null
                      : () async {
                          if (isEditMode) {
                            await context
                                .read<TripEditorCubit>()
                                .updateTrip(id: trip!.id);
                          } else {
                            await context.read<TripEditorCubit>().createTrip();
                          }
                          Navigator.of(context).pop();
                        },
                ),
                SizedBox(height: 15),
                CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  child: Text(
                    'Save & Publish',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                  onPressed: !state.formStatus.isValidated
                      ? null
                      : () async {
                          if (isEditMode) {
                            await context
                                .read<TripEditorCubit>()
                                .updateTrip(id: trip!.id, isPublic: true);
                          } else {
                            await context
                                .read<TripEditorCubit>()
                                .createTrip(isPublic: true);
                          }
                          Navigator.of(context).pop();
                        },
                ),
              ],
            ),
          );
        },
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

class _TitleInput extends StatefulWidget {
  _TitleInput({
    required this.title,
    required this.decoration,
    required this.focusNodeTo,
  });

  final String title;
  final BoxDecoration decoration;
  final FocusNode focusNodeTo;

  @override
  _TitleInputState createState() => _TitleInputState();
}

class _TitleInputState extends State<_TitleInput> {
  late TextEditingController _textController;
  @override
  void initState() {
    _textController = TextEditingController(text: widget.title);
    context.read<TripEditorCubit>().titleChanged(widget.title);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripEditorCubit, TripEditorState>(
      buildWhen: (previous, current) => previous.title != current.title,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              decoration: widget.decoration,
              controller: _textController,
              placeholder: 'Title',
              padding: EdgeInsets.all(15),
              onChanged: (title) {
                context.read<TripEditorCubit>().titleChanged(title);
              },
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(widget.focusNodeTo);
              },
            ),
            const SizedBox(height: 5),
            Hint(
              state.title.invalid ? 'invalid title' : '',
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
    context.read<TripEditorCubit>().descriptionChanged(widget.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripEditorCubit, TripEditorState>(
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
                context.read<TripEditorCubit>().descriptionChanged(description);
              },
              focusNode: widget.focusNode,
            ),
          ],
        );
      },
    );
  }
}

class _CostInput extends StatefulWidget {
  _CostInput({
    required this.cost,
    required this.decoration,
  });

  final String cost;
  final BoxDecoration decoration;

  @override
  _CostInputState createState() => _CostInputState();
}

class _CostInputState extends State<_CostInput> {
  late TextEditingController _textController;
  @override
  void initState() {
    _textController = TextEditingController(text: widget.cost);
    context.read<TripEditorCubit>().costChanged(widget.cost);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripEditorCubit, TripEditorState>(
      buildWhen: (previous, current) => previous.cost != current.cost,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              decoration: widget.decoration,
              controller: _textController,
              placeholder: 'Cost',
              padding: EdgeInsets.all(15),
              onChanged: (cost) {
                context.read<TripEditorCubit>().costChanged(cost);
              },
            ),
            const SizedBox(height: 5),
            Hint(
              state.title.invalid ? 'invalid cost' : '',
              type: HintType.error,
            ),
          ],
        );
      },
    );
  }
}

class _TripPhotoEditor extends StatefulWidget {
  _TripPhotoEditor({Key? key, required this.imageUrl}) : super(key: key);

  final String imageUrl;

  @override
  _TripPhotoEditorState createState() => _TripPhotoEditorState();
}

class _TripPhotoEditorState extends State<_TripPhotoEditor> {
  final double _size = 250;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    context.read<TripEditorCubit>().photoUrlChanged(widget.imageUrl);
    super.initState();
  }

  Future<void> _onImageButtonPressed() async {
    final imageFile = await _imagePicker.getImage(
      source: ImageSource.gallery,
    );
    await context
        .read<TripEditorCubit>()
        .uploadTripPhoto(File(imageFile!.path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripEditorCubit, TripEditorState>(
      buildWhen: (previous, current) =>
          previous.loadPhotoStatus != current.loadPhotoStatus,
      builder: (context, state) {
        return Column(
          children: [
            Container(
              height: _size,
              width: MediaQuery.of(context).size.width,
              child: state.loadPhotoStatus == LoadTripPhotoStatus.loadInProgress
                  ? CupertinoActivityIndicator()
                  : _buildTripImage(context, state.photoUrl, widget.imageUrl),
            ),
            SizedBox(height: 10),
            CupertinoButton(
              child: Text('Edit trip\'s image'),
              onPressed:
                  state.loadPhotoStatus == LoadTripPhotoStatus.loadInProgress
                      ? null
                      : () async {
                          await _onImageButtonPressed();
                        },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTripImage(
      BuildContext context, String currentUrl, String initialUrl) {
    final defaultImage = Column(
      children: [
        Icon(
          CupertinoIcons.photo,
          color: CupertinoTheme.of(context).textTheme.textStyle.color,
          size: 200,
        ),
        Text('No photo'),
      ],
    );

    if (currentUrl == '' && initialUrl == '') {
      return defaultImage;
    }

    final url = currentUrl != '' ? currentUrl : initialUrl;
    return Image.network(
      url,
      fit: BoxFit.fitHeight,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Center(
          child: CupertinoActivityIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        child: defaultImage,
        margin: const EdgeInsets.only(top: 100),
      ),
    );
  }
}
