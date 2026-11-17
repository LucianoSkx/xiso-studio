import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n_ext.dart';
import 'state.dart';
import 'version.dart';

/// Endereço público do projeto.
const repoSite = 'https://github.com/LucianoSkx/xiso-studio';

/// Abre um endereço no navegador padrão; sem navegador, fica em silêncio.
Future<void> abrirUrl(String url) async {
  try {
    await Process.start('xdg-open', [url]);
  } catch (_) {
    // ambiente sem xdg-open: nada a fazer
  }
}

/// Linhas de informação exibidas no Sobre e copiadas para a área de transferência.
String aboutInfoText(AppState state) {
  final linhas = [
    'XISO Studio $appVersion',
    'extract-xiso ${state.version.isEmpty ? '—' : state.version} (embedded)',
    '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'.trim(),
    'repo: $repoSite',
  ];
  return linhas.join('\n');
}

/// Ex.: `linux_x64`, lido do mesmo texto que o Dart usa para se identificar.
String _plataforma() {
  final m = RegExp(r'on "([^"]+)"').firstMatch(Platform.version);
  return m?.group(1) ?? Platform.operatingSystem;
}

/// Versão do Dart VM que vem no bundle (o Flutter não expõe a dele aqui).
String _runtime() {
  final m = RegExp(r'^(\S+)').firstMatch(Platform.version);
  return 'Dart ${m?.group(1) ?? '?'}';
}

Future<void> showXisoAbout(BuildContext context, AppState state) {
  return showDialog<void>(
    context: context,
    builder: (_) => _AboutBox(state: state),
  );
}

class _AboutBox extends StatelessWidget {
  const _AboutBox({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    final discreto = t.textTheme.labelSmall?.copyWith(
      letterSpacing: 1.0,
      fontWeight: FontWeight.w700,
      color: t.colorScheme.onSurfaceVariant,
    );

    Widget linha(String rotulo, String valor) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(rotulo, style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            )),
          ),
          Expanded(
            child: SelectableText(
              valor,
              style: t.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'packaging/icons/xiso-studio-128.png',
                    width: 48,
                    height: 48,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 48),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.appName,
                          style: t.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l.aboutTagline,
                          style: t.textTheme.bodySmall?.copyWith(
                            color: t.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: t.colorScheme.primary.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'v$appVersion',
                      style: t.textTheme.labelSmall?.copyWith(
                        color: t.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(l.aboutBuildTitle, style: discreto),
              const SizedBox(height: 6),
              linha(l.aboutApp, appVersion),
              linha(
                l.aboutTool,
                state.version.isEmpty ? '—' : state.version,
              ),
              linha(l.aboutSystem, _plataforma()),
              linha(l.aboutRuntime, _runtime()),
              linha(l.aboutLicense, 'MIT · extract-xiso (own license)'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.aboutMadeBy,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l.aboutCopy,
                    icon: const Icon(Icons.copy_all_outlined, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: aboutInfoText(state)),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.aboutCopied)),
                      );
                    },
                  ),
                ],
              ),
              const Divider(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => abrirUrl(repoSite),
                    icon: const Icon(Icons.code, size: 16),
                    label: Text(l.aboutOpenRepo),
                  ),
                  Builder(
                    builder: (inner) => TextButton(
                      onPressed: () => showAboutDialog(
                        context: inner,
                        applicationName: l.appName,
                        applicationVersion: appVersion,
                        applicationLegalese: l.aboutLegal,
                      ),
                      child: Text(l.aboutLicenses),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l.actionClose),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
