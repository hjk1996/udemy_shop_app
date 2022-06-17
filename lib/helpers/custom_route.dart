import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  // page간에 route될 때 transition 효과 정의하는 곳
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 홈 화면인 경우 별다른 효과부여하지 않음.
    if (settings.name == '/') {
      return child;
    }

    // 홈 말고 다른 화면이면 투명해지는 트랜지션 효과 부여함.
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// default route transition을 설정하기 위해 PageTransitionsBuilder를 사용함.
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 홈 화면으로 트랜지션 될 경우에는 아무런 효과 없음.
    if (route.settings.name == '/') {
      return child;
    }

    // 홈 말고 다른 화면이면 투명해지는 트랜지션 효과 부여함.
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
