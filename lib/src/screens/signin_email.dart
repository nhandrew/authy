import 'dart:async';

import 'package:authy/src/blocs/auth_bloc.dart';
import 'package:authy/src/screens/home.dart';
import 'package:authy/src/screens/login.dart';
import 'package:authy/src/screens/verify.dart';
import 'package:authy/src/widgets/alert.dart';
import 'package:authy/src/widgets/button.dart';
import 'package:authy/src/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SigninEmailScreen extends StatefulWidget {
  @override
  _SigninEmailScreenState createState() => _SigninEmailScreenState();
}

class _SigninEmailScreenState extends State<SigninEmailScreen> {
  StreamSubscription _errorMessageSubscription;
  StreamSubscription _processRunningSubscription;
  StreamSubscription _userSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.clearValues();

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
    _errorMessageSubscription.cancel();
    _processRunningSubscription.cancel();
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      stream: authBloc.email,
                      builder: (context, snapshot) {
                        return AuthyTextField(
                          label: 'Email',
                          textInputType: TextInputType.emailAddress,
                          onChanged: authBloc.changeEmail,
                          errorText: snapshot.error,
                        );
                      }),
                  StreamBuilder<String>(
                      stream: authBloc.password,
                      builder: (context, snapshot) {
                        return AuthyTextField(
                          label: 'Password',
                          obscureText: true,
                          onChanged: authBloc.changePassword,
                          errorText: snapshot.error,
                        );
                      }),
                ],
              ),
            ),
            StreamBuilder<bool>(
                stream: authBloc.isEmailSigninValid,
                builder: (context, snapshot) {
                  print(snapshot.data);
                  return AuthyButton(
                    text: 'Sign in',
                    enabled: (snapshot.data == true) ? true : false,
                    onTap: authBloc.signinEmail,
                  );
                })
          ],
        ),
      ),
    );
  }
}
