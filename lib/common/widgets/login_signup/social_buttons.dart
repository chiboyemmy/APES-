import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/authentication/controllers/login_in_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';

class TSocialButtons extends StatelessWidget {
  const TSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // /// Google Button
        // Container(
        //   padding: const EdgeInsets.all(TSizes.xs),
        //   decoration: BoxDecoration(border: Border.all(color: TColors.grey), borderRadius: BorderRadius.circular(100)),
        //   child: IconButton(
        //     onPressed: () => controller.googleSignIn(),
        //     icon: const Image(width: TSizes.iconMd + 4, height: TSizes.iconMd + 4, image: AssetImage(TImages.google)),
        //   ),
        // ),
        // const SizedBox(width: TSizes.spaceBtwItems),

        /// Facebook Button
        Container(
          padding: const EdgeInsets.all(TSizes.xs),
          decoration: BoxDecoration(border: Border.all(color: TColors.grey), borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: () => showComingSoonDialog(context),
            icon: const Image(width: TSizes.iconMd + 4, height: TSizes.iconMd + 4, image: AssetImage(TImages.facebook)),
          ),
        ),
      ],
    );
  }
}
// Function to show a professional dialog
void showComingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 8),
          Text("Coming Soon"),
        ],
      ),
      content: const Text(
        "Facebook login will be available in a future update. Stay tuned for exciting new features!",
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK", style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}
