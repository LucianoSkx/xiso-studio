import 'dart:io';

import 'package:flutter/material.dart';

/// Rótulo pequeno em caixa alta usado acima de campos.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.hint});
  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: t.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint!,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.labelSmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant.withValues(alpha: .7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Caixa de texto editável com caminho + botão de escolher.
class PathPicker extends StatefulWidget {
  const PathPicker({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onPick,
    this.placeholder = 'Nenhum selecionado',
    this.icon = Icons.folder_open,
    this.onClear,
    this.pickLabel = 'Escolher',
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onPick;
  final VoidCallback? onClear;
  final String placeholder;
  final IconData icon;
  final String pickLabel;

  @override
  State<PathPicker> createState() => _PathPickerState();
}

class _PathPickerState extends State<PathPicker> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.value ?? '');
  final FocusNode _focus = FocusNode();

  @override
  void didUpdateWidget(covariant PathPicker old) {
    super.didUpdateWidget(old);
    final v = widget.value ?? '';
    if (!_focus.hasFocus && v != _ctrl.text) _ctrl.text = v;
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              onChanged: widget.onChanged,
              style: t.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                prefixIcon: Icon(
                  widget.icon,
                  size: 18,
                  color: t.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _ctrl.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar',
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _ctrl.clear();
                          widget.onChanged('');
                          widget.onClear?.call();
                        },
                      ),
                filled: true,
                fillColor: t.colorScheme.surfaceContainerHighest.withValues(alpha: .45),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: t.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: t.colorScheme.outlineVariant),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.tonalIcon(
          onPressed: widget.onPick,
          icon: const Icon(Icons.search, size: 18),
          label: Text(widget.pickLabel),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 46),
          ),
        ),
      ],
    );
  }
}

/// Linha de opções (checkboxes) com descrição.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.textTheme.bodyMedium),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painel de log com rolagem automática.
class LogPanel extends StatefulWidget {
  const LogPanel({
    super.key,
    required this.lines,
    required this.busy,
    this.emptyText = '',
  });
  final List<String> lines;
  final bool busy;
  final String emptyText;

  @override
  State<LogPanel> createState() => _LogPanelState();
}

class _LogPanelState extends State<LogPanel> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(covariant LogPanel old) {
    super.didUpdateWidget(old);
    if (widget.lines.length != old.lines.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10131A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: widget.lines.isEmpty
          ? Center(
              child: Text(
                widget.emptyText,
                style: t.textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            )
          : Scrollbar(
              controller: _scroll,
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: widget.lines.length,
                itemBuilder: (_, i) => Text(
                  widget.lines[i],
                  style: const TextStyle(
                    color: Color(0xFFC9D1D9),
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ),
    );
  }
}

/// Abre o gerenciador de arquivos em [dir].
Future<void> openInFileManager(String dir) async {
  try {
    await Process.start('xdg-open', [dir]);
  } catch (_) {
    // sem gerenciador de arquivos: ignora silenciosamente
  }
}

/// Barra de progresso da execução atual.
///
/// Com total conhecido mostra a fração concluída e "12 / 48 arquivos";
/// sem total, mostra uma barra indeterminada.
class ProgressStrip extends StatelessWidget {
  const ProgressStrip({
    super.key,
    required this.value,
    required this.done,
    required this.total,
    required this.label,
    required this.fileLabel,
  });

  final double? value;
  final int done;
  final int? total;
  final String? label;
  final String fileLabel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final determinate = value != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (determinate)
                Text(
                  fileLabel,
                  style: t.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: t.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
