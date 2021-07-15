import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class SignUpForm extends StatelessWidget {
  SignUpForm({Key? key}) : super(key: key);
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = BoxDecoration(
      border: Border.all(
        color: CupertinoTheme.of(context).barBackgroundColor,
        width: 2,
      ),
    );

    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          _showErrorAlert(context,
              'Sign Up Failure ${state.error != '' ? state.error : ''}');
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DisplayNameInput(
              decoration: textFieldDecoration,
              focusNodeTo: _emailFocusNode,
            ),
            const SizedBox(height: 8.0),
            _EmailInput(
              decoration: textFieldDecoration,
              focusNode: _emailFocusNode,
              focusNodeTo: _passwordFocusNode,
            ),
            const SizedBox(height: 8.0),
            _PasswordInput(
              decoration: textFieldDecoration,
              focusNode: _passwordFocusNode,
              focusNodeTo: _confirmPasswordFocusNode,
            ),
            const SizedBox(height: 8.0),
            _ConfirmPasswordInput(
              decoration: textFieldDecoration,
              focusNode: _confirmPasswordFocusNode,
            ),
            const SizedBox(height: 8.0),
            _SignUpButton(),
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

class _DisplayNameInput extends StatelessWidget {
  _DisplayNameInput({
    required this.decoration,
    required this.focusNodeTo,
  });
  final BoxDecoration decoration;
  final FocusNode focusNodeTo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.displayName != current.displayName,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              decoration: decoration,
              placeholder: 'Display name',
              padding: EdgeInsets.all(15),
              onChanged: (displayName) {
                context.read<SignUpCubit>().displayNameChanged(displayName);
              },
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodeTo);
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

class _EmailInput extends StatelessWidget {
  _EmailInput({
    required this.decoration,
    required this.focusNode,
    required this.focusNodeTo,
  });
  final BoxDecoration decoration;
  final FocusNode focusNode;
  final FocusNode focusNodeTo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              decoration: decoration,
              placeholder: 'E-mail',
              padding: EdgeInsets.all(15),
              keyboardType: TextInputType.emailAddress,
              onChanged: (email) {
                context.read<SignUpCubit>().emailChanged(email);
              },
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodeTo);
              },
            ),
            const SizedBox(height: 5),
            Hint(
              !state.status.isValidated && state.email.invalid
                  ? 'invalid email'
                  : '',
              type: HintType.error,
            ),
          ],
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  _PasswordInput({
    required this.decoration,
    required this.focusNode,
    required this.focusNodeTo,
  });

  final BoxDecoration decoration;
  final FocusNode focusNode;
  final FocusNode focusNodeTo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              decoration: decoration,
              placeholder: 'Password',
              padding: EdgeInsets.all(15),
              focusNode: focusNode,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (password) {
                context.read<SignUpCubit>().passwordChanged(password);
              },
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodeTo);
              },
            ),
            const SizedBox(height: 5),
            Hint(
              state.password.invalid ? 'invalid password' : '',
              type: HintType.error,
            ),
          ],
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  _ConfirmPasswordInput({
    required this.decoration,
    required this.focusNode,
  });

  final BoxDecoration decoration;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              decoration: decoration,
              placeholder: 'Confirm password',
              padding: EdgeInsets.all(15),
              focusNode: focusNode,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (confirmPassword) {
                context
                    .read<SignUpCubit>()
                    .confirmedPasswordChanged(confirmPassword);
              },
            ),
            const SizedBox(height: 5),
            Hint(
              state.confirmedPassword.invalid ? 'passwords do not match' : '',
              type: HintType.error,
            ),
          ],
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CupertinoActivityIndicator()
            : Container(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  child: Text(
                    'Sign up',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                  onPressed: !state.status.isValidated
                      ? null
                      : () => context.read<SignUpCubit>().signUpFormSubmitted(),
                ),
              );
      },
    );
  }
}
