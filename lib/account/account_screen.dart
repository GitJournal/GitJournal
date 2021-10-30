/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gitjournal/account/login_screen.dart';

class AccountScreen extends StatefulWidget {
  static const routePath = '/account';

  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends SupabaseAuthRequiredState<AccountScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      body: Center(
        child: user == null
            ? const CircularProgressIndicator()
            : Text(user.email!),
      ),
    );
  }

  @override
  void onUnauthenticated() {
    if (mounted) {
      var _ = Navigator.pushReplacementNamed(context, LoginPage.routePath);
    }
  }

  // Do we want to handle onAuthenticated ?
}
