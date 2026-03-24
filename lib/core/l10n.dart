import 'package:flutter/material.dart';

class HingaL10n {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome to Hinga+',
      'weather': 'Weather',
      'pests': 'Pests',
      'planner': 'Planner',
      'market': 'Market',
      'support': 'Support',
      'sync_status': 'All data synced',
      'next': 'NEXT',
      'start': 'START',
      'skip': 'SKIP',
    },
    'rw': {
      'welcome': 'Murakaza neza kuri Hinga+',
      'weather': 'HingaHava',
      'pests': 'HingaShinga',
      'planner': 'HingaGahunda',
      'market': 'HingaIsoko',
      'support': 'HingaInama',
      'sync_status': 'Byose byageze kuri seriveri',
      'next': 'KOMEZA',
      'start': 'TANGIRA',
      'skip': 'REKA',
    },
  };

  static String getString(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    return _localizedValues[locale]?[key] ?? _localizedValues['en']![key]!;
  }
}

