import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/features/profile/application/profile_provider.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policyAsync = ref.watch(privacyPolicyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: policyAsync.when(
        data: (policyResponse) {
          if (policyResponse.policy?.description == null) {
            return const Center(child: Text('No privacy policy available.'));
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
                'Error loading privacy policy: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
      ),
    );
  }
}
