final class EndpointConstant {
  const EndpointConstant._();

  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String registerInitiate = '/auth/register/initiate';
  static const String registerVerify = '/auth/register/verify';
  static const String registerPassword = '/auth/register/password';
  static const String registerProfile = '/auth/register/profile';
  static const String userProfile = '/users/me';
  static const String propertyFeed = '/properties';
  static const String propertyPlaces = '/properties/places';
  static const String propertyFavorites = '/properties/favorites';
  static const String notifications = '/notifications';
  static const String notificationUnreadCount = '/notifications/unread-count';
  static const String subscriptionConfig = '/subscriptions/config';
  static const String subscriptionInitiate = '/subscriptions/initiate';
  static const String mySubscription = '/subscriptions/me';

  static String propertyFavorite(String id) => '/properties/$id/favorite';

  static const String googleMapsApiKey =
      'AIzaSyAknqfu3Tx0v_XwLHMaGRj5fMQ7rJxYYLY';
}
