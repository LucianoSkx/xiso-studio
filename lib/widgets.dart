import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

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
    this.recents = const [],
    this.recentLabel = 'Recentes',
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onPick;
  final VoidCallback? onClear;
  final String placeholder;
  final IconData icon;
  final String pickLabel;

  /// Imagens usadas recentemente; quando há alguma, aparece o botão de histórico.
  final List<String> recents;
  final String recentLabel;

  @override
  State<PathPicker> createState() => _PathPickerState();
}

String _nomeArquivo(String caminho) => caminho.split('/').last;

String _pastaDe(String caminho) {
  final i = caminho.lastIndexOf('/');
  return i <= 0 ? caminho : caminho.substring(0, i);
}

class _PathPickerState extends State<PathPicker> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.value ?? '',
  );
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
                fillColor: t.colorScheme.surfaceContainerHighest.withValues(
                  alpha: .45,
                ),
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
        if (widget.recents.isNotEmpty) ...[
          const SizedBox(width: 8),
          SizedBox(
            height: 46,
            child: PopupMenuButton<String>(
              tooltip: widget.recentLabel,
              onSelected: (p) {
                _ctrl.text = p;
                widget.onChanged(p);
              },
              icon: const Icon(Icons.history, size: 18),
              itemBuilder: (_) => [
                for (final p in widget.recents)
                  PopupMenuItem<String>(
                    value: p,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_nomeArquivo(p), style: t.textTheme.bodySmall),
                        Text(
                          _pastaDe(p),
                          style: t.textTheme.labelSmall?.copyWith(
                            color: t.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
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
    required this.cutLabel,
  });
  final List<String> lines;
  final bool busy;
  final String emptyText;

  /// Texto da linha que avisa quantas linhas antigas não estão sendo exibidas.
  final String Function(int count) cutLabel;

  @override
  State<LogPanel> createState() => _LogPanelState();
}

class _LogPanelState extends State<LogPanel> {
  final _scroll = ScrollController();

  /// Enquanto verdadeiro a vista acompanha o fim da saída. Vira falso quando
  /// o usuário rola para cima, e volta ao chegar perto do fim.
  bool _seguir = true;

  static const _margemFim = 24.0;

  /// Só a rolagem feita pelo usuário desliga o acompanhamento. Escutar o
  /// `ScrollController` não serve: quando a saída cresce a extensão muda e o
  /// ajuste automático era lido como rolagem do usuário, desligando o modo.
  bool _aoUsuarioRolar(ScrollNotification n) {
    if (n is UserScrollNotification) {
      _seguir = n.direction == ScrollDirection.idle
          ? n.metrics.extentAfter <= _margemFim
          : false;
    }
    return false;
  }

  @override
  void didUpdateWidget(covariant LogPanel old) {
    super.didUpdateWidget(old);
    final terminou = old.busy && !widget.busy;
    if (widget.lines.length != old.lines.length || terminou) {
      // saída nova (ou execução concluída): volta a acompanhar o fim
      _seguir = true;
      _colarNoFim();
    }
  }

  /// Cola a vista na última linha. `maxScrollExtent` é apenas estimado
  /// enquanto os itens de altura variável (com quebra de linha) não foram
  /// posicionados, então repetimos por alguns frames até a extensão parar de
  /// crescer — um único salto para o fim para antes da última linha.
  void _colarNoFim([int tentativa = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients || !_seguir) return;
      final antes = _scroll.position.pixels;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
      final andou = _scroll.position.pixels - antes;
      if (andou > 1 && tentativa < 4) _colarNoFim(tentativa + 1);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Só o fim da saída é renderizado: uma lista com milhares de itens deixa o
  /// painel pesado a ponto de a interface parar de acompanhar o processo. O log
  /// completo continua em memória (com limite em `AppState`).
  static const _maxRenderizar = 1000;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final total = widget.lines.length;
    final corte = total > _maxRenderizar ? total - _maxRenderizar : 0;
    final linhas = corte == 0 ? widget.lines : widget.lines.sublist(corte);
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
          : NotificationListener<ScrollNotification>(
              onNotification: _aoUsuarioRolar,
              child: Scrollbar(
                controller: _scroll,
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: linhas.length + (corte > 0 ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (corte > 0 && i == 0) {
                      return Text(
                        widget.cutLabel(corte),
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    return Text(
                      linhas[i - (corte > 0 ? 1 : 0)],
                      style: const TextStyle(
                        color: Color(0xFFC9D1D9),
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.45,
                      ),
                    );
                  },
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
