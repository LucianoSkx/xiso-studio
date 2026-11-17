import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'args.dart';
import 'l10n_ext.dart';
import 'state.dart';
import 'widgets.dart';
import 'xiso.dart';

const _isoGroup = XTypeGroup(
  label: 'Xbox image (XISO/ISO)',
  extensions: ['iso', 'xiso'],
);

const _isoOutGroup = XTypeGroup(
  label: 'XISO image',
  extensions: ['iso'],
);

Future<String?> pickIsoFile() async {
  final f = await openFile(acceptedTypeGroups: const [_isoGroup]);
  return f?.path;
}

Future<List<String>> pickIsoFiles() async {
  final files = await openFiles(acceptedTypeGroups: const [_isoGroup]);
  return files.map((f) => f.path).toList();
}

Future<String?> pickDirectory() => getDirectoryPath();

Future<String?> pickSaveIso(String suggested) async {
  final loc = await getSaveLocation(
    suggestedName: suggested,
    acceptedTypeGroups: const [_isoOutGroup],
  );
  return loc?.path;
}

String baseName(String path) {
  final name = path.split('/').last;
  final dot = name.lastIndexOf('.');
  return dot > 0 ? name.substring(0, dot) : name;
}

/// Botão principal de ação + botão de cancelar enquanto roda.
class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.state,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final AppState state;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        SizedBox(
          height: 46,
          child: FilledButton.icon(
            onPressed: state.canRun ? onPressed : null,
            icon: Icon(icon, size: 20),
            label: Text(label),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22),
            ),
          ),
        ),
        if (state.busy) ...[
          const SizedBox(width: 12),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: state.cancel,
              icon: const Icon(Icons.stop_circle_outlined, size: 18),
              label: Text(l.actionCancel),
            ),
          ),
          const SizedBox(width: 16),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          for (final f in fields) ...[f, const SizedBox(height: 16)],
          actions,
        ],
      ),
    );
  }
}

class ExtractPage extends StatefulWidget {
  const ExtractPage({super.key, required this.state});
  final AppState state;

  @override
  State<ExtractPage> createState() => _ExtractPageState();
}

class _ExtractPageState extends State<ExtractPage> {
  final List<String> _files = [];
  String? _outDir;
  bool _skipSystemUpdate = true;
  bool _perIsoFolder = true;

  void _setFiles(List<String> files) {
    setState(() {
      _files
        ..clear()
        ..addAll(files);
    });
  }

  Future<void> _start() async {
    final state = widget.state;
    final l = context.l10n;
    var ok = true;
    for (var i = 0; i < _files.length; i++) {
      final iso = _files[i];
      final target = _outDir == null
          ? null
          : extractTargetFor(
              outDir: _outDir!,
              isoBaseName: baseName(iso),
              totalFiles: _files.length,
              perIsoFolder: _perIsoFolder,
            );
      final args = buildExtractArgs(
        iso: iso,
        outDir: target,
        skipSystemUpdate: _skipSystemUpdate,
      );
      final total = state.exe == null
          ? null
          : await countXisoEntries(state.exe!, iso);
      final label = _files.length > 1
          ? l.extractMulti(i + 1, _files.length, baseName(iso))
          : l.extractSingle(baseName(iso));
      await state.run(
        args,
        label: label,
        totalFiles: total,
        clearLog: i == 0,
      );
      state.lastOutputDir = target ?? Directory.current.path;
      if (state.outcome != RunOutcome.ok) {
        ok = false;
        break;
      }
    }
    if (ok && _files.length > 1) {
      state.setOutcome(RunOutcome.ok);
      state.taskLabel = l.doneAllExtract(_files.length);
      state.lastOutputDir = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l = context.l10n;
    final multiple = _files.length > 1;
    return SingleChildScrollView(
      child: PageFrame(
        title: l.extractTitle,
        subtitle: l.extractSubtitle,
        fields: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.labelSourceImages, hint: l.labelSourceImagesHint),
              PathPicker(
                value: _files.isEmpty
                    ? null
                    : multiple
                        ? l.imagesSelected(_files.length)
                        : _files.first,
                placeholder: l.placeholderNoImage,
                icon: Icons.album_outlined,
                pickLabel: l.actionChoose,
                onChanged: (v) => _setFiles(v.trim().isEmpty ? [] : [v.trim()]),
                onPick: () async {
                  final files = await pickIsoFiles();
                  if (files.isNotEmpty) _setFiles(files);
                },
                onClear: _files.isEmpty ? null : () => _setFiles([]),
              ),
              if (multiple) ...[
                const SizedBox(height: 8),
                for (final f in _files)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      '• ${f.split('/').last}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.labelDestFolder, hint: l.labelDestHint),
              PathPicker(
                value: _outDir,
                placeholder: l.placeholderSameAsImage,
                icon: Icons.drive_folder_upload_outlined,
                pickLabel: l.actionChoose,
                onChanged: (v) =>
                    setState(() => _outDir = v.trim().isEmpty ? null : v.trim()),
                onPick: () async {
                  final d = await pickDirectory();
                  if (d != null) setState(() => _outDir = d);
                },
                onClear: () => setState(() => _outDir = null),
              ),
            ],
          ),
          OptionTile(
            title: l.optSkipSystemUpdate,
            subtitle: l.optSkipSystemUpdateHint,
            value: _skipSystemUpdate,
            onChanged: (v) => setState(() => _skipSystemUpdate = v),
          ),
          OptionTile(
            title: l.optPerIsoFolder,
            subtitle: l.optPerIsoFolderHint,
            value: _perIsoFolder,
            onChanged: (v) => setState(() => _perIsoFolder = v),
          ),
        ],
        actions: ActionBar(
          state: state,
          label: l.actionExtract,
          icon: Icons.unarchive_outlined,
          onPressed: _files.isEmpty ? null : _start,
        ),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.state});
  final AppState state;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String? _iso;
  int? _entries;

  Future<void> _start() async {
    final state = widget.state;
    setState(() => _entries = null);
    await state.run(buildListArgs(_iso!),
        label: context.l10n.listLabel(baseName(_iso!)));
    final count = parseEntryCount(state.log.join('\n'));
    if (mounted) setState(() => _entries = count ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l = context.l10n;
    final t = Theme.of(context);
    return SingleChildScrollView(
      child: PageFrame(
        title: l.listTitle,
        subtitle: l.listSubtitle,
        fields: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.labelImage),
              PathPicker(
                value: _iso,
                placeholder: l.placeholderNoImageSelected,
                icon: Icons.album_outlined,
                pickLabel: l.actionChoose,
                onChanged: (v) =>
                    setState(() => _iso = v.trim().isEmpty ? null : v.trim()),
                onPick: () async {
                  final f = await pickIsoFile();
                  if (f != null) setState(() => _iso = f);
                },
                onClear: () => setState(() => _iso = null),
              ),
            ],
          ),
          if (_entries != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: t.colorScheme.secondaryContainer.withValues(alpha: .35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.format_list_bulleted,
                      size: 18, color: t.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Text(l.entriesFound(_entries!), style: t.textTheme.bodyMedium),
                ],
              ),
            ),
        ],
        actions: ActionBar(
          state: state,
          label: l.actionList,
          icon: Icons.format_list_bulleted,
          onPressed: _iso == null ? null : _start,
        ),
      ),
    );
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key, required this.state});
  final AppState state;

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String? _source;
  String? _out;
  bool _skipSystemUpdate = true;
  bool _noPatch = false;

  Future<void> _start() async {
    final state = widget.state;
    final total = countFilesInDir(_source!, skipSystemUpdate: _skipSystemUpdate);
    final args = buildCreateArgs(
      sourceDir: _source!,
      outIso: _out!,
      skipSystemUpdate: _skipSystemUpdate,
      noPatch: _noPatch,
    );
    await state.run(
      args,
      label: context.l10n.createLabel(baseName(_out!)),
      totalFiles: total,
    );
    state.lastOutputDir = File(_out!).parent.path;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l = context.l10n;
    return SingleChildScrollView(
      child: PageFrame(
        title: l.createTitle,
        subtitle: l.createSubtitle,
        fields: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.labelSourceFolder),
              PathPicker(
                value: _source,
                placeholder: l.placeholderSourceFolder,
                icon: Icons.folder_open,
                pickLabel: l.actionChoose,
                onChanged: (v) =>
                    setState(() => _source = v.trim().isEmpty ? null : v.trim()),
                onPick: () async {
                  final d = await pickDirectory();
                  if (d != null) {
                    setState(() {
                      _source = d;
                      _out ??= '${Directory.current.path}/${baseName(d)}.iso';
                    });
                  }
                },
                onClear: () => setState(() => _source = null),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.labelOutputFile, hint: l.labelOutputHint),
              PathPicker(
                value: _out,
                placeholder: l.placeholderChooseOutput,
                icon: Icons.save_outlined,
                pickLabel: l.actionSaveAs,
                onChanged: (v) =>
                    setState(() => _out = v.trim().isEmpty ? null : v.trim()),
                onPick: () async {
                  final suggested =
                      _source == null ? 'game.iso' : '${baseName(_source!)}.iso';
                  final p = await pickSaveIso(suggested);
                  if (p != null) setState(() => _out = p);
                },
                onClear: () => setState(() => _out = null),
              ),
            ],
          ),
          OptionTile(
            title: l.optSkipSystemUpdate,
            subtitle: l.optSkipSystemUpdateHint,
            value: _skipSystemUpdate,
            onChanged: (v) => setState(() => _skipSystemUpdate = v),
          ),
          OptionTile(
            title: l.optNoPatch,
            subtitle: l.optNoPatchHint,
            value: _noPatch,
            onChanged: (v) => setState(() => _noPatch = v),
          ),
        ],
        actions: ActionBar(
          state: state,
          label: l.actionCreate,
          icon: Icons.add_to_photos_outlined,
          onPressed: _source == null || _out == null ? null : _start,
        ),
      ),
    );
  }
}

class RewritePage extends StatefulWidget {
  const RewritePage({super.key, required this.state});
  final AppState state;

  @override
  State<RewritePage> createState() => _RewritePageState();
}

class _RewritePageState extends State<RewritePage> {
  final List<String> _files = [];
  String? _outDir;
  bool _deleteOld = false;

  Future<void> _start() async {
    final state = widget.state;
    final l = context.l10n;
    for (var i = 0; i < _files.length; i++) {
      final args = buildRewriteArgs(
        iso: _files[i],
        outDir: _outDir,
        deleteOld: _deleteOld,
      );
      final total = state.exe == null
          ? null
          : await countXisoEntries(state.exe!, _files[i]);
      final label = _files.length > 1
          ? l.optimizeMulti(i + 1, _files.length, baseName(_files[i]))
          : l.optimizeSingle(baseName(_files[i]));
      await state.run(
        args,
        label: label,
        totalFiles: total,
        clearLog: i == 0,
      );
      if (state.outcome != RunOutcome.ok) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l = context.l10n;
    return SingleChildScrollView(
      child: PageFrame(
        title: l.optimizeTitle,
        subtitle: l.optimizeSubtitle,
        fields: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.labelSourceImages),
              PathPicker(
                value: _files.isEmpty
                    ? null
                    : _files.length == 1
                        ? _files.first
                        : l.imagesSelected(_files.length),
                placeholder: l.placeholderNoImageSelected,
                icon: Icons.album_outlined,
                pickLabel: l.actionChoose,
                onChanged: (v) => setState(() {
                  _files.clear();
                  if (v.trim().isNotEmpty) _files.add(v.trim());
                }),
                onPick: () async {
                  final files = await pickIsoFiles();
                  if (files.isNotEmpty) {
                    setState(() {
                      _files
                        ..clear()
                        ..addAll(files);
                    });
                  }
                },
                onClear: _files.isEmpty
                    ? null
                    : () => setState(() => _files.clear()),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.labelDestFolder, hint: l.labelDestHint),
              PathPicker(
                value: _outDir,
                placeholder: l.placeholderSameAsImage,
                icon: Icons.drive_folder_upload_outlined,
                pickLabel: l.actionChoose,
                onChanged: (v) =>
                    setState(() => _outDir = v.trim().isEmpty ? null : v.trim()),
                onPick: () async {
                  final d = await pickDirectory();
                  if (d != null) setState(() => _outDir = d);
                },
                onClear: () => setState(() => _outDir = null),
              ),
            ],
          ),
          OptionTile(
            title: l.optDeleteOld,
            subtitle: l.optDeleteOldHint,
            value: _deleteOld,
            onChanged: (v) => setState(() => _deleteOld = v),
          ),
        ],
        actions: ActionBar(
          state: state,
          label: l.actionOptimize,
          icon: Icons.compress_outlined,
          onPressed: _files.isEmpty ? null : _start,
        ),
      ),
    );
  }
}
