import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/features/profile/application/profile_provider.dart';

class TermsConditionScreen extends ConsumerWidget {
  const TermsConditionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(termsConditionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: termsAsync.when(
          data: (policyResponse) {
            if (policyResponse.policy?.description == null) {
              return const Center(
                child: Text('No terms and conditions available.'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policyResponse.policy!.description!,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stackTrace) => Center(
                child: Text(
                  'Error loading terms and conditions: ${error.toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
        ),
      ),
    );
  }
}
