/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gitjournal/app_router.dart';

class AccountScreen extends StatefulWidget {
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
      Navigator.of(context).pushReplacementNamed(AppRoute.Login);
    }
  }

  // Do we want to handle onAuthenticated ?
}
