/*
 *    Copyright 2022, the Darwin Framework authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import 'dart:async';

import 'package:darwin_sdk/darwin_sdk.dart';

/// Execution profile based service registration condition.
/// This conditions matches true, if the application is running in the profile
/// specified by [Profile.profile], this behaviour can be inverted by using
/// [Profile.inverse].
class Profile extends Condition {
  final String profile;
  final bool inverse;
  const Profile(this.profile, {this.inverse = false});

  @override
  FutureOr<bool> match(DarwinSystem system) {
    if (inverse) {
      return system.profileMixin.profile != profile;
    } else {
      return system.profileMixin.profile == profile;
    }
  }
}

mixin DarwinSystemProfileMixin on DarwinSystem {
  /// The execution profile of the application.
  String? profile;
}
