import 'package:currency_converter_app/src/config/theme/app_colors.dart';
import 'package:currency_converter_app/src/core/widgets/app_text.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.titleText,
    this.showBackButton = false,
    this.leadingIcon,
    this.showTitleIcon = false,
    this.titleIcon,
    this.trailingIcon,
    this.onTrailingPressed,
    this.hideHomeButton = false,
    this.actions,
    this.onHomePressed,
  });

  final String titleText;
  final bool showBackButton;
  final Widget? leadingIcon;

  final bool showTitleIcon;
  final Widget? titleIcon;

  final Widget? trailingIcon;
  final VoidCallback? onTrailingPressed;

  final bool hideHomeButton;
  final List<Widget>? actions;
  final VoidCallback? onHomePressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: leadingIcon ?? const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leadingIcon,
      iconTheme: const IconThemeData(color: AppColors.textNavyBlue),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitleIcon && titleIcon != null) ...[
            titleIcon!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: AppText(
              titleText,
              themeTextStyle: Theme.of(context).textTheme.titleMedium,
              fontWeight: FontWeight.w700,
              color: AppColors.textNavyBlue,
              letterSpacing: 0.2,
              height: 1.2,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        if (trailingIcon != null)
          IconButton(
            icon: trailingIcon!,
            onPressed: onTrailingPressed ?? () {},
            color: AppColors.textNavyBlue,
          ),
      ],
      backgroundColor: AppColors.appBarBackground,
      elevation: 0,
      centerTitle: true,
    );
  }
}


