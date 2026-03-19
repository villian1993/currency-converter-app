import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_font.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/common_gradient_divider.dart';

class CurrencySearchBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearchPressed;
  final Function(String) onSearchChanged;
  final String title;

  const CurrencySearchBox({
    super.key,
    required this.controller,
    required this.onSearchPressed,
    required this.onSearchChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightCL,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          AppText(
            title,
            themeTextStyle: Theme.of(context).textTheme.bodyMedium,
            fontWeight: AppFont.manropeBold,
            color: AppColors.lightBlackTextColor,
            fontSize: 14,
          ),

          const SizedBox(height: 8),
          const GradientDivider(),
          const SizedBox(height: 8),

          // Search TextField
          Container(
            height: 36,
            decoration: const BoxDecoration(color: Colors.white),
            child: TextField(
              controller: controller,
              onChanged: (value) {
                onSearchChanged(value);
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus(); // ⬅ hides keyboard
                onSearchChanged(controller.text.trim());
              },
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E1E1E),
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8, right: 4),
                  child: Icon(
                    Icons.search,
                    color: Color(0x99001D53),
                    size: 18,
                  ),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onSearchChanged("");
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                )
                    : null,
                hintText: "Enter Currency",
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGrayColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Colors.white,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}