import 'package:event_pro/data/local/contants.dart';

String getRouteForIndex(int index) {
  switch (index) {
    case 0:
      return '/home';
    case 1:
      return constant.userType == constant.exhibitorUser ? '/exhibitorBadge' : '/myBadge';
    case 2:
      return '/scanQR';
    case 3:
      return '/menu';
    default:
      return '/home';
  }
}

// double? convertFigmaWidthToUI(double figmaValue, double screenWidth) {
//   try {
//     double value = (figmaValue * screenWidth) / 430;
//     return value;
//   } catch (e) {
//     return figmaValue;
//   }
// }

// double? convertFigmaHeightToUI(double figmaValue, double screenHeight) {
//   try {
//     double value = (figmaValue * screenHeight) / 858;
//     return value;
//   } catch (e) {
//     return figmaValue;
//   }
// }
