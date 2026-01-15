import 'dart:math';
import 'dart:ui';

class Images {
  static String imagePath = 'assets/images';
  static String iconPath = 'assets/icon';

  static String appLogo = '$imagePath/logo/login.png';
  static String success = '$imagePath/app/success.png';

  static String logout = '$iconPath/logout.png';
  static String language = '$iconPath/language.png';
  static String lightDarkMode = '$iconPath/light_dark-mode.png';
  static String bottomBarDividerIcon = '$iconPath/bottombar_divider.png';
  static String successIcon = '$iconPath/success.png';

  static List<String> avatars =
      List.generate(9, (index) => 'assets/avatar/${index + 1}.png');

  static String randomImage(List<String> images) {
    return images[Random().nextInt(images.length)];
  }

  static String getImageBasedOnFirstName(String firstName) {
    int hash = firstName.hashCode;
    int index = hash % avatars.length;
    return avatars[index];
  }

  static Color generateColorFromString(String input) {
    final hash = input.toUpperCase().hashCode;
    int r = (hash & 0xFF0000) >> 16;
    int g = (hash & 0x00FF00) >> 8;
    int b = (hash & 0x0000FF);

    r = (r + 128).clamp(100, 200);
    g = (g + 128).clamp(100, 200);
    b = (b + 128).clamp(100, 200);

    if (r == 255 && g == 255 && b == 255) {
      r = 254;
      g = 254;
      b = 254;
    }

    return Color.fromARGB(255, r, g, b);
  }
}
