/*
  Code adapted from https://github.com/TheAlphamerc/flutter_login_signup/

  MIT License

  Copyright (c) 2020 Sonu Sharma

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

/*
  All Modifications are Licensed under -
    GNU AFFERO GENERAL PUBLIC LICENSE
    Copyright (c) 2020 Vishesh Handa
  See the LICENSE file
*/

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:gotrue/gotrue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/widgets/scroll_view_without_animation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends SupabaseAuthState<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  var _isLoading = false;

  @override
  void onUnauthenticated() {
    print('onUnauthenticated');
  }

  @override
  void onAuthenticated(Session session) {
    print('onAuthenticated');
  }

  @override
  void onPasswordRecovery(Session session) {}
  @override
  void onErrorAuthenticating(String message) {}

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    recoverSupabaseSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    var email = _emailController.text.trim();
    var password = _passwordController.text.trim();

    // For testing
    if (email.isEmpty) email = 'test@gitjournal.io';
    if (password.isEmpty) password = 'hellohello';

    var auth = Supabase.instance.client.auth;
    var result = await auth.signIn(email: email, password: password);

    if (result.data?.user != null) {
      Navigator.of(context).pushReplacementNamed(AppRoute.Account);
    }

    // FIXME: Handle errors like invalid username or password!
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, "/register"),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Don't have an account ?",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _submitButton() {
    var textTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      onPressed: _isLoading ? null : _signIn,
      child: Text(
        _isLoading ? 'Loading' : 'Login',
        style: textTheme.headline3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ScrollViewWithoutAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .12),
                    FormTitle(),
                    const SizedBox(height: 50),
                    _emailPasswordWidget(),
                    const SizedBox(height: 20),
                    _submitButton(),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.centerRight,
                      child: const Text('Forgot Password ?',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(height: height * .055),
                    _createAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 0,
              child: SafeArea(child: FormBackButton()),
            ),
          ],
        ),
      ),
    );
  }
}

class FormBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            const Text(
              'Back',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class FormTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var style = textTheme.headline2!.copyWith(fontFamily: "Lato");
    return Text('GitJournal', style: style);
  }
}
