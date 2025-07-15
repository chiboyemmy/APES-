import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/login_in_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    // final dark = THelperFunctions.isDarkMode(context);
    final screenWidth = THelperFunctions.screenWidth();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: TSizes.defaultSpace,
              vertical: TSizes.spaceBtwSections),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: TSizes.spaceBtwSections * 1.5),

              /// -- Lottie Animation (Header)
              BounceInDown(
                duration: const Duration(milliseconds: 1200),
                child: Lottie.asset(
                  'assets/images/animations/Animation - 1745236705111.json', // ➜ Add your animation file in assets
                  width: screenWidth * 0.8,
                  repeat: true,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Title
              FadeIn(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Welcome to APES',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: TColors.black,
                      ),
                ),
              ),

              const SizedBox(height: TSizes.sm),

              /// -- Subtitle
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: Text(
                  'Shop smart, live better.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Login Buttons Card
              FadeInUp(
                delay: const Duration(milliseconds: 900),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Column(
                      children: [
                        /// -- Email Login (White icon)
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.email_outlined,
                              size: 28,
                              color: Colors.white, // White icon
                            ),
                            onPressed: () => Get.toNamed(TRoutes.logIn,
                                arguments: 'EmailPassword'),
                            label: const Text('Login with Email & Password'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        /// -- Phone Login (Larger icon)
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.phone_android_outlined,
                              size: 28,
                            ),
                            onPressed: () => Get.toNamed(TRoutes.phoneSignIn),
                            label: const Text('Login with Phone Number'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: TColors.primary),
                              foregroundColor: TColors.primary,
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        /// -- Google Sign-In Button (Larger icon)
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: OutlinedButton.icon(
                            icon: Image.asset(
                              TImages.google,
                              width: 28,
                              height: 28,
                            ),
                            onPressed: () => controller.googleSignIn(),
                            label: const Text('Sign in with Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: TColors.primary),
                              foregroundColor: TColors.primary,
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Footer
              FadeInUp(
                delay: const Duration(milliseconds: 1100),
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey.shade700),
                    children: [
                      TextSpan(
                        text: "Sign up",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.toNamed(TRoutes.signup),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: TColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
