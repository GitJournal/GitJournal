// ignore_for_file: avoid_print

/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  static const routePath = '/login';

  const LoginPage({super.key, this.title});

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();

    _initAsync();
  }

  Future<void> _initAsync() async {
    await Supabase.initialize(
      url: 'https://kokulrmhlfxdwuvcmblj.supabase.co',
      anonKey: '<key>',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: _login,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<String?> _login() async {
    final supabase = Supabase.instance.client;
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: 'test@gitjournal.io',
      password: '<pass>',
    );
    final session = res.session;
    final user = res.user;

    print("User: $user");
    print("Session: $session");

    final qr = await supabase.from('analytics_device_info').select();
    print(qr);
    return "";
  }
}

/*

Next Steps:

1. Create a simple table about user_info which has the bool 'pro'
2. Add RLS to that table so only the user can see read own data
3. Add RLS to the other tables (make sure no one can read those)
4. Figure out how the Supabase session data is saved!
5. Create a very simple login/password screen, and just allow the user to login
6. Direct the user to the account_screen or login_screen depending if they are logged in
7. Add a logout button to the account_screen

 */