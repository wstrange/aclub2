// Holds current state information about the logged in user
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// import 'section.dart';
import 'user_profile.dart';

part 'user_state.freezed.dart';

/// Holds current state information aboaut the loggin in user.
@freezed
class UserState({
  required UserProfile userModel,
  required UserInfo userInfo,
  //required Section currentSection
}) with _$UserState;
