import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class TRatingAndShare extends StatelessWidget {
  const TRatingAndShare({
    super.key, required this.rating, required this.reviewCount,
  });
  final String rating;
  final String reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Rating
        Row(
          children: [
            const Icon(Iconsax.star5, color: TColors.primary, size: 24),
            const SizedBox(width: TSizes.spaceBtwItems / 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: rating, style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(text: '($reviewCount)'),
                ],
              ),
            ),
          ],
        ),

        ///Share Button
        IconButton(onPressed: () {}, icon: const Icon(Icons.share, size: TSizes.iconMd))
      ],
    );
  }
}
