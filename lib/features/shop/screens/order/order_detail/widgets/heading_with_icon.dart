import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/helpers/helper_functions.dart';

class THeadingWithIcon extends StatelessWidget {
  const THeadingWithIcon({
    super.key,
    this.icon = Iconsax.add,
    required this.title,
    this.color = TColors.primary,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        TCircularIcon(icon: icon, backgroundColor: color.withValues(alpha: 0.1), color: color),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium!.apply(color: dark ? TColors.light : TColors.dark),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
