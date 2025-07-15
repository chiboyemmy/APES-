import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/formatters/formatter.dart';
import '../../../models/product_review_model.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.reviewModel});

  final ReviewModel reviewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(foregroundImage: NetworkImage(reviewModel.userProfileImage!), backgroundColor: TColors.grey),
          title: Text(reviewModel.userName, style:  Theme.of(context).textTheme.titleSmall),
          trailing: SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  TFormatter.formatDate(reviewModel.createdAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.star_half_outlined,
                      color: TColors.primary,
                    ),
                    Text('${reviewModel.rating}/5', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Text(reviewModel.reviewText, style: Theme.of(context).textTheme.bodySmall?.apply(color: TColors.darkGrey)),
        ReadMoreText(
          reviewModel.reviewText,
          trimLines: 4,
          colorClickableText: TColors.primary,
          trimMode: TrimMode.Line,
          trimCollapsedText: ' Show more',
          trimExpandedText: ' Show less',
          style: Theme.of(context).textTheme.bodySmall?.apply(color: TColors.darkGrey),
          moreStyle: const TextStyle(fontWeight: FontWeight.bold),
          lessStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
