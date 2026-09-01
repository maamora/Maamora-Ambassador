import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _primary = Color(0xFFFB7701);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);


class EditMessageBottomSheet extends StatefulWidget {
  final String currentMessage;
  final String defaultMessage;
  final String referralLink;
  final String city;
  final ValueChanged<String> onSaved;

  const EditMessageBottomSheet({
    super.key,
    required this.currentMessage,
    required this.defaultMessage,
    required this.referralLink,
    required this.city,
    required this.onSaved,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentMessage,
    required String defaultMessage,
    required String referralLink,
    required String city,
    required ValueChanged<String> onSaved,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditMessageBottomSheet(
        currentMessage: currentMessage,
        defaultMessage: defaultMessage,
        referralLink: referralLink,
        city: city,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<EditMessageBottomSheet> createState() => _EditMessageBottomSheetState();
}

class _EditMessageBottomSheetState extends State<EditMessageBottomSheet> {
  late final TextEditingController _controller;
  int _selectedTemplateIndex = -1;

  List<Map<String, String>> get _templates => [
        {
          'title': '🌟 Standard',
          'text':
              'Assalamu alaikum neighbors! 👋\n\nJoin my Maamora group for the best deals on bulk groceries in ${widget.city}. We buy together, we save together! 🛒✨\n\nClick here to join my group:\n${widget.referralLink}',
        },
        {
          'title': '🇲🇦 Darija',
          'text':
              'Salam les voisins ! 👋\n\nRejoignez mon groupe Maamora pour profiter des meilleurs prix de gros à ${widget.city}. Chriw majmou3in w rbe7 m3ana ! 🛒✨\n\nLien pour rejoindre :\n${widget.referralLink}',
        },
        {
          'title': '🇫🇷 Français',
          'text':
              'Bonjour à tous ! 👋\n\nRejoignez mon groupe d\'achats groupés Maamora à ${widget.city} pour économiser ensemble sur vos courses. 🛒✨\n\nCliquez sur ce lien pour rejoindre :\n${widget.referralLink}',
        },
        {
          'title': '⚡ Express',
          'text':
              'Super promos d\'achats groupés à ${widget.city} sur Maamora ! 🛒 Rejoignez le groupe ici :\n${widget.referralLink}',
        },
      ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentMessage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyTemplate(int index) {
    setState(() {
      _selectedTemplateIndex = index;
      _controller.text = _templates[index]['text']!;
    });
  }

  void _resetToDefault() {
    setState(() {
      _selectedTemplateIndex = 0;
      _controller.text = widget.defaultMessage;
    });
  }

  void _insertLink() {
    final text = _controller.text;
    if (!text.contains(widget.referralLink)) {
      final newText = text.isEmpty
          ? widget.referralLink
          : '$text\n\n${widget.referralLink}';
      setState(() {
        _controller.text = newText;
      });
    }
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le message ne peut pas être vide.')),
      );
      return;
    }
    widget.onSaved(text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final containsLink = _controller.text.contains(widget.referralLink);

    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _cardBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customize Message',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _onBackground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Personalize your WhatsApp invitation',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: _onSurfaceVariant),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Templates label
            Text(
              'QUICK TEMPLATES',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),

            // Template horizontal scroll chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_templates.length, (index) {
                  final t = _templates[index];
                  final isSelected = _selectedTemplateIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        t['title']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : _onBackground,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _primary,
                      backgroundColor: const Color(0xFFFFF0E6),
                      side: BorderSide(
                        color: isSelected ? _primary : _cardBorder,
                      ),
                      onSelected: (_) => _applyTemplate(index),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Message Editor Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MESSAGE CONTENT',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                TextButton.icon(
                  onPressed: _resetToDefault,
                  icon: const Icon(Icons.restart_alt_rounded, size: 14, color: _primary),
                  label: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Text Input Box
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 7,
                    minLines: 4,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _onBackground,
                      height: 1.45,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write your custom WhatsApp invitation message...',
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) {
                      if (_selectedTemplateIndex != -1) {
                        setState(() => _selectedTemplateIndex = -1);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  if (!containsLink)
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 14, color: Color(0xFFE65100)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Referral link is missing.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFFE65100),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _insertLink,
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              '+ Add link',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _onSurfaceVariant,
                      side: const BorderSide(color: _cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
