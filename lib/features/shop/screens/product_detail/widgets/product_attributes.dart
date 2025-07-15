import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_utils/common/widgets/chips/choice_chip.dart';

import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../common/widgets/texts/t_product_price_text.dart';
import '../../../../../common/widgets/texts/t_product_title_text.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/variation_controller.dart';
import '../../../models/product_model.dart';

class TProductAttributes extends StatelessWidget {
  const TProductAttributes({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = VariationController.instance;
    controller.resetSelectedAttributes();
    return Obx(
      () => Column(
        children: [
          /// -- Selected Attribute Pricing & Description
          if (controller.selectedVariation.value.id.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const TSectionHeading(title: 'Variation: ', showActionButton: false),
                    const SizedBox(width: TSizes.spaceBtwItems),

                    /// Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const TProductTitleText(title: 'Price : ', smallSize: true),
                            if (controller.selectedVariation.value.salePrice > 0)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: TSizes.spaceBtwItems),
                                  Text(
                                    controller.selectedVariation.value.price.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .apply(decoration: TextDecoration.lineThrough),
                                  ),
                                  const SizedBox(width: TSizes.spaceBtwItems)
                                ],
                              ),
                            TProductPriceText(
                              price: controller.selectedVariation.value.salePrice > 0
                                  ? controller.selectedVariation.value.salePrice.toString()
                                  : controller.selectedVariation.value.price.toString(),
                            ),
                          ],
                        ),

                        /// Stock
                        Row(
                          children: [
                            const TProductTitleText(title: 'Stock : ', smallSize: true),
                            Text(controller.selectedVariation.value.stock.toString(),
                                style: Theme.of(context).textTheme.titleMedium)
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                TProductTitleText(
                  title: controller.selectedVariation.value.description.toString(),
                  smallSize: true,
                  maxLines: 4,
                ),
              ],
            ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// -- Attributes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: product.attributes!
                .map((attribute) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TSectionHeading(title: attribute.name, showActionButton: false),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        Obx(
                          () => attribute.isColorAttribute
                              ? Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: attribute.values.map((colorValue) {
                                    final colorList = controller.convertStringsToColors(attribute.values);
                                    final colorIndex = attribute.values.indexOf(colorValue);
                                    final color = (colorIndex != -1 && colorIndex < colorList.length)
                                        ? colorList[colorIndex]
                                        : Colors.grey; // Fallback color

                                    final isSelected = controller.selectedAttributes[attribute.name] == colorValue;
                                    return GestureDetector(
                                      onTap: () {
                                        if (controller
                                            .getAttributesAvailabilityInVariation(product.variations!, attribute.name)
                                            .contains(colorValue)) {
                                          controller.onAttributeSelected(product, attribute.name, colorValue);
                                        }
                                      },
                                      child: Container(
                                        width: isSelected ? 36 : 30,
                                        height: isSelected ? 36 : 30,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: isSelected ? Colors.black : Colors.grey, width: isSelected ? 2 : 1),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: attribute.values.map((attributeValue) {
                                    final isSelected = controller.selectedAttributes[attribute.name] == attributeValue;
                                    final available = controller
                                        .getAttributesAvailabilityInVariation(product.variations!, attribute.name)
                                        .contains(attributeValue);

                                    return TChoiceChip(
                                      text: attributeValue,
                                      selected: isSelected,
                                      onSelected: available
                                          ? (selected) {
                                              if (selected && available) {
                                                controller.onAttributeSelected(
                                                    product, attribute.name, attributeValue);
                                              }
                                            }
                                          : null,
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
