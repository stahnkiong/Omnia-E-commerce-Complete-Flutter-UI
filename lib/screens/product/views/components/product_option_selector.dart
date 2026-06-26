import 'package:flutter/material.dart';
import '../../../../constants.dart';

class ProductOptionSelector extends StatelessWidget {
  final String title;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const ProductOptionSelector({
    super.key,
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: defaultPadding / 2),
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: values.length,
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            itemBuilder: (context, index) {
              final val = values[index];
              final isSelected = val == selectedValue;
              return GestureDetector(
                onTap: () => onSelected(val),
                child: Container(
                  margin: const EdgeInsets.only(right: defaultPadding / 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: defaultPadding / 2,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(defaultBorderRadious),
                    ),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    val,
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}
