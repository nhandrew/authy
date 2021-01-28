import 'dart:async';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:authy/src/models/authy_user.dart';
import 'package:authy/src/services/auth_service.dart';
import 'package:authy/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

final RegExp regExpEmail = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
final RegExp regExpPhone = RegExp(
    r'(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)');

class AuthBloc {
  Timer timer;
  String _verificationCode;
  final _authService = AuthService();
  final _dbService = FirestoreService();
  final fb = FacebookLogin();
  final googleSignin = GoogleSignIn(scopes: ['email']);

  final _email = BehaviorSubject<String>();
  final _phone = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _name = BehaviorSubject<String>();
  final _confirmPassword = BehaviorSubject<String>();
  final _errorMessage = BehaviorSubject<String>();
  final _confirmationCode = BehaviorSubject<String>();
  final _processRunning = BehaviorSubject<bool>();
  final _showConfirmationDialog = BehaviorSubject<bool>();
  final _showAutomatedConfirmationDialog = BehaviorSubject<bool>();
  final _emailVerified = BehaviorSubject<bool>();
  final _user = BehaviorSubject<AuthyUser>();

  AuthBloc() {
    _authService.currentUser().listen((user) {
      if (user != null) {
        setUser(user.uid);
      } else {
        setUser(null);
      }
    });
  }

  //Getters
  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get password => _password.stream.transform(validatePassword);
  Stream<String> get phone => _phone.stream.transform(validatePhone);
  Stream<String> get name => _name.stream.transform(validateName);
  Stream<bool> get emailVerified => _emailVerified.stream;
  Stream<String> get confirmPassword => _confirmPassword.stream.doOnData((c) {
        if (c.compareTo(_password.value) != 0) {
          _confirmPassword.sink.addError('Must match password');
        }
      });

  Stream<bool> get isEmailSignupValid => CombineLatestStream.combine3(
      email,
      password,
      confirmPassword,
      (email, password, combinePassword) =>
          (0 == password.compareTo(combinePassword)));

  Stream<bool> get isEmailSigninValid =>
      CombineLatestStream.combine2(email, password, (email, password) => true);
  Stream<bool> get isVerifyValid =>
      CombineLatestStream.combine2(email, name, (email, name) => true);
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<String> get confirmationCode => _confirmationCode.stream;
  Stream<bool> get processRunning => _processRunning.stream;
  Stream<AuthyUser> get user => _user.stream;
  Stream<bool> get showConfirmationDialog => _showConfirmationDialog;
  Stream<bool> get showAutomatedConfirmationDialog =>
      _showAutomatedConfirmationDialog;

  //Setters
  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changePassword => _password.sink.add;
  Function(String) get changeName => _name.sink.add;
  Function(String) get changePhone => _phone.sink.add;
  Function(String) get changeConfirmPassword => _confirmPassword.sink.add;
  Function(String) get changeConfirmationCode => _confirmationCode.sink.add;
  Function(bool) get changeShowAutomatedConfirmationDialog =>
      _showAutomatedConfirmationDialog.sink.add;

  setUser(String userId) async {
    if (userId != null) {
      var user = await _dbService.getUser(userId);
      _user.sink.add(user);
    } else {
      _user.sink.add(null);
    }
  }

  //Validators
  final validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password != null) {
      if (password.length >= 8) {
        sink.add(password.trim());
      } else {
        sink.addError('8 Character Minimum');
      }
    }
  });

  //Validators
  final validateName =
      StreamTransformer<String, String>.fromHandlers(handleData: (name, sink) {
    if (name != null) {
      if (name.length >= 6) {
        sink.add(name.trim());
      } else {
        sink.addError('6 Character Minimum');
      }
    }
  });

  final validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email != null) {
      if (regExpEmail.hasMatch(email.trim())) {
        sink.add(email.trim());
      } else {
        sink.addError('Valid Email Required');
      }
    }
  });

  final validatePhone =
      StreamTransformer<String, String>.fromHandlers(handleData: (phone, sink) {
    if (phone != null) {
      if (regExpPhone.hasMatch(phone.trim())) {
        sink.add(phone.trim());
      } else {
        sink.addError('Valid Phone# Required');
      }
    }
  });

  //Methods
  dispose() {
    _confirmPassword.close();
    _emailVerified.close();
    _name.close();
    _email.close();
    _phone.close();
    _password.close();
    _errorMessage.close();
    _processRunning.close();
    _confirmationCode.close();
    _user.close();
    _showConfirmationDialog.close();
    _showAutomatedConfirmationDialog.close();
    timer.cancel();
  }

  clearValues() {
    changePassword(null);
    changeEmail(null);
    changeConfirmPassword(null);
    _errorMessage.sink.add('');
    _confirmationCode.sink.add('');
  }

  clearErrorMessage() {
    _errorMessage.sink.add('');
  }

  signupEmail() async {
    try {
      //Mark Process as Running
      _processRunning.sink.add(true);

      //Create Firebase Auth Record
      UserCredential authResult =
          await _authService.signupEmail(_email.value, _password.value);

      //Create App Database User
      var authyUser = AuthyUser(
          email: authResult.user.email,
          userId: authResult.user.uid,
          verified: false);
      await _dbService.setUser(authyUser);

      //Mark Process as Stopped
      _processRunning.sink.add(false);
    } on FirebaseAuthException catch (error) {
      _processRunning.sink.add(false);
      _errorMessage.sink.add(error.message);
    } catch (error) {
      _processRunning.sink.add(false);
      _errorMessage.sink.add(error.toString());
    }
  }

  signinEmail() async {
    try {
      //Mark Process as Running
      _processRunning.sink.add(true);

      //Create Firebase Auth Record
      await _authService.signinEmail(_email.value, _password.value);

      //Mark Process as Stopped
      _processRunning.sink.add(false);
    } on FirebaseAuthException catch (error) {
      _processRunning.sink.add(false);
      _errorMessage.sink.add(error.message);
    } catch (error) {
      _processRunning.sink.add(false);
      _errorMessage.sink.add(error.toString());
    }
  }

  verifyEmail() async {
    var user = _authService.user();
    await user.updateEmail(_email.value);
    _authService.verifyEmail();
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      var user = _authService.user();
      await user.reload();
      if (user.emailVerified) {
        _emailVerified.sink.add(true);
        _dbService.updateEmailVerified(
          email: _email.value,
          userId: user.uid,
          verified: user.emailVerified,
          displayName: _name.value,
        );
        timer.cancel();
      } else if (timer.tick > 60) {
        //Timeout
        timer.cancel();
      }
    });
  }

  signinFacebook() async {
    //Mark Process as Running
    _processRunning.sink.add(true);
    //Facebook Login
    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email
    ]);

    switch (res.status) {
      case FacebookLoginStatus.success:
        try {
          final FacebookAccessToken fbToken = res.accessToken;
          AuthCredential credential =
              FacebookAuthProvider.credential(fbToken.token);

          await signinWithCredential(credential);

          _processRunning.sink.add(false);
        } on PlatformException catch (error) {
          _processRunning.sink.add(false);
          _errorMessage.sink.add(error.message);
        } on FirebaseAuthException catch (error) {
          _processRunning.sink.add(false);
          _errorMessage.sink.add(error.message);
        }
        break;
      case FacebookLoginStatus.cancel:
        _processRunning.sink.add(false);
        break;
      case FacebookLoginStatus.error:
        _processRunning.sink.add(false);
        _errorMessage.sink.add('Facebook Authorization Failed');
        break;
    }
  }

  signinGoogle() async {

    try {
      final GoogleSignInAccount googleUser = await googleSignin.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      _processRunning.sink.add(true);
      await signinWithCredential(credential);

      _processRunning.sink.add(false);
    } on PlatformException catch (error) {
      _processRunning.sink.add(false);
      _errorMessage.sink.add(error.message);
    } on FirebaseAuthException catch (error) {
      _processRunning.sink.add(false);
      _errorMessage.sink.add(error.message);
    }
  }

  signinApple() async {
    if (!await AppleSignIn.isAvailable()) {
      _errorMessage.sink.add('This Device is not eligible for Apple Sign in');
      return null; //Break from the program
    }

    final res = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    _processRunning.sink.add(true);

    switch (res.status) {
      case AuthorizationStatus.authorized:
        try {
          //Get Token
          final AppleIdCredential appleIdCredential = res.credential;
          final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
              idToken: String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
                  String.fromCharCodes(appleIdCredential.authorizationCode));

          await signinWithCredential(credential);

          _processRunning.sink.add(false);
        } on PlatformException catch (error) {
          _processRunning.sink.add(false);
          _errorMessage.sink.add(error.message);
        } on FirebaseAuthException catch (error) {
          _processRunning.sink.add(false);
          _errorMessage.sink.add(error.message);
        }
        break;
      case AuthorizationStatus.error:
        _processRunning.sink.add(false);
        _errorMessage.sink.add('Apple authorization failed');
        break;
      case AuthorizationStatus.cancelled:
        _processRunning.sink.add(false);
        break;
    }
  }

  signupPhone() {
    _processRunning.sink.add(true);
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phone.value,
      verificationCompleted: (PhoneAuthCredential credential) async {
        _showConfirmationDialog.sink.add(false);
        _showAutomatedConfirmationDialog.sink.add(true);
        await signinWithCredential(credential);
        _processRunning.sink.add(false);
      },
      verificationFailed: (FirebaseAuthException e) {
        _errorMessage.sink.add(e.message);
        _processRunning.sink.add(false);
      },
      codeSent: (String verificationId, int resendToken) {
        _verificationCode = verificationId;
        //Show Popup to confirm code
        _confirmationCode.sink.add(null);
        _showConfirmationDialog.sink.add(true);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _processRunning.sink.add(false);
      },
    );
  }

  submitSMSCode() {
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: _verificationCode, smsCode: _confirmationCode.value);

      // Sign the user in (or link) with the credential
      signinWithCredential(phoneAuthCredential, verified: false);
      _processRunning.sink.add(false);
    } on PlatformException catch (error) {
      _processRunning.sink.add(false);
      _errorMessage.sink.add(error.message);
    } on FirebaseAuthException catch (error) {
      _processRunning.sink.add(false);
      _errorMessage.sink.add(error.message);
    }
  }

  Future<void> signinWithCredential(AuthCredential credential,
      {bool verified = true}) async {
    //Sign in to Firebase
    final result = await _authService.signinWithCredential(credential);
    //Check for existing user, Add if not yet registered
    var user = await _dbService.getUser(result.user.uid);
    if (user == null) {
      //Create App Database User
      var authyUser = AuthyUser(
          email: result.user.email,
          userId: result.user.uid,
          verified: verified,
          displayName: result.user.displayName);
      await _dbService.setUser(authyUser);
    }

    setUser(result.user.uid);
  }

  Future<void> signOut() => _authService.signOut();
}
