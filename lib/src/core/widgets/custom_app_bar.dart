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
    final homePressed =
        onHomePressed ??
        () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (route) => false);

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
        if (!hideHomeButton)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _HomeButton(onPressed: homePressed),
          ),
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

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.homePillBackground,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home, size: 16, color: AppColors.homePillForeground),
              SizedBox(width: 6),
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.homePillForeground,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
