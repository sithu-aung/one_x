import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/profile/application/profile_provider.dart';
import 'package:one_x/features/profile/domain/models/contact_response.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final bool _isLoading = true;
  String? _errorMessage;
  ContactResponse? _contactResponse;

  @override
  void initState() {
    super.initState();
    // Data will be loaded through provider
  }

  // Launch phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        _showSnackBar('Could not make a call to $phoneNumber');
      }
    } catch (e) {
      _showSnackBar('Error making call: $e');
    }
  }

  // Launch Viber
  Future<void> _openViber(String viberNumber) async {
    try {
      // For Viber, we try both the viber:// and the market:// schemes
      final Uri viberUri = Uri.parse("viber://chat?number=$viberNumber");
      if (await canLaunchUrl(viberUri)) {
        await launchUrl(viberUri);
      } else {
        // Try opening the link in browser as a fallback
        final Uri browserUri = Uri.parse("https://viber.com/");
        if (await canLaunchUrl(browserUri)) {
          await launchUrl(browserUri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar('Could not open Viber');
        }
      }
    } catch (e) {
      _showSnackBar('Error opening Viber: $e');
    }
  }

  // Launch Facebook
  Future<void> _openFacebook(String fbId) async {
    try {
      // Try fb:// scheme first (for app)
      final Uri fbAppUri = Uri.parse("fb://profile/$fbId");
      if (await canLaunchUrl(fbAppUri)) {
        await launchUrl(fbAppUri);
      } else {
        // Fall back to https link for browser
        final Uri browserUri = Uri.parse("https://www.facebook.com/$fbId");
        if (await canLaunchUrl(browserUri)) {
          await launchUrl(browserUri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar('Could not open Facebook');
        }
      }
    } catch (e) {
      _showSnackBar('Error opening Facebook: $e');
    }
  }

  // Launch WhatsApp
  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Format the phone number (remove any non-numeric characters)
      final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // WhatsApp deep link
      final Uri whatsappUri = Uri.parse(
        "whatsapp://send?phone=$formattedNumber",
      );
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        // Fall back to web link
        final Uri browserUri = Uri.parse("https://wa.me/$formattedNumber");
        if (await canLaunchUrl(browserUri)) {
          await launchUrl(browserUri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar('Could not open WhatsApp');
        }
      }
    } catch (e) {
      _showSnackBar('Error opening WhatsApp: $e');
    }
  }

  // Copy to clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard: $text');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Contact Us'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: contactsAsync.when(
        data: (contactResponse) {
          if (contactResponse.contacts == null) {
            return const Center(
              child: Text('No contact information available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phone section
                if (contactResponse.contacts?.phone != null &&
                    contactResponse.contacts!.phone!.isNotEmpty)
                  _buildContactSection(
                    title: 'Phone',
                    icon: Icons.phone,
                    iconColor: Colors.green,
                    contacts: contactResponse.contacts!.phone!,
                    onTap: (contact) => _makePhoneCall(contact.contact ?? ''),
                    onLongPress:
                        (contact) => _copyToClipboard(contact.contact ?? ''),
                  ),

                // Viber section
                if (contactResponse.contacts?.viber != null &&
                    contactResponse.contacts!.viber!.isNotEmpty)
                  _buildContactSection(
                    title: 'Viber',
                    icon: Icons.message,
                    iconColor: Colors.purple,
                    contacts: contactResponse.contacts!.viber!,
                    onTap: (contact) => _openViber(contact.contact ?? ''),
                    onLongPress:
                        (contact) => _copyToClipboard(contact.contact ?? ''),
                  ),

                // Facebook section
                if (contactResponse.contacts?.facebook != null &&
                    contactResponse.contacts!.facebook!.isNotEmpty)
                  _buildContactSection(
                    title: 'Facebook',
                    icon: Icons.facebook,
                    iconColor: Colors.blue,
                    contacts: contactResponse.contacts!.facebook!,
                    onTap: (contact) => _openFacebook(contact.contact ?? ''),
                    onLongPress:
                        (contact) => _copyToClipboard(contact.contact ?? ''),
                  ),

                // WhatsApp section
                if (contactResponse.contacts?.whatsApp != null &&
                    contactResponse.contacts!.whatsApp!.isNotEmpty)
                  _buildContactSection(
                    title: 'WhatsApp',
                    icon: Icons.message,
                    iconColor: const Color(0xFF25D366), // WhatsApp green color
                    contacts: contactResponse.contacts!.whatsApp!,
                    onTap: (contact) => _openWhatsApp(contact.contact ?? ''),
                    onLongPress:
                        (contact) => _copyToClipboard(contact.contact ?? ''),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(contactsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildContactSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<ContactData> contacts,
    required Function(ContactData) onTap,
    required Function(ContactData) onLongPress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
        ),
        ...contacts.map(
          (contact) => Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onTap(contact),
              onLongPress: () => onLongPress(contact),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.contact ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.color,
                            ),
                          ),
                          if (contact.category?.name != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                contact.category!.name!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.1),
                      child: Icon(
                        title == 'Phone'
                            ? Icons.call
                            : title == 'Viber'
                            ? Icons.chat
                            : title == 'WhatsApp'
                            ? Icons.chat_bubble
                            : Icons.facebook,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
