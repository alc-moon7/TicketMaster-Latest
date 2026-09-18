import 'package:flutter/material.dart';

class TmColors {
  static const brandBlue = Color(0xFF026CDF);
  static const darkBackground = Color(0xFF1F2730);
  static const headerBlack = Colors.black;
  static const navUnselected = Color(0xFF9E9E9E);
  static const divider = Color(0xFFE0E0E0);
  static const lightBorder = Color(0xFFDDDDDD);
  static const ticketHeader = Color(0xFF242528);
  static const ticketBody = Color(0xFF242528);
  static const hintGrey = Color(0xFF8C8C8C);
}

class TmTypography {
  static const family = 'Metropolis';

  static const header = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const navLabel = TextStyle(fontWeight: FontWeight.w400);
}

class TmSpacing {
  static const s4 = 4.0;
  static const s6 = 6.0;
  static const s8 = 8.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s14 = 14.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
}

class TmRadii {
  static const card = 8.0;
  static const pill = 6.0;
  static const button = 3.0;
}

class TmDurations {
  static const splashFade = Duration(milliseconds: 300);
  static const splashScale = Duration(milliseconds: 500);
  static const splashHold = Duration(milliseconds: 900);
  static const splashExitDelay = Duration(milliseconds: 120);
  static const tabSwitch = Duration(milliseconds: 300);
  static const listAppear = Duration(milliseconds: 320);
}

class TmCurves {
  static const easeOut = Curves.easeOutCubic;
}

class TmAssets {
  static const splashVideo = 'assets/splash_screen.mp4';
  static const splashLogo = 'assets/apk/images/t.png';
  static const brandLogo = 'assets/apk/images/ticketmaster-logo.png';
  static const loginMark = 'assets/tm/t_icon_no_padding.png';
  static const flag = 'assets/apk/images/usaflag3.png';
  static const locationIcon = 'assets/apk/images/location.png';
  static const dateIcon = 'assets/apk/images/date.png';
  static const searchIcon = 'assets/apk/images/icon_blue_white.png';
  static const discoverHero = 'assets/apk/images/discover_back.jpg';
  static const discoverPerson = 'assets/apk/images/discover_person.png';
  static const discoverReference = 'screenshot/IMG_0368.PNG';
  static const ticketsSelectedReference = 'screenshot/IMG_0372.PNG';
  static const forYouEmpty = 'assets/apk/images/Landing_Icon.png';
  static const sellHero = 'assets/apk/images/resale.png';

  static const bottomDiscover = 'assets/apk/images/bottom/01.png';
  static const bottomForYou = 'assets/apk/images/bottom/02.png';
  static const bottomTickets = 'assets/apk/images/bottom/03.png';
  static const bottomSell = 'assets/apk/images/bottom/04.png';
  static const bottomAccount = 'assets/apk/images/bottom/05.png';

  static const bottomDiscoverOn = 'assets/apk/images/bottom_click/1.png';
  static const bottomForYouOn = 'assets/apk/images/bottom_click/2.png';
  static const bottomTicketsOn = 'assets/apk/images/bottom_click/3.png';
  static const bottomSellOn = 'assets/apk/images/bottom_click/4.png';
  static const bottomAccountOn = 'assets/apk/images/bottom_click/5.png';
}
