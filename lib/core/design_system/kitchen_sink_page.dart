import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/ripple_button.dart';
import '../widgets/ripple_card.dart';
import '../widgets/ripple_input.dart';
import '../widgets/ripple_page_header.dart';

class KitchenSinkPage extends StatelessWidget {
  const KitchenSinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RipplePageHeader(
                title: 'Design System',
                subtitle: 'Kitchen Sink - "Cozy Productivity"',
                action: CircleAvatar(
                  backgroundColor: AppColors.rippleBlue,
                  child: Icon(Icons.palette, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Typography'),
                    Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
                    Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
                    Text('Body Large - Comfortable reading size.', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Body Medium - Slightly smaller for density. '
                      'The quick brown fox jumps over the lazy dog.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),
                    _sectionHeader('Buttons'),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        RippleButton(
                          text: 'Primary Action',
                          onPressed: () {},
                          icon: PhosphorIcons.plus(),
                        ),
                        RippleButton(
                          text: 'Secondary',
                          type: RippleButtonType.secondary,
                          onPressed: () {},
                        ),
                        RippleButton(
                          text: 'Ghost Button',
                          type: RippleButtonType.ghost,
                          onPressed: () {},
                        ),
                        RippleButton(
                          text: 'Loading',
                          isLoading: true,
                          onPressed: () {},
                        ),
                        RippleButton(
                          text: 'Delete',
                          type: RippleButtonType.danger,
                          icon: PhosphorIcons.trash(),
                          onPressed: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _sectionHeader('Inputs'),
                    const RippleInput(
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    const RippleInput(
                      hintText: 'Password',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                    ),

                    const SizedBox(height: 32),
                    _sectionHeader('Cards'),
                    RippleCard(
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.softGray,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(PhosphorIcons.checkCircle(), color: AppColors.rippleBlue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Task Card', style: Theme.of(context).textTheme.labelLarge),
                                Text('Tap to see hover effect', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const RippleCard(
                      backgroundColor: AppColors.rippleBlue,
                      child: Center(
                        child: Text(
                          'Colored Card',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
