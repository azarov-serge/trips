import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:trips/pages/pages.dart';
import 'package:trips/widgets/widgets.dart';

class LoginForm extends StatelessWidget {
  LoginForm({Key? key}) : super(key: key);
  final _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = BoxDecoration(
      border: Border.all(
        color: CupertinoTheme.of(context).barBackgroundColor,
        width: 2,
      ),
    );

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          _showErrorAlert(context, 'Authentication Failure');
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _FormLogo(),
              const SizedBox(height: 16.0),
              _EmailInput(
                decoration: textFieldDecoration,
                focusNodeTo: _passwordFocusNode,
              ),
              const SizedBox(height: 8.0),
              _PasswordInput(
                decoration: textFieldDecoration,
                focusNode: _passwordFocusNode,
              ),
              const SizedBox(height: 8.0),
              const _LoginButton(),
              const SizedBox(height: 80),
              const _SignUpButton(),
            ],
          ),
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

class _FormLogo extends StatelessWidget {
  const _FormLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: const Logo(),
    );
  }
}

class _EmailInput extends StatelessWidget {
  _EmailInput({
    required this.decoration,
    required this.focusNodeTo,
  });
  final BoxDecoration decoration;
  final FocusNode focusNodeTo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
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
              onChanged: (email) =>
                  context.read<LoginCubit>().emailChanged(email),
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodeTo);
              },
            ),
            const SizedBox(height: 5),
            Hint(
              state.email.invalid ? 'invalid email' : '',
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
  });

  final BoxDecoration decoration;
  final FocusNode focusNode;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
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
              onChanged: (password) =>
                  context.read<LoginCubit>().passwordChanged(password),
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

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CupertinoActivityIndicator()
            : Container(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      color: CupertinoColors.white,
                    ),
                  ),
                  onPressed: state.status.isValidated
                      ? () => context.read<LoginCubit>().logInWithCredentials()
                      : null,
                ),
              );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: CupertinoButton(
        key: const Key('loginForm_CupertinoButton'),
        child: Text('Don\'t have an account? Sing up'),
        onPressed: () {
          Navigator.of(context).push(SignUpPage.route());
        },
      ),
    );
  }
}
