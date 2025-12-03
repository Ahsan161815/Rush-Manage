import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:myapp/app/app_theme.dart';

typedef EmojiReactionSelected = void Function(String emoji);

class _EmojiEntry {
  const _EmojiEntry(this.emoji, this.keywords);

  final String emoji;
  final List<String> keywords;

  bool matches(String needle) {
    final query = needle.toLowerCase();
    if (emoji.contains(query)) {
      return true;
    }
    return keywords.any((keyword) => keyword.contains(query));
  }
}

class _EmojiCategory {
  const _EmojiCategory({
    required this.label,
    required this.icon,
    required this.emojis,
  });

  final String label;
  final IconData icon;
  final List<String> emojis;
}

const List<_EmojiEntry> _emojiCatalog = [
  _EmojiEntry('👍', ['thumbs up', 'like', 'approve', 'yes']),
  _EmojiEntry('👎', ['thumbs down', 'dislike', 'no']),
  _EmojiEntry('👌', ['perfect', 'ok', 'nice']),
  _EmojiEntry('✌️', ['peace', 'victory']),
  _EmojiEntry('🤞', ['fingers crossed', 'hope']),
  _EmojiEntry('🫰', ['money gesture', 'snap']),
  _EmojiEntry('🤟', ['i love you', 'sign']),
  _EmojiEntry('🤘', ['rock on', 'party']),
  _EmojiEntry('🤙', ['call me', 'hang loose']),
  _EmojiEntry('👋', ['wave', 'hello', 'hi']),
  _EmojiEntry('🤚', ['raised hand', 'stop']),
  _EmojiEntry('🖐️', ['raised hand', 'high five']),
  _EmojiEntry('✋', ['stop', 'high five']),
  _EmojiEntry('🖖', ['vulcan salute', 'live long']),
  _EmojiEntry('👊', ['fist', 'respect']),
  _EmojiEntry('✊', ['fist', 'power']),
  _EmojiEntry('🤛', ['fist bump', 'support']),
  _EmojiEntry('🤜', ['fist bump', 'support']),
  _EmojiEntry('👏', ['clap', 'applause']),
  _EmojiEntry('🙌', ['hooray', 'raise hands']),
  _EmojiEntry('👐', ['open hands', 'hug']),
  _EmojiEntry('🤲', ['offer', 'support']),
  _EmojiEntry('🙏', ['thanks', 'appreciate', 'pray']),
  _EmojiEntry('🤝', ['deal', 'handshake', 'agreement']),
  _EmojiEntry('🫶', ['heart hands', 'support']),
  _EmojiEntry('❤️', ['heart', 'love', 'favorite']),
  _EmojiEntry('💙', ['blue heart', 'trust', 'calm']),
  _EmojiEntry('💚', ['green heart', 'growth', 'win']),
  _EmojiEntry('💜', ['purple heart', 'gratitude']),
  _EmojiEntry('🧡', ['orange heart', 'care']),
  _EmojiEntry('🤍', ['white heart', 'pure']),
  _EmojiEntry('🖤', ['black heart', 'bold']),
  _EmojiEntry('🤎', ['brown heart', 'warm']),
  _EmojiEntry('✨', ['sparkle', 'magic', 'wow']),
  _EmojiEntry('⭐', ['star', 'favorite']),
  _EmojiEntry('🌟', ['glow', 'shine']),
  _EmojiEntry('🎉', ['celebrate', 'party', 'congrats']),
  _EmojiEntry('🥳', ['party face', 'celebrate']),
  _EmojiEntry('🎯', ['goal', 'target']),
  _EmojiEntry('🏆', ['trophy', 'win', 'award']),
  _EmojiEntry('🔥', ['fire', 'lit', 'great']),
  _EmojiEntry('⚡', ['spark', 'fast', 'energy']),
  _EmojiEntry('⚙️', ['settings', 'gear']),
  _EmojiEntry('🚀', ['launch', 'growth']),
  _EmojiEntry('✅', ['done', 'complete', 'checkmark']),
  _EmojiEntry('☑️', ['checkbox', 'complete']),
  _EmojiEntry('📌', ['pin', 'important']),
  _EmojiEntry('📎', ['attachment', 'file', 'link']),
  _EmojiEntry('📷', ['camera', 'photo']),
  _EmojiEntry('🎥', ['video', 'record']),
  _EmojiEntry('🎧', ['listen', 'audio']),
  _EmojiEntry('📝', ['note', 'document', 'edit']),
  _EmojiEntry('🖊️', ['pen', 'edit']),
  _EmojiEntry('📊', ['stats', 'chart', 'data']),
  _EmojiEntry('📈', ['chart up', 'growth']),
  _EmojiEntry('📉', ['chart down', 'loss']),
  _EmojiEntry('🧠', ['think', 'strategy']),
  _EmojiEntry('🪄', ['magic', 'improve']),
  _EmojiEntry('🧩', ['puzzle', 'fit']),
  _EmojiEntry('📚', ['learning', 'research']),
  _EmojiEntry('🧑‍💻', ['developer', 'tech']),
  _EmojiEntry('🧑‍🤝‍🧑', ['team', 'collaboration']),
  _EmojiEntry('🧭', ['direction', 'guide']),
  _EmojiEntry('🛠️', ['fix', 'tools']),
  _EmojiEntry('🧰', ['toolbox', 'support']),
  _EmojiEntry('📦', ['package', 'deliverable']),
  _EmojiEntry('🗂️', ['files', 'archive']),
  _EmojiEntry('🧾', ['invoice', 'bill']),
  _EmojiEntry('🪙', ['coin', 'finance']),
  _EmojiEntry('💰', ['budget', 'money']),
  _EmojiEntry('📅', ['calendar', 'schedule']),
  _EmojiEntry('⏱️', ['timer', 'deadline']),
  _EmojiEntry('⏳', ['waiting', 'hourglass']),
  _EmojiEntry('💬', ['chat', 'talk', 'message']),
  _EmojiEntry('🔁', ['repeat', 'refresh']),
  _EmojiEntry('ℹ️', ['info', 'details']),
  _EmojiEntry('❗', ['important', 'alert']),
  _EmojiEntry('❓', ['question', 'help']),
  _EmojiEntry('💡', ['idea', 'insight']),
  _EmojiEntry('📣', ['announce', 'share']),
  _EmojiEntry('🗣️', ['speak', 'voice']),
  _EmojiEntry('🤨', ['skeptical', 'huh', 'question']),
  _EmojiEntry('😅', ['relief', 'awkward']),
  _EmojiEntry('😂', ['lol', 'haha']),
  _EmojiEntry('🤣', ['rolling', 'laughing']),
  _EmojiEntry('😎', ['cool', 'sunglasses']),
  _EmojiEntry('🤩', ['wow', 'star eyes']),
  _EmojiEntry('😀', ['grinning', 'smile', 'happy']),
  _EmojiEntry('😁', ['beaming', 'big smile']),
  _EmojiEntry('😆', ['laugh', 'joy']),
  _EmojiEntry('😄', ['grin', 'joy']),
  _EmojiEntry('😊', ['smile', 'happy']),
  _EmojiEntry('😇', ['angel', 'wholesome']),
  _EmojiEntry('🙂', ['simple smile', 'content']),
  _EmojiEntry('🙃', ['upside-down', 'playful']),
  _EmojiEntry('😉', ['wink', 'playful']),
  _EmojiEntry('😍', ['love', 'heart eyes']),
  _EmojiEntry('🥰', ['in love', 'hearts']),
  _EmojiEntry('😘', ['kiss', 'thanks']),
  _EmojiEntry('😗', ['kiss', 'whistle']),
  _EmojiEntry('😙', ['kiss', 'smile']),
  _EmojiEntry('😚', ['kiss', 'closed eyes']),
  _EmojiEntry('😋', ['tasty', 'yum']),
  _EmojiEntry('😜', ['playful', 'cheeky']),
  _EmojiEntry('🤪', ['silly', 'crazy']),
  _EmojiEntry('😝', ['tongue out', 'playful']),
  _EmojiEntry('🤑', ['money mouth', 'rich']),
  _EmojiEntry('🤗', ['hug', 'support']),
  _EmojiEntry('🤭', ['oops', 'hand over mouth']),
  _EmojiEntry('🤫', ['quiet', 'shh']),
  _EmojiEntry('🤥', ['lying', 'pinocchio']),
  _EmojiEntry('🤯', ['mind blown', 'wow']),
  _EmojiEntry('😶', ['speechless', 'blank']),
  _EmojiEntry('🙄', ['eyeroll', 'annoyed']),
  _EmojiEntry('😏', ['smirk', 'confident']),
  _EmojiEntry('😐', ['neutral', 'meh']),
  _EmojiEntry('😑', ['expressionless', 'blank']),
  _EmojiEntry('🤔', ['thinking', 'hmm', 'consider']),
  _EmojiEntry('😣', ['ugh', 'tired']),
  _EmojiEntry('😖', ['confounded', 'upset']),
  _EmojiEntry('😫', ['exhausted', 'tired']),
  _EmojiEntry('😩', ['weary', 'overwhelmed']),
  _EmojiEntry('🥺', ['plead', 'puppy eyes']),
  _EmojiEntry('😢', ['cry', 'sad']),
  _EmojiEntry('😭', ['sob', 'cry']),
  _EmojiEntry('😤', ['determined', 'phew']),
  _EmojiEntry('😠', ['angry', 'annoyed']),
  _EmojiEntry('😡', ['mad', 'angry']),
  _EmojiEntry('🤬', ['angry', 'frustrated']),
  _EmojiEntry('😳', ['flushed', 'surprised']),
  _EmojiEntry('🥵', ['hot', 'overheated']),
  _EmojiEntry('🥶', ['cold', 'freezing']),
  _EmojiEntry('😱', ['shock', 'scared']),
  _EmojiEntry('😨', ['scared', 'worried']),
  _EmojiEntry('😰', ['nervous', 'sweat']),
  _EmojiEntry('😥', ['relieved', 'sad']),
  _EmojiEntry('😓', ['tired', 'sweat']),
  _EmojiEntry('😴', ['sleep', 'offline']),
  _EmojiEntry('😪', ['sleepy', 'drowsy']),
  _EmojiEntry('😵', ['dizzy', 'wow']),
  _EmojiEntry('🤐', ['zipper mouth', 'secret']),
  _EmojiEntry('🥴', ['woozy', 'tipsy']),
  _EmojiEntry('🤢', ['nauseous', 'sick']),
  _EmojiEntry('🤧', ['sneeze', 'ill']),
  _EmojiEntry('😷', ['mask', 'sick']),
  _EmojiEntry('😶‍🌫️', ['foggy', 'hazy', 'confused']),
  _EmojiEntry('🤦', ['facepalm', 'oops']),
  _EmojiEntry('🤷', ['shrug', 'unsure']),
  _EmojiEntry('👀', ['eyes', 'look', 'watching']),
];

final Map<String, _EmojiEntry> _emojiLookup = {
  for (final entry in _emojiCatalog) entry.emoji: entry,
};

const List<_EmojiCategory> _emojiCategories = [
  _EmojiCategory(
    label: 'Recent',
    icon: Icons.watch_later_outlined,
    emojis: [
      '👍',
      '❤️',
      '🎉',
      '👏',
      '🔥',
      '✅',
      '🚀',
      '😊',
      '💡',
      '🤝',
      '🙌',
      '😂',
    ],
  ),
  _EmojiCategory(
    label: 'Smileys',
    icon: Icons.emoji_emotions_outlined,
    emojis: [
      '😀',
      '😄',
      '😁',
      '😆',
      '😊',
      '😇',
      '🙂',
      '🙃',
      '😉',
      '🥰',
      '😍',
      '🤩',
      '😘',
      '😗',
      '😙',
      '😚',
      '😋',
      '😜',
      '🤪',
      '😝',
      '🤑',
      '🤗',
      '🤔',
      '🤨',
      '😐',
      '😑',
      '😶',
      '🙄',
      '😏',
      '😣',
      '😖',
      '😫',
      '😩',
      '🥺',
      '😢',
      '😭',
      '😤',
      '😠',
      '😡',
      '🤬',
      '🤯',
      '😳',
      '🥵',
      '🥶',
      '😱',
      '😨',
      '😰',
      '😥',
      '😓',
      '🤗',
      '🤭',
      '🤫',
      '🤥',
      '😶‍🌫️',
      '😴',
      '😪',
      '😵',
      '🤐',
      '🥴',
      '🤢',
      '🤧',
      '😷',
    ],
  ),
  _EmojiCategory(
    label: 'Gestures',
    icon: Icons.back_hand_outlined,
    emojis: [
      '👍',
      '👎',
      '👌',
      '✌️',
      '🤞',
      '🫰',
      '🤟',
      '🤘',
      '🤙',
      '👋',
      '🤚',
      '🖐️',
      '✋',
      '🖖',
      '👊',
      '✊',
      '🤛',
      '🤜',
      '👏',
      '🙌',
      '👐',
      '🤲',
      '🙏',
      '🫶',
      '🤝',
      '🤗',
    ],
  ),
  _EmojiCategory(
    label: 'Work',
    icon: Icons.work_outline,
    emojis: [
      '💡',
      '🏆',
      '📣',
      '🎯',
      '📌',
      '📎',
      '📷',
      '📝',
      '📊',
      '📈',
      '📉',
      '🗂️',
      '📦',
      '🧾',
      '🧰',
      '🛠️',
      '🧠',
      '🧩',
      '🧭',
      '🪄',
      '🧑‍💻',
      '🧑‍🤝‍🧑',
      '🪙',
      '💰',
    ],
  ),
  _EmojiCategory(
    label: 'Symbols',
    icon: Icons.emoji_symbols_outlined,
    emojis: [
      '❤️',
      '💙',
      '💚',
      '💜',
      '🧡',
      '🤍',
      '🖤',
      '🤎',
      '✨',
      '⭐',
      '🌟',
      '⚡',
      '🔥',
      '💬',
      '🔁',
      'ℹ️',
      '❗',
      '❓',
      '✅',
      '☑️',
      '🚀',
      '⚙️',
      '⏱️',
      '⏳',
    ],
  ),
];

Future<void> showEmojiReactionPicker({
  required BuildContext context,
  required EmojiReactionSelected onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _EmojiBottomSheet(onSelected: onSelected),
  );
}

class _EmojiBottomSheet extends StatefulWidget {
  const _EmojiBottomSheet({required this.onSelected});

  final EmojiReactionSelected onSelected;

  @override
  State<_EmojiBottomSheet> createState() => _EmojiBottomSheetState();
}

class _EmojiBottomSheetState extends State<_EmojiBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  int _selectedCategory = 0;
  String _query = '';

  List<_EmojiEntry> get _activeEmojis {
    if (_query.isNotEmpty) {
      final matches = _emojiCatalog
          .where((entry) => entry.matches(_query))
          .map((entry) => entry.emoji)
          .toSet()
          .map((emoji) => _emojiLookup[emoji])
          .whereType<_EmojiEntry>()
          .toList(growable: false);
      return matches;
    }

    final category = _emojiCategories[_selectedCategory];
    return category.emojis
        .map((emoji) => _emojiLookup[emoji])
        .whereType<_EmojiEntry>()
        .toList(growable: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = math.min(mediaQuery.size.height * 0.62, 440.0);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            12 + mediaQuery.viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textfieldBorder.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'React with emoji',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _EmojiSearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              const SizedBox(height: 16),
              _EmojiCategoryBar(
                selectedIndex: _selectedCategory,
                onCategorySelected: (index) {
                  setState(() {
                    _selectedCategory = index;
                    _query = '';
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: availableHeight,
                child: _EmojiGrid(
                  entries: _activeEmojis,
                  onSelected: (emoji) {
                    Navigator.of(context).pop();
                    widget.onSelected(emoji);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiSearchField extends StatelessWidget {
  const _EmojiSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search emoji or keyword',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.hintTextfiled,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.hintTextfiled,
        ),
        filled: true,
        fillColor: AppColors.textfieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.textfieldBorder.withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.textfieldBorder.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class _EmojiCategoryBar extends StatelessWidget {
  const _EmojiCategoryBar({
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _emojiCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _emojiCategories[index];
          final isSelected = index == selectedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.16)
                  : AppColors.textfieldBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.textfieldBorder.withValues(alpha: 0.5),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onCategorySelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 18,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.hintTextfiled,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({required this.entries, required this.onSelected});

  final List<_EmojiEntry> entries;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No emoji match your search yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: entries.length,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _EmojiTile(emoji: entry.emoji, onSelected: onSelected);
      },
    );
  }
}

class _EmojiTile extends StatelessWidget {
  const _EmojiTile({required this.emoji, required this.onSelected});

  final String emoji;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(emoji),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.textfieldBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textfieldBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
    );
  }
}
