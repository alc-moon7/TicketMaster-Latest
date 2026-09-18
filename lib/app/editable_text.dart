part of 'package:ticketmaster/main.dart';

class _EditableTextStore {
  static final Map<String, String> _editedValues = <String, String>{};
  static bool _isDialogOpen = false;

  static bool get isDialogOpen => _isDialogOpen;

  static String valueFor(String key, String original) {
    final resolvedKey = _resolvedStoreKey(key, original);
    final legacyKey = _legacyStoreKey(key, original);
    return _editedValues[resolvedKey] ?? _editedValues[legacyKey] ?? original;
  }

  static void hydrate(Map<String, String> values) {
    _editedValues
      ..clear()
      ..addAll(values);
  }

  static Future<void> save(String key, String original, String edited) async {
    final resolvedKey = _resolvedStoreKey(key, original);
    final legacyKey = _legacyStoreKey(key, original);
    if (edited == original) {
      _editedValues.remove(resolvedKey);
      _editedValues.remove(legacyKey);
    } else {
      _editedValues[resolvedKey] = edited;
      if (legacyKey != resolvedKey) {
        _editedValues.remove(legacyKey);
      }
    }
    await _TicketmasterCloudStore.instance.saveEditedTexts(_editedValues);
  }

  static void setDialogOpen(bool value) {
    _isDialogOpen = value;
  }

  static String _resolvedStoreKey(String key, String original) {
    if (key.isNotEmpty) {
      return key;
    }
    return _legacyStoreKey(key, original);
  }

  static String _legacyStoreKey(String key, String original) {
    return '$key::$original';
  }
}

class Text extends StatefulWidget {
  const Text(
    String this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const Text.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  State<Text> createState() => _TextState();
}

class _TextState extends State<Text> {
  String _cachedOriginal = '';
  String _cachedStoreKey = '';

  @override
  void initState() {
    super.initState();
    _syncDerivedValues();
  }

  @override
  void didUpdateWidget(covariant Text oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.textSpan != widget.textSpan ||
        oldWidget.key != widget.key) {
      _syncDerivedValues();
    }
  }

  String _originalText() {
    if (widget.data != null) {
      return widget.data!;
    }
    return widget.textSpan?.toPlainText(includeSemanticsLabels: true) ?? '';
  }

  String _storeKey(String original) {
    final keyPart = widget.key?.toString() ?? '';
    if (keyPart.isNotEmpty) {
      return keyPart;
    }
    return '::$original';
  }

  void _syncDerivedValues() {
    _cachedOriginal = _originalText();
    _cachedStoreKey = _storeKey(_cachedOriginal);
  }

  Widget _buildMaterialText(String value, String original) {
    if (widget.textSpan != null && value == original) {
      return material.Text.rich(
        widget.textSpan!,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        locale: widget.locale,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        textScaler: widget.textScaler,
        maxLines: widget.maxLines,
        semanticsLabel: widget.semanticsLabel,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
        selectionColor: widget.selectionColor,
      );
    }

    final spanStyle = widget.textSpan is TextSpan
        ? (widget.textSpan as TextSpan).style
        : null;
    return material.Text(
      value,
      style: widget.style ?? spanStyle,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaler: widget.textScaler,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    String storeKey,
    String original,
  ) async {
    if (!context.mounted || _EditableTextStore.isDialogOpen) {
      return;
    }

    _EditableTextStore.setDialogOpen(true);

    try {
      await Future<void>.delayed(Duration.zero);
      if (!context.mounted) {
        return;
      }
      final editedText = await showDialog<String>(
        context: context,
        useRootNavigator: false,
        builder: (dialogContext) {
          return _EditableTextDialog(
            initialValue: _EditableTextStore.valueFor(storeKey, original),
          );
        },
      );

      if (editedText == null) {
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
      await _EditableTextStore.save(storeKey, original, editedText);
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // Swallow dialog/context race errors so a failed edit attempt
      // doesn't terminate the whole app.
    } finally {
      _EditableTextStore.setDialogOpen(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final original = _cachedOriginal;
    if (original.trim().isEmpty) {
      return _buildMaterialText(original, original);
    }

    final storeKey = _cachedStoreKey;
    final effectiveValue = _EditableTextStore.valueFor(storeKey, original);
    final editableChild = _buildMaterialText(effectiveValue, original);
    return _HoldToEditText(
      onTriggered: () {
        if (!context.mounted) {
          return;
        }
        _showEditDialog(context, storeKey, original);
      },
      child: editableChild,
    );
  }
}

class _EditableTextDialog extends StatefulWidget {
  const _EditableTextDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_EditableTextDialog> createState() => _EditableTextDialogState();
}

class _EditableTextDialogState extends State<_EditableTextDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close([String? value]) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const material.Text('Edit text'),
      content: TextField(
        controller: _controller,
        autofocus: false,
        autocorrect: false,
        enableSuggestions: false,
        maxLines: 4,
        minLines: 1,
        decoration: const InputDecoration(
          hintText: 'Enter updated text',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: _close, child: const material.Text('Cancel')),
        ElevatedButton(
          onPressed: () => _close(_controller.text),
          child: const material.Text('Save'),
        ),
      ],
    );
  }
}

class _HoldToEditText extends StatefulWidget {
  const _HoldToEditText({required this.onTriggered, required this.child});

  final VoidCallback onTriggered;
  final Widget child;

  @override
  State<_HoldToEditText> createState() => _HoldToEditTextState();
}

class _HoldToEditTextState extends State<_HoldToEditText> {
  void _handleLongPress() {
    if (!mounted || _EditableTextStore.isDialogOpen) {
      return;
    }
    widget.onTriggered();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      onLongPress: _handleLongPress,
      child: widget.child,
    );
  }
}
