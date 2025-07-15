import 'package:cwt_ecommerce_app/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/widgets.dart';

class TBannerShimmer extends StatelessWidget {
  const TBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const TShimmerEffect(width: double.infinity, height: 190);
  }
}
