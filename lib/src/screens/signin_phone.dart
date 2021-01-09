import 'dart:async';

import 'package:authy/src/blocs/auth_bloc.dart';
import 'package:authy/src/screens/home.dart';
import 'package:authy/src/screens/login.dart';
import 'package:authy/src/screens/verify.dart';
import 'package:authy/src/widgets/alert.dart';
import 'package:authy/src/widgets/button.dart';
import 'package:authy/src/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SigninPhoneScreen extends StatefulWidget {
  final Mode mode;

  SigninPhoneScreen(this.mode);

  @override
  _SigninPhoneScreenState createState() => _SigninPhoneScreenState();
}

class _SigninPhoneScreenState extends State<SigninPhoneScreen> {
  StreamSubscription _errorMessageSubscription;
  StreamSubscription _processRunningSubscription;
  StreamSubscription _userSubscription;
  StreamSubscription _verificationCodeSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context,listen: false);
    authBloc.changePhone(null);
    authBloc.changeShowAutomatedConfirmationDialog(false);

    _errorMessageSubscription = authBloc.errorMessage.listen((errorMessage) {
      if (errorMessage != '') {
        AuthyAlert.showErrorDialog(context, errorMessage);
      }
    });

    _processRunningSubscription = authBloc.processRunning.listen((running) {
      if (running != null) {
        setState(() {
          _isLoading = running;
        });
      }
    });

    _verificationCodeSubscription = authBloc.showConfirmationDialog.listen((event) {
      if (event == true) {
        AuthyAlert.showCodeConfirmationDialog(context, authBloc);
      }
    });

    _userSubscription = authBloc.user.listen((user) {
      if (user != null)
        if (user.verified == true) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => VerifyScreen(user.email)));
        }
    });

    super.initState();
  }
  @override
  void dispose() {
    _verificationCodeSubscription.cancel();
    _errorMessageSubscription.cancel();
    _processRunningSubscription.cancel();
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.solidArrowAltCircleLeft,
            size: 45.0,
            color: Colors.deepPurple,
          ),
          onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen())),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<String>(
                      stream: authBloc.phone,
                      builder: (context, snapshot) {
                        return AuthyTextField(
                          label: 'Phone +19997775555',
                          textInputType: TextInputType.phone,
                          onChanged: authBloc.changePhone,
                          errorText: snapshot.error,
                        );
                      }),

                ],
              ),
            ),
            StreamBuilder<String>(
                stream: authBloc.phone,
                builder: (context, snapshot) {

                  return AuthyButton(
                    text: (widget.mode == Mode.Signin) ? 'Sign in': 'Sign up',
                    enabled: (snapshot.data != null) ? true : false,
                    onTap: authBloc.signupPhone,
                  );
                })
          ],
        ),
      ),
    );
  }
}

enum Mode{
  Signin,
  Signup
}

