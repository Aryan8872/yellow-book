class ApiEndpoints {
  ApiEndpoints._();

  // Auth & Profile
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Offers Catalog
  static const String offersHome = '/offers/home';
  static const String offers = '/offers';
  static String offerById(String id) => '/offers/$id';
  static String trackOfferView(String id) => '/offers/$id/view';
  static String trackOfferRedeem(String id) => '/offers/$id/redeem';

  // Categories
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // Consumer Redemptions
  static String redeemInit(String offerId) => '/offers/$offerId/redeem-init';
  static const String myRedemptions = '/redemptions/me';

  // Subscriptions & Checkout
  static const String subscriptionPlans = '/payments/plans';
  static const String initiatePayment = '/payments/initiate';
  static const String verifyPayment = '/payments/verify';
}

