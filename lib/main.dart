import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'about_dialog.dart';
import 'l10n_ext.dart';
import 'log_export.dart';
import 'notify.dart';
import 'pages.dart';
import 'state.dart';
import 'version.dart';
import 'widgets.dart';

void main() {
  runApp(const XisoStudioApp());
}

class XisoStudioApp extends StatefulWidget {
  const XisoStudioApp({super.key, this.state});

  /// Estado injetável (usado pelos testes); por padrão o app cria o seu.
  final AppState? state;

  @override
  State<XisoStudioApp> createState() => _XisoStudioAppState();
}

class _XisoStudioAppState extends State<XisoStudioApp> {
  late final AppState _state = widget.state ?? AppState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_rebuild);
    _state.init();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_rebuild);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF52B043),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      onGenerateTitle: (ctx) => ctx.l10n.appName,
      debugShowCheckedModeBanner: false,
      locale: _state.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF14161C),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        visualDensity: VisualDensity.comfortable,
      ),
      home: Shell(state: _state),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.state});
  final AppState state;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  AppState get _state => widget.state;
  int _mode = 0;
  bool _estavaOcupado = false;
  String? _iconeEmCache;

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final terminou = _estavaOcupado && !_state.busy;
    _estavaOcupado = _state.busy;
    if (terminou && _state.outcome != RunOutcome.none) {
      _avisarConclusao();
    }
    if (mounted) setState(() {});
  }

  /// Avisa no desktop que a execução terminou (detalhe pedido pelo usuário).
  /// Fica muda se não houver `notify-send`; o rodapé sempre mostra o resultado.
  void _avisarConclusao() {
    if (!mounted) return;
    final l = context.l10n;
    // só falha merece urgência crítica; cancelar é escolha do usuário
    final erro = _state.outcome == RunOutcome.failed ||
        _state.outcome == RunOutcome.error;
    const notifier = DesktopNotifier();
    _caminhoIcone().then((icone) {
      notifier.enviar(
        titulo: 'XISO Studio',
        corpo: statusMessage(l, _state),
        icone: icone,
        critica: erro,
      );
    });
  }

  Future<String?> _caminhoIcone() async {
    if (_iconeEmCache != null) return _iconeEmCache;
    try {
      final dados = await rootBundle.load('packaging/icons/xiso-studio-128.png');
      final casa = Platform.environment['HOME'] ?? '.';
      final dir = Directory('$casa/.cache/xiso-studio');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final f = File('${dir.path}/icon.png');
      f.writeAsBytesSync(dados.buffer.asUint8List());
      return _iconeEmCache = f.path;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final wide = MediaQuery.of(context).size.width >= 980;

    final modes = <({String label, IconData icon})>[
      (label: l.navExtract, icon: Icons.unarchive_outlined),
      (label: l.navList, icon: Icons.format_list_bulleted),
      (label: l.navCreate, icon: Icons.add_to_photos_outlined),
      (label: l.navOptimize, icon: Icons.compress_outlined),
    ];

    final pages = <Widget>[
      ExtractPage(state: _state),
      ListPage(state: _state),
      CreatePage(state: _state),
      RewritePage(state: _state),
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Sidebar(
              modes: modes,
              selected: _mode,
              onSelect: (i) {
                if (i == _mode) return;
                setState(() => _mode = i);
                // console limpo ao entrar em outro modo (preservado se houver
                // execução em andamento)
                _state.resetConsole();
              },
              state: _state,
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: IndexedStack(index: _mode, children: pages),
                        ),
                        if (wide)
                          Expanded(
                            flex: 2,
                            child: LogColumn(state: _state),
                          ),
                      ],
                    ),
                  ),
                  StatusBar(state: _state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.modes,
    required this.selected,
    required this.onSelect,
    required this.state,
  });

  final List<({String label, IconData icon})> modes;
  final int selected;
  final ValueChanged<int> onSelect;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    return Container(
      width: 236,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF101218),
        border: Border(right: BorderSide(color: t.colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'packaging/icons/xiso-studio-128.png',
                  width: 36,
                  height: 36,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.album,
                    size: 21,
                    color: Color(0xFF52B043),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            l.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: t.colorScheme.primary.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            appVersion,
                            style: t.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: t.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      state.ready
                          ? l.toolVersion(state.version)
                          : l.statusInitializing,
                      style: t.textTheme.labelSmall?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          for (var i = 0; i < modes.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: NavItem(
                icon: modes[i].icon,
                label: modes[i].label,
                active: i == selected,
                onTap: () => onSelect(i),
              ),
            ),
          const Spacer(),
          if (state.fatalError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.fatalError!,
                style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.error),
              ),
            ),
          Row(
            children: [
              LanguageButton(state: state),
              const Spacer(),
              IconButton(
                tooltip: l.menuClearLog,
                onPressed: state.log.isEmpty ? null : state.clearLog,
                icon: const Icon(Icons.cleaning_services_outlined, size: 18),
              ),
              IconButton(
                tooltip: l.menuOpenOutput,
                onPressed: state.lastOutputDir == null
                    ? null
                    : () => openInFileManager(state.lastOutputDir!),
                icon: const Icon(Icons.folder_outlined, size: 18),
              ),
              IconButton(
                tooltip: l.menuAbout,
                onPressed: () => showXisoAbout(context, state),
                icon: const Icon(Icons.info_outline, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Seletor de idioma (sistema, português, inglês, espanhol).
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = state.locale?.languageCode;
    return PopupMenuButton<Locale?>(
      tooltip: l.menuLanguage,
      icon: const Icon(Icons.translate, size: 18),
      position: PopupMenuPosition.over,
      onSelected: state.setLocale,
      itemBuilder: (_) => [
        _item(null, l.languageSystem, current == null),
        _item(const Locale('pt'), l.languagePortuguese, current == 'pt'),
        _item(const Locale('en'), l.languageEnglish, current == 'en'),
        _item(const Locale('es'), l.languageSpanish, current == 'es'),
      ],
    );
  }

  PopupMenuItem<Locale?> _item(Locale? value, String label, bool selected) {
    return PopupMenuItem<Locale?>(
      value: value,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check : Icons.circle_outlined,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Material(
      color: active ? t.colorScheme.primary.withValues(alpha: .16) : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? t.colorScheme.primary : t.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? t.colorScheme.primary : t.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogColumn extends StatelessWidget {
  const LogColumn({super.key, required this.state});
  final AppState state;

  /// Exporta o console inteiro (não só o trecho exibido) para um arquivo.
  Future<void> _salvarLog(BuildContext context, AppState state) async {
    final l = context.l10n;
    final mensageiro = ScaffoldMessenger.of(context);
    // Sem diretório inicial o diálogo abre na pasta de montagem do AppImage.
    final casa = Platform.environment['HOME'];
    final documentos = casa == null ? null : '$casa/Documents';
    final inicial = documentos != null && Directory(documentos).existsSync()
        ? documentos
        : casa;
    final destino = await getSaveLocation(
      suggestedName: logFileName(),
      initialDirectory: inicial,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Text', extensions: ['txt']),
      ],
    );
    if (destino == null) return;
    try {
      await File(destino.path).writeAsString(buildLogExport(state.log));
      mensageiro.showSnackBar(
        SnackBar(content: Text(l.logSaved(destino.path))),
      );
    } catch (e) {
      mensageiro.showSnackBar(
        SnackBar(content: Text(l.logSaveFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l.logHeader,
                style: t.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (state.taskLabel != null)
                Flexible(
                  child: Text(
                    state.taskLabel!,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.labelSmall?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: state.log.isEmpty
                    ? null
                    : () => _salvarLog(context, state),
                tooltip: l.logSave,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                icon: const Icon(Icons.save_alt),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.busy) ...[
            ProgressStrip(
              value: state.progress,
              done: state.progressDone,
              total: state.progressTotal,
              label: state.taskLabel,
              fileLabel: state.progressTotal == null
                  ? ''
                  : l.progressFiles(state.progressDone, state.progressTotal!),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: LogPanel(
              lines: state.log,
              busy: state.busy,
              emptyText: l.logEmpty,
              cutLabel: l.logHidden,
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto do rodapé para o estado atual; também usado na notificação.
String statusMessage(AppLocalizations l, AppState state) {
  return switch (state.outcome) {
    RunOutcome.none => state.ready
        ? l.statusReady(state.version)
        : (state.fatalError == null ? l.statusInitializing : l.statusToolFailed),
    RunOutcome.ok => state.taskLabel == null
        ? (state.ready ? l.statusReady(state.version) : '')
        : l.statusDone(state.taskLabel!),
    RunOutcome.failed => l.statusFailed(state.exitCode ?? -1, state.taskLabel ?? ''),
    RunOutcome.cancelled => l.statusCancelled,
    RunOutcome.error => l.statusError(state.errorMessage ?? ''),
  };
}

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    final (icon, color) = switch (state.outcome) {
      RunOutcome.none => (Icons.circle_outlined, t.colorScheme.onSurfaceVariant),
      RunOutcome.ok => (Icons.check_circle_outline, t.colorScheme.onSurfaceVariant),
      RunOutcome.failed => (Icons.error_outline, t.colorScheme.error),
      RunOutcome.cancelled => (Icons.cancel_outlined, t.colorScheme.tertiary),
      RunOutcome.error => (Icons.error_outline, t.colorScheme.error),
    };
    final text = statusMessage(l, state);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF101218),
        border: Border(top: BorderSide(color: t.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          if (state.busy)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
          if (state.lastOutputDir != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => openInFileManager(state.lastOutputDir!),
                icon: const Icon(Icons.folder_open_outlined, size: 15),
                label: Text(l.openOutputFolder),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: t.textTheme.labelSmall,
                ),
              ),
            ),
          Text(
            'v$appVersion',
            style: t.textTheme.labelSmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
