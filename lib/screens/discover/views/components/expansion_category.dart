import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../constants.dart';

class ExpansionCategory extends StatelessWidget {
  const ExpansionCategory({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      iconColor: Theme.of(context).textTheme.bodyLarge!.color,
      collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
      leading: SvgPicture.asset(
        "assets/icons/Category.svg",
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
          Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontSize: 14),
      ),
      textColor: Theme.of(context).textTheme.bodyLarge!.color,
      childrenPadding: const EdgeInsets.only(left: defaultPadding * 3.5),
      children: category.categoryChildren != null
          ? List.generate(
              category.categoryChildren!.length,
              (index) => Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                    title: Text(
                      category.categoryChildren![index].name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (index < category.categoryChildren!.length - 1)
                    const Divider(height: 1),
                ],
              ),
            )
          : [],
    );
  }
}
