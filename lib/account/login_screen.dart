/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:email_validator/email_validator.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:gotrue/gotrue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gitjournal/account/account_screen.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';

class LoginPage extends StatefulWidget {
  static const routePath = '/login';

  const LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends SupabaseAuthState<LoginPage> {
  @override
  void onUnauthenticated() {
    print('onUnauthenticated');
  }

  @override
  void onAuthenticated(Session session) {
    print('onAuthenticated');
  }

  @override
  void onReceivedAuthDeeplink(Uri uri) {
    Supabase.instance.log('onReceivedAuthDeeplink uri: $uri');
    Log.i("Received Auth Deep Link: $uri");
  }

  @override
  void onPasswordRecovery(Session session) {}

  @override
  void onErrorAuthenticating(String message) {
    Log.e(message);
  }

  @override
  void initState() {
    super.initState();

    var _ = recoverSupabaseSession();
  }

  @override
  Widget build(BuildContext context) {
    var login = FlutterLogin(
      title: 'GitJournal',
      logo: 'assets/icon/icon.png',
      navigateBackAfterRecovery: false,
      loginAfterSignUp: false,
      // hideForgotPasswordButton: true,
      // hideSignUpButton: true,
      // disableCustomPageTransformer: true,
      // messages: LoginMessages(
      //   userHint: 'User',
      //   passwordHint: 'Pass',
      //   confirmPasswordHint: 'Confirm',
      //   loginButton: 'LOG IN',
      //   signupButton: 'REGISTER',
      //   forgotPasswordButton: 'Forgot huh?',
      //   recoverPasswordButton: 'HELP ME',
      //   goBackButton: 'GO BACK',
      //   confirmPasswordError: 'Not match!',
      //   recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
      //   recoverPasswordDescription: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
      //   recoverPasswordSuccess: 'Password rescued successfully',
      //   flushbarTitleError: 'Oh no!',
      //   flushbarTitleSuccess: 'Succes!',
      //   providersTitle: 'login with'
      // ),
      // theme: LoginTheme(
      //   primaryColor: Colors.teal,
      //   accentColor: Colors.yellow,
      //   errorColor: Colors.deepOrange,
      //   pageColorLight: Colors.indigo.shade300,
      //   pageColorDark: Colors.indigo.shade500,
      //   logoWidth: 0.80,
      //   titleStyle: TextStyle(
      //     color: Colors.greenAccent,
      //     fontFamily: 'Quicksand',
      //     letterSpacing: 4,
      //   ),
      //   // beforeHeroFontSize: 50,
      //   // afterHeroFontSize: 20,
      //   bodyStyle: TextStyle(
      //     fontStyle: FontStyle.italic,
      //     decoration: TextDecoration.underline,
      //   ),
      //   textFieldStyle: TextStyle(
      //     color: Colors.orange,
      //     shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
      //   ),
      //   buttonStyle: TextStyle(
      //     fontWeight: FontWeight.w800,
      //     color: Colors.yellow,
      //   ),
      //   cardTheme: CardTheme(
      //     color: Colors.yellow.shade100,
      //     elevation: 5,
      //     margin: EdgeInsets.only(top: 15),
      //     shape: ContinuousRectangleBorder(
      //         borderRadius: BorderRadius.circular(100.0)),
      //   ),
      //   inputTheme: InputDecorationTheme(
      //     filled: true,
      //     fillColor: Colors.purple.withOpacity(.1),
      //     contentPadding: EdgeInsets.zero,
      //     errorStyle: TextStyle(
      //       backgroundColor: Colors.orange,
      //       color: Colors.white,
      //     ),
      //     labelStyle: TextStyle(fontSize: 12),
      //     enabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
      //       borderRadius: inputBorder,
      //     ),
      //     focusedBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
      //       borderRadius: inputBorder,
      //     ),
      //     errorBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.red.shade700, width: 7),
      //       borderRadius: inputBorder,
      //     ),
      //     focusedErrorBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.red.shade400, width: 8),
      //       borderRadius: inputBorder,
      //     ),
      //     disabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.grey, width: 5),
      //       borderRadius: inputBorder,
      //     ),
      //   ),
      //   buttonTheme: LoginButtonTheme(
      //     splashColor: Colors.purple,
      //     backgroundColor: Colors.pinkAccent,
      //     highlightColor: Colors.lightGreen,
      //     elevation: 9.0,
      //     highlightElevation: 6.0,
      //     shape: BeveledRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //     // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      //     // shape: CircleBorder(side: BorderSide(color: Colors.green)),
      //     // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
      //   ),
      // ),
      termsOfService: [
        TermOfService(
          id: 'newsletter',
          mandatory: false,
          text: 'Subscribe to the GitJournal Newsletter',
        ),
      ],
      userValidator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is empty";
        }
        if (!EmailValidator.validate(value)) {
          return LocaleKeys.settings_email_validator_invalid;
        }
        return null;
      },
      passwordValidator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: _login,
      onSignup: _signup,
      onSubmitAnimationCompleted: () {
        var _ = Navigator.of(context).pushReplacement(_FadePageRoute(
          builder: (context) => const AccountScreen(),
        ));
      },
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        // return _recoverPassword(name);
        // Show new password dialog
      },
      disableCustomPageTransformer: true,
      // showDebugButtons: true,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: login,
    );
  }

  Future<String?> _signup(SignupData signupData) async {
    print('Signup info');
    print('Name: ${signupData.name}');
    print('Password: ${signupData.password}');

    var email = signupData.name;
    var password = signupData.password;

    email = 'test6@gitjournal.io';
    password = 'hellohello';

    var auth = Supabase.instance.client.auth;
    var result = await auth.signUp(
      email,
      password,
      options: AuthOptions(
        redirectTo: 'gitjournal-identity://register-callback',
      ),
    );

    print('Result: $result');

    if (result.error != null) {
      // Show the error
      print('Error ${result.error}');
      return result.error!.message;
    }
    if (result.data == null && result.error == null) {
      // Email Validation
      print('Email verification required');
    }

    print('Terms of serveice');
    print(signupData.termsOfService);
    if (signupData.termsOfService.isNotEmpty) {
      print(signupData.termsOfService[0].accepted);
    }
  }

  Future<String?> _login(LoginData loginData) async {
    var email = loginData.name;
    var password = loginData.password;

    print('Login info');
    print('Name: ${loginData.name}');
    print('Password: ${loginData.password}');

    // For testing
    email = 'test@gitjournal.io';
    password = 'hellohellod';

    var auth = Supabase.instance.client.auth;
    var result = await auth.signIn(email: email, password: password);

    if (result.data?.user != null) {
      return null;
    }

    if (result.error != null) {
      return result.error!.message;
    }
  }
}

class FormBackButton extends StatelessWidget {
  const FormBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: const <Widget>[
            Icon(Icons.keyboard_arrow_left, color: Colors.black),
            Text(
              'Back',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class _FadePageRoute<T> extends MaterialPageRoute<T> {
  _FadePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 600);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == LoginPage.routePath) {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
