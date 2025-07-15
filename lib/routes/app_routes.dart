import 'package:cwt_ecommerce_app/features/authentication/screens/login/login.dart';
import 'package:cwt_ecommerce_app/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:cwt_ecommerce_app/home_menu.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../bindings/coupon_binding.dart';
import '../bindings/notifcation_binding.dart';
import '../bindings/otp_binding.dart';
import '../bindings/sign_in_binding.dart';
import '../bindings/user_binding.dart';
import '../features/authentication/screens/onboarding/onboarding.dart';
import '../features/authentication/screens/otp/otp_screen.dart';
import '../features/authentication/screens/phone_number/phone_number_screen.dart';
import '../features/authentication/screens/pin/register_pin_screen.dart';
import '../features/authentication/screens/pin/update_pin_screen.dart';
import '../features/authentication/screens/pin/verify_pin_screen.dart';
import '../features/authentication/screens/signup/signup.dart';
import '../features/authentication/screens/signup/verify_email.dart';
import '../features/authentication/screens/welcome/welcome_screen.dart';
import '../features/chat/screens/chat/chat_screen.dart';
import '../features/chat/screens/chat_list_screen/chat_list_screen.dart';
import '../features/personalization/screens/address/add_new_address.dart';
import '../features/personalization/screens/address/address.dart';
import '../features/personalization/screens/notification/notifcation_detail_screen.dart';
import '../features/personalization/screens/notification/notifcation_screen.dart';
import '../features/personalization/screens/profile/profile.dart';
import '../features/personalization/screens/setting/settings.dart';
import '../features/shop/screens/cart/cart.dart';
import '../features/shop/screens/checkout/checkout.dart';
import '../features/shop/screens/coupon/coupon_screen.dart';
import '../features/shop/screens/favourites/favourite.dart';
import '../features/shop/screens/home/home.dart';
import '../features/shop/screens/order/order.dart';
import '../features/shop/screens/order/order_detail/order_detail_screen.dart';
import '../features/shop/screens/search/search.dart';
import '../features/shop/screens/store/store.dart';
import 'routes.dart';

class AppRoutes {
  static final pages = [
    GetPage(name: TRoutes.phoneSignIn, page: () => const PhoneNumberScreen(), binding: SignInBinding()),
    GetPage(name: TRoutes.home, page: () => const HomeScreen()),
    GetPage(name: TRoutes.homeMenu, page: () => const HomeMenu()),
    GetPage(name: TRoutes.store, page: () => const StoreScreen()),
    GetPage(name: TRoutes.favourites, page: () => const FavouriteScreen()),
    GetPage(name: TRoutes.settings, page: () => const SettingsScreen()),
    GetPage(name: TRoutes.search, page: () => SearchScreen()),
    // GetPage(name: TRoutes.productReviews, page: () => const ProductReviewsScreen()),
    GetPage(name: TRoutes.order, page: () => const OrderScreen()),
    GetPage(name: TRoutes.orderDetail, page: () => const OrderDetail()),
    GetPage(name: TRoutes.checkout, page: () => const CheckoutScreen()),
    GetPage(name: TRoutes.cart, page: () => const CartScreen()),
    GetPage(name: TRoutes.userProfile, page: () => const ProfileScreen()),
    GetPage(name: TRoutes.userAddress, page: () => const UserAddressScreen()),
    GetPage(name: TRoutes.signup, page: () => const SignupScreen(), binding: UserBinding()),
    GetPage(name: TRoutes.verifyEmail, page: () => const VerifyEmailScreen()),
    GetPage(name: TRoutes.logIn, page: () => const LoginScreen()),
    GetPage(name: TRoutes.forgetPassword, page: () => const ForgetPasswordScreen()),
    GetPage(name: TRoutes.onBoarding, page: () => const OnBoardingScreen()),
    GetPage(name: TRoutes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: TRoutes.pin, page: () => const RegisterPinScreen()),
    GetPage(name: TRoutes.verifyPin, page: () => const VerifyPinScreen()),
    GetPage(name: TRoutes.updatePin, page: () => const UpdatePinScreen()),
    GetPage(name: TRoutes.otpVerification, page: () => const OtpScreen(), binding: OtpBinding()),

    GetPage(name: TRoutes.coupon, page: () => const CouponScreen(), binding: CouponBinding(), transition: Transition.fade),
    GetPage(name: TRoutes.coupon, page: () => const CouponScreen(), binding: CouponBinding(), transition: Transition.fade),

    GetPage(name: TRoutes.addNewAddress, page: () => const AddNewAddressScreen(), transition: Transition.fade),

    /// Chats
    GetPage(name: TRoutes.chatList, page: () => const ChatListScreen()),
    GetPage(name: TRoutes.chat, page: () => ChatScreen()),

    GetPage(
      name: TRoutes.notification,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: TRoutes.notificationDetails,
      page: () => const NotificationDetailScreen(),
      binding: NotificationBinding(),
      transition: Transition.fade,
    ),
  ];
}
