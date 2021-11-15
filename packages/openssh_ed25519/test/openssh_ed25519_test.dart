/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:convert';

import 'package:test/test.dart';

import 'package:openssh_ed25519/openssh_ed25519.dart';

void main() {
  test('Writing', () async {
    var public64 = 'ksOdzR271XtjQ3O6XkZ71gfrpdo0/GvA7mlv2KrH6iQ=';
    var private64 =
        'qTqQOBNbdHY9GQiznM+I4DI1xHH3AX23IvMqEZF6ks+Sw53NHbvVe2NDc7peRnvWB+ul2jT8a8DuaW/YqsfqJA==';

    var openSshPublic64 =
        'c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpMRG5jMGR1OVY3WTBOenVsNUdlOVlINjZYYU5QeHJ3TzVwYjlpcXgrb2sK';
    var openSshPrivate64 =
        'LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUFNd0FBQUF0egpjMmd0WldReU5UVXhPUUFBQUNDU3c1M05IYnZWZTJORGM3cGVSbnZXQit1bDJqVDhhOER1YVcvWXFzZnFKQUFBCkFJaWF5d1JDbXNzRVFnQUFBQXR6YzJndFpXUXlOVFV4T1FBQUFDQ1N3NTNOSGJ2VmUyTkRjN3BlUm52V0IrdWwKMmpUOGE4RHVhVy9ZcXNmcUpBQUFBRUNwT3BBNEUxdDBkajBaQ0xPY3o0amdNalhFY2ZjQmZiY2k4eW9Sa1hxUwp6NUxEbmMwZHU5VjdZME56dWw1R2U5WUg2NlhhTlB4cndPNXBiOWlxeCtva0FBQUFBQUVDQXdRRgotLS0tLUVORCBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K';

    var publicBytes = base64.decode(public64);
    var privateBytes = base64.decode(private64).sublist(0, 32);

    var expectedPublic = utf8.decode(base64.decode(openSshPublic64));
    var expectedPrivate = utf8.decode(base64.decode(openSshPrivate64));

    var actualPublic = encodeEd25519Public(publicBytes);
    var actualPrivate = encodeEd25519Private(
      privateBytes: privateBytes,
      publicBytes: publicBytes,
      nonce: 2596996162,
    );

    expect(actualPublic, expectedPublic);
    expect(actualPrivate, expectedPrivate);
  });
}
