import 'dart:async';
import 'dart:io';

import 'package:authy/src/blocs/auth_bloc.dart';
import 'package:authy/src/blocs/auth_bloc.dart';
import 'package:authy/src/blocs/auth_bloc.dart';
import 'package:authy/src/screens/home.dart';
import 'package:authy/src/screens/login.dart';
import 'package:authy/src/screens/signin_phone.dart';
import 'package:authy/src/screens/signup_email.dart';
import 'package:authy/src/screens/verify.dart';
import 'package:authy/src/widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  StreamSubscription _errorMessageSubscription;
  StreamSubscription _processRunningSubscription;
  StreamSubscription _userSubscription;
  bool _isLoading = false;
  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);

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
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/authy.png'),
              SignInButton(Buttons.Email, onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignupEmailScreen())
              ),text: 'Sign up with Email',),
              SignInButtonBuilder(
                elevation: 2.0,
                key: ValueKey("GitHub"),
                mini: false,
                text: 'Sign up with Phone',
                icon: FontAwesomeIcons.phone,
                backgroundColor: Colors.purple,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => SigninPhoneScreen(Mode.Signup))),
                padding: const EdgeInsets.all(0),
                //shape: shape,
              ),
              SignInButton(Buttons.GoogleDark, onPressed: () => authBloc.signinGoogle(),text: 'Sign up with Google',),
              SignInButton(Buttons.Facebook, onPressed: () => authBloc.signinFacebook() ,text: 'Sign up with Facebook',),
              (Platform.isIOS)
                  ? SignInButton(Buttons.AppleDark, onPressed: () => authBloc.signinApple(),text: 'Sign up with Apple',)
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Or',style:Theme.of(context).textTheme.headline6.copyWith(color:Colors.white)),
              ),
              SignInButtonBuilder(
                elevation: 2.0,
                key: ValueKey("GitHub"),
                mini: false,
                text: 'Sign in with Existing',
                icon: FontAwesomeIcons.signInAlt,
                backgroundColor: Colors.deepPurple,
                onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen())),
                padding: const EdgeInsets.all(0),
                //shape: shape,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
