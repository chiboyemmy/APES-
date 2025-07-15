import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwt_ecommerce_app/features/personalization/controllers/settings_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_utils/utils/constants/enums.dart';

import '../../../common/widgets/loaders/circular_loader.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../routes/routes.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/user_model.dart';
import '../screens/profile/re_authenticate_user_login_form.dart';

/// Controller to manage user-related functionality.
class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> user = UserModel.empty().obs;
  final imageUploading = false.obs;
  final profileLoading = false.obs;
  final profileImageUrl = ''.obs;
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserRepository());
  final settingController = Get.put(SettingsController());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  /// init user data when Home Screen appears
  @override
  void onInit() {
    fetchUserRecord();
    super.onInit();
  }

  /// Fetch user record
  Future<void> fetchUserRecord() async {
    try {
      if (user.value.id.isEmpty) {
        profileLoading.value = true;
        final user = await userRepository.fetchUserDetails();
        this.user(user);
      }
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Warning', message: 'Unable to fetch your information. Try again.');
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user Record from any Registration provider
  Future<void> saveUserRecord({UserModel? user, UserCredential? userCredentials}) async {
    try {
      // First UPDATE Rx User and then check if user data is already stored. If not store new data
      await fetchUserRecord();

      // If no record already stored.
      if (this.user.value.id.isEmpty) {
        if (userCredentials != null) {
          // Convert Name to First and Last Name
          final nameParts = UserModel.nameParts(userCredentials.user!.displayName ?? '');
          final customUsername = UserModel.generateUsername(userCredentials.user!.displayName ?? '');

          // Map data
          final newUser = UserModel(
            id: userCredentials.user!.uid,
            firstName: nameParts[0],
            lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : "",
            userName: customUsername,
            email: userCredentials.user!.email ?? '',
            profilePicture: userCredentials.user!.photoURL ?? '',
            deviceToken: user!.deviceToken,
            isEmailVerified: true,
            isProfileActive: true,
            updatedAt: DateTime.now(),
            createdAt: DateTime.now(),
            role: AppRole.user,
            verificationStatus: VerificationStatus.approved,
            addresses: [],
            orderCount: 0,
            phoneNumber: '',
          );

          // Save user data
          await userRepository.saveUserRecord(newUser);

          // Assign new user to the RxUser so that we can use it through out the app.
          this.user(newUser);
        } else if (user != null) {
          // Save Model when user registers using Email and Password
          await userRepository.saveUserRecord(user);

          // Assign new user to the RxUser so that we can use it through out the app.
          this.user(user);
        }
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Data not saved',
        message: 'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }

  /// Update user record after login (e.g., to update token)
  Future<void> updateUserRecordWithToken(String newToken) async {
    try {
      // Ensure we have fetched the user record before updating
      await fetchUserRecord();
      // Create a map to store the fields we want to update (e.g., token)
      Map<String, dynamic> updatedFields = {'deviceToken': newToken};

      // Call the repository to update the specific fields
      await userRepository.updateSingleField(updatedFields);

      // Update the local RxUser object with the new token
      user.value.deviceToken = newToken;
      user.refresh();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user record: $e',
      );
    }
  }

  /// Update user record after login (e.g., to update Pin)
  Future<void> updateUserRecordWithPin(String pin) async {
    try {
      // Ensure we have fetched the user record before updating
      await fetchUserRecord();
      // Create a map to store the fields we want to update (e.g., token)
      Map<String, dynamic> updatedFields = {'pin': pin};

      // Call the repository to update the specific fields
      await userRepository.updateSingleField(updatedFields);

      // Update the local RxUser object with the new token
      user.value.pin = pin;
      user.refresh();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: TTexts.error.tr,
        message: '${TTexts.failedToUpdateUserRecord.tr}: $e',
      );
    }
  }

  /// Update user order count
  Future<void> updateUserOrderCount() async {
    try {
      // Ensure we have fetched the user record before updating
      await fetchUserRecord();

      int countOrder = user.value.orderCount;
      countOrder++;
      Map<String, dynamic> updatedFields = {'orderCount': FieldValue.increment(1)};

      // Call the repository to update the specific fields
      await userRepository.updateSingleField(updatedFields);

      // Update the local RxUser object with the order Count
      user.value.orderCount = countOrder;
      user.refresh();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user record: $e',
      );
    }
  }

  /// Update user points per purchase
  Future<void> updateUserPointsPerPurchase(double total) async {
    try {
      // Ensure we have fetched the user record before updating
      await fetchUserRecord();

      int points = user.value.points;
      points = points + (total * settingController.settings.value.pointsPerPurchase).toInt();
      Map<String, dynamic> updatedFields = {'points': points};

      // Call the repository to update the specific fields
      await userRepository.updateSingleField(updatedFields);

      // Update the local RxUser object with the order Count
      user.value.points = points;
      user.refresh();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user record: $e',
      );
    }
  }

  /// Update user points as used for purchase
  Future<void> updateUserPointsUsedForPurchase(double usedPoints) async {
    try {
      // Ensure we have fetched the user record before updating
      await fetchUserRecord();

      int points = user.value.points - usedPoints.toInt();
      Map<String, dynamic> updatedFields = {'points': points};

      // Call the repository to update the specific fields
      await userRepository.updateSingleField(updatedFields);

      // Update the local RxUser object with the order Count
      user.value.points = points;
      user.refresh();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user record: $e',
      );
    }
  }

  /// Update user points per purchase
  Future<void> updateUserPointsPerReview() async {
    try {
      // Ensure we have fetched the user record before updating
      await fetchUserRecord();

      int points = user.value.points;
      points = points + settingController.settings.value.pointsPerReview.round();
      Map<String, dynamic> updatedFields = {'points': points};

      // Call the repository to update the specific fields
      await userRepository.updateSingleField(updatedFields);

      // Update the local RxUser object with the order Count
      user.value.points = points;
      user.refresh();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user record: $e',
      );
    }
  }

  /// Update user points per purchase
  Future<void> updateUserPointsPerRating() async {
    try {
      // Ensure we have fetched the user record before updating
      await fetchUserRecord();

      int points = user.value.points;
      points = points + settingController.settings.value.pointsPerRating.round();
      Map<String, dynamic> updatedFields = {'points': points};

      // Call the repository to update the specific fields
      await userRepository.updateSingleField(updatedFields);

      // Update the local RxUser object with the order Count
      user.value.points = points;
      user.refresh();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user record: $e',
      );
    }
  }

  /// Upload Profile Picture
  uploadUserProfilePicture() async {
    try {
      final image =
          await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxHeight: 512, maxWidth: 512);
      if (image != null) {
        imageUploading.value = true;
        final uploadedImage = await userRepository.uploadImage('Users/Images/Profile/', image);
        profileImageUrl.value = uploadedImage;
        Map<String, dynamic> newImage = {'ProfilePicture': uploadedImage};
        await userRepository.updateSingleField(newImage);
        user.value.profilePicture = uploadedImage;
        user.refresh();

        imageUploading.value = false;
        TLoaders.successSnackBar(title: 'Congratulations', message: 'Your Profile Image has been updated!');
      }
    } catch (e) {
      imageUploading.value = false;
      TLoaders.errorSnackBar(title: 'OhSnap', message: 'Something went wrong: $e');
    }
  }

  /// Delete Account Warning
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText:
          'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
        child: const Padding(padding: EdgeInsets.symmetric(horizontal: TSizes.lg), child: Text('Delete')),
      ),
      cancel: OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
      ),
    );
  }

  /// Delete User Account
  void deleteUserAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog('Processing', TImages.docerAnimation);

      /// First re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider = auth.firebaseUser!.providerData.map((e) => e.providerId).first;
      if (provider.isNotEmpty) {
        // Re Verify Auth Email
        if (provider == 'google.com') {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          TFullScreenLoader.stopLoading();
          Get.offAllNamed(TRoutes.logIn);
        } else if (provider == 'facebook.com') {
          TFullScreenLoader.stopLoading();
          Get.offAllNamed(TRoutes.logIn);
        } else if (provider == 'password') {
          TFullScreenLoader.stopLoading();
          Get.to(() => const ReAuthLoginForm());
        }
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// -- RE-AUTHENTICATE before deleting
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      TFullScreenLoader.openLoadingDialog('Processing', TImages.docerAnimation);

      //Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance
          .reAuthenticateWithEmailAndPassword(verifyEmail.text.trim(), verifyPassword.text.trim());
      await AuthenticationRepository.instance.deleteAccount();
      TFullScreenLoader.stopLoading();
      Get.offAllNamed(TRoutes.logIn);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Logout Loader Function
  logout() {
    try {
      Get.defaultDialog(
        contentPadding: const EdgeInsets.all(TSizes.md),
        title: 'Logout',
        middleText: 'Are you sure you want to Logout?',
        confirm: ElevatedButton(
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
            child: Text('Confirm'),
          ),
          onPressed: () async {
            onClose();

            /// On Confirmation show any loader until user Logged Out.
            Get.defaultDialog(
              title: '',
              barrierDismissible: false,
              backgroundColor: Colors.transparent,
              content: const TCircularLoader(),
            );
            await AuthenticationRepository.instance.logout();
          },
        ),
        cancel: OutlinedButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        ),
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
