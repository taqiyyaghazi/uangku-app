enum Environment { dev, prod }

class AppConfig {
  static Environment environment = Environment.prod;

  static bool get isDev => environment == Environment.dev;
  static bool get isProd => environment == Environment.prod;

  static String get title => isDev ? 'Uangku Dev' : 'Uangku';
}
