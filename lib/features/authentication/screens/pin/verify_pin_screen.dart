import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/pin_controller.dart';

class VerifyPinScreen extends StatelessWidget {
  const VerifyPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PinController controller = Get.put(PinController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        showActions: true,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              const SizedBox(height: TSizes.defaultSpace * 2),

              /// Image
              Lottie.asset(TImages.pinCodeIllustration, width: 300),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Title
              Text(TTexts.verifyPINCode.tr, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// subTitle
              Text(TTexts.verifyPinCodeMessage.tr,
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// OTP Text Field
              Obx(
                () => OTPTextField(
                  length: 4,
                  fieldWidth: 60,
                  outlineBorderRadius: 10,
                  onCompleted: (String code) => controller.setEnteredOTP(code),
                  onChanged: (String code) => controller.setEnteredOTP(code),
                  fieldStyle: FieldStyle.box,
                  width: 280,
                  style: Theme.of(context).textTheme.headlineLarge!.apply(fontSizeDelta: 12),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  hasError: controller.hasError.value,
                  keyboardType: TextInputType.number,
                  inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                  spaceBetween: TSizes.spaceBtwItems,
                  otpFieldStyle: OtpFieldStyle(
                    borderColor: TColors.primary,
                    focusBorderColor: dark ? TColors.iconPrimaryLight : TColors.primary,
                    backgroundColor: dark ? TColors.iconPrimaryLight : TColors.disabledTextLight,
                    enabledBorderColor: dark ? TColors.iconPrimaryLight : TColors.disabledTextLight,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Verify Pin Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      if (await controller.verifyPin()) {
                        Get.offNamed(TRoutes.home);
                      }
                    },
                    child: Text(TTexts.verifyPin.tr)),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Forget Pin
              // TextButton(onPressed: () => Get.toNamed(TRoutes.updatePin), child: Text(TTexts.forgetPin.tr)),
              // const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}
