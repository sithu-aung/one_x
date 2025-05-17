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

  // Launch Telegram
  Future<void> _openTelegram(String telegramNumber) async {
    try {
      // Remove leading + or other non-numeric characters
      final formattedNumber = telegramNumber.replaceAll(RegExp(r'[^\d]'), '');

      // Try app scheme first
      final Uri telegramUri = Uri.parse("tg://resolve?phone=$formattedNumber");
      if (await canLaunchUrl(telegramUri)) {
        await launchUrl(telegramUri);
      } else {
        // Fall back to web link
        final Uri browserUri = Uri.parse("https://t.me/$formattedNumber");
        if (await canLaunchUrl(browserUri)) {
          await launchUrl(browserUri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar('Could not open Telegram');
        }
      }
    } catch (e) {
      _showSnackBar('Error opening Telegram: $e');
    }
  }

  // Launch Facebook
  Future<void> _openFacebook(String fbUrl) async {
    try {
      final Uri uri = Uri.parse(fbUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open Facebook');
      }
    } catch (e) {
      _showSnackBar('Error opening Facebook: $e');
    }
  }

  // Launch TikTok
  Future<void> _openTikTok(String tiktokUrl) async {
    try {
      final Uri uri = Uri.parse(tiktokUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open TikTok');
      }
    } catch (e) {
      _showSnackBar('Error opening TikTok: $e');
    }
  }

  // Copy to clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('ဆက်သွယ်ရန်'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: contactsAsync.when(
          data: (contactResponse) {
            if (contactResponse.contacts == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.contact_support_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No contact information available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'ကျွန်ုပ်တို့နှင့် ဆက်သွယ်ပါ',
                  //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //     color: Theme.of(context).colorScheme.onSurface,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  // Text(
                  //   'သင့်အတွက် အဆင်ပြေသည့် နည်းလမ်းဖြင့် ဆက်သွယ်ပါ',
                  //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  //     color: Theme.of(
                  //       context,
                  //     ).colorScheme.onSurface.withOpacity(0.7),
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // Contact cards grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth > 600;
                      final crossAxisCount = isTablet ? 2 : 1;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          // Phone
                          if (contactResponse.contacts?.phone != null &&
                              contactResponse.contacts!.phone!.data != null &&
                              contactResponse.contacts!.phone!.data!.isNotEmpty)
                            SizedBox(
                              width:
                                  isTablet
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth,
                              child: _buildContactCard(
                                title: 'Phone',
                                icon: contactResponse.contacts!.phone!.icon,
                                fallbackIcon: Icons.phone_rounded,
                                color: Colors.green,
                                contacts:
                                    contactResponse.contacts!.phone!.data!,
                                onTap:
                                    (contact) =>
                                        _makePhoneCall(contact.contact ?? ''),
                                onLongPress:
                                    (contact) =>
                                        _copyToClipboard(contact.contact ?? ''),
                                isDarkMode: isDarkMode,
                              ),
                            ),

                          // Viber
                          if (contactResponse.contacts?.viber != null &&
                              contactResponse.contacts!.viber!.data != null &&
                              contactResponse.contacts!.viber!.data!.isNotEmpty)
                            SizedBox(
                              width:
                                  isTablet
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth,
                              child: _buildContactCard(
                                title: 'Viber',
                                icon: contactResponse.contacts!.viber!.icon,
                                fallbackIcon: Icons.message_rounded,
                                color: const Color(0xFF7360F2),
                                contacts:
                                    contactResponse.contacts!.viber!.data!,
                                onTap:
                                    (contact) =>
                                        _openViber(contact.contact ?? ''),
                                onLongPress:
                                    (contact) =>
                                        _copyToClipboard(contact.contact ?? ''),
                                isDarkMode: isDarkMode,
                              ),
                            ),

                          // Telegram
                          if (contactResponse.contacts?.telegram != null &&
                              contactResponse.contacts!.telegram!.data !=
                                  null &&
                              contactResponse
                                  .contacts!
                                  .telegram!
                                  .data!
                                  .isNotEmpty)
                            SizedBox(
                              width:
                                  isTablet
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth,
                              child: _buildContactCard(
                                title: 'Telegram',
                                icon: contactResponse.contacts!.telegram!.icon,
                                fallbackIcon: Icons.telegram_rounded,
                                color: const Color(0xFF0088CC),
                                contacts:
                                    contactResponse.contacts!.telegram!.data!,
                                onTap:
                                    (contact) =>
                                        _openTelegram(contact.contact ?? ''),
                                onLongPress:
                                    (contact) =>
                                        _copyToClipboard(contact.contact ?? ''),
                                isDarkMode: isDarkMode,
                              ),
                            ),

                          // Facebook
                          if (contactResponse.contacts?.facebook != null &&
                              contactResponse.contacts!.facebook!.data !=
                                  null &&
                              contactResponse
                                  .contacts!
                                  .facebook!
                                  .data!
                                  .isNotEmpty)
                            SizedBox(
                              width:
                                  isTablet
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth,
                              child: _buildContactCard(
                                title: 'Facebook',
                                icon: contactResponse.contacts!.facebook!.icon,
                                fallbackIcon: Icons.facebook_rounded,
                                color: const Color(0xFF1877F2),
                                contacts:
                                    contactResponse.contacts!.facebook!.data!,
                                onTap:
                                    (contact) =>
                                        _openFacebook(contact.contact ?? ''),
                                onLongPress:
                                    (contact) =>
                                        _copyToClipboard(contact.contact ?? ''),
                                isDarkMode: isDarkMode,
                              ),
                            ),

                          // TikTok
                          if (contactResponse.contacts?.tiktok != null &&
                              contactResponse.contacts!.tiktok!.isNotEmpty)
                            SizedBox(
                              width:
                                  isTablet
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth,
                              child: _buildContactCard(
                                title: 'TikTok',
                                icon: null,
                                fallbackIcon: Icons.music_note_rounded,
                                color: Colors.black,
                                contacts: contactResponse.contacts!.tiktok!,
                                onTap:
                                    (contact) =>
                                        _openTikTok(contact.contact ?? ''),
                                onLongPress:
                                    (contact) =>
                                        _copyToClipboard(contact.contact ?? ''),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
          loading:
              () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading contacts...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
          error:
              (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(contactsProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    String? icon,
    required IconData fallbackIcon,
    required Color color,
    required List<ContactData> contacts,
    required Function(ContactData) onTap,
    required Function(ContactData) onLongPress,
    required bool isDarkMode,
  }) {
    final contact = contacts.first; // Using first contact for cleaner UI
    final isPhoneOrViber = title == 'Phone' || title == 'Viber';
    final displayText =
        isPhoneOrViber && contact.contact != null
            ? '+95 ${contact.contact!.substring(2)}'
            : contact.contact ?? '';

    return Card(
      elevation: isDarkMode ? 2 : 0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isDarkMode
                  ? Colors.transparent
                  : Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(contact),
        onLongPress: () => onLongPress(contact),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child:
                          icon != null && icon.isNotEmpty
                              ? Image.network(
                                icon,
                                width: 28,
                                height: 28,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    fallbackIcon,
                                    color: color,
                                    size: 28,
                                  );
                                },
                              )
                              : Icon(fallbackIcon, color: color, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayText,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Action icon
                  Icon(
                    title == 'Phone'
                        ? Icons.call_rounded
                        : Icons.arrow_forward_ios_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
                ],
              ),
              if (contacts.length > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${contacts.length - 1} more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
