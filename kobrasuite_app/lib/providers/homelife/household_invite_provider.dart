import 'package:flutter/foundation.dart';
import '../../models/homelife/homelife_profile.dart';
import '../../models/homelife/household_invite.dart';
import '../../services/homelife/household_service.dart';
import '../../services/service_locator.dart';
import '../general/homelife_profile_provider.dart';

class HouseholdInviteProvider extends ChangeNotifier {
  final HouseholdService _svc;
  HomeLifeProfileProvider _profile;

  HouseholdInviteProvider({required HomeLifeProfileProvider homelifeProfileProvider})
      : _profile = homelifeProfileProvider,
        _svc     = serviceLocator<HouseholdService>();

  bool   _busy = false;
  String? _err;
  List<HouseholdInvite> _invites = [];

  bool get isLoading => _busy;
  String? get errorMessage => _err;
  List<HouseholdInvite> get invites => _invites;

  int  get _u  => _profile.userPk;
  int  get _up => _profile.userProfilePk;
  int  get _hp => _profile.homeLifeProfilePk;
  int? get _hh => _profile.householdPk;

  void update(HomeLifeProfileProvider p) => _profile = p;

  Future<void> refresh() async {
    _busy = true; _err = null; notifyListeners();
    try {
      _invites = await _svc.getHouseholdInvites(
          userPk: _u, userProfilePk: _up, homelifeProfilePk: _hp);
    } catch (e) { _err = '$e'; }
    _busy = false; notifyListeners();
  }

  Future<bool> create(String code) async {
    _busy = true; _err = null; notifyListeners();
    try {
      final ok = await _svc.createHouseholdInvite(
          userPk: _u, userProfilePk: _up, homelifeProfilePk: _hp,
          householdPk: _hh, code: code);
      if (ok) await refresh();
      return ok;
    } catch (e) { _err = '$e'; return false; }
    finally { _busy = false; notifyListeners(); }
  }

  Future<bool> redeem(String code) async {
    _busy = true; _err = null; notifyListeners();
    try {
      return await _svc.redeemHouseholdInvite(
          userPk: _u, userProfilePk: _up, homelifeProfilePk: _hp, code: code);
    } catch (e) { _err = '$e'; return false; }
    finally { _busy = false; notifyListeners(); }
  }
}