// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'XISO Studio';

  @override
  String get navExtract => 'Extract';

  @override
  String get navList => 'List';

  @override
  String get navCreate => 'Create';

  @override
  String get navOptimize => 'Optimize';

  @override
  String get extractTitle => 'Extract';

  @override
  String get extractSubtitle =>
      'Expands the contents of one or more XISO images into folders.';

  @override
  String get listTitle => 'List';

  @override
  String get listSubtitle =>
      'Shows the file tree inside an XISO image, without extracting.';

  @override
  String get createTitle => 'Create';

  @override
  String get createSubtitle =>
      'Builds a new XISO image from a folder containing the game files.';

  @override
  String get optimizeTitle => 'Optimize (rewrite)';

  @override
  String get optimizeSubtitle =>
      'Rewrites the filesystem structure, shrinking the final image size.';

  @override
  String get labelSourceImages => 'Source images';

  @override
  String get labelSourceImagesHint => 'use the button or paste a path';

  @override
  String get labelDestFolder => 'Destination folder';

  @override
  String get labelDestHint => 'empty = current folder';

  @override
  String get placeholderNoImage => 'No XISO image selected';

  @override
  String get placeholderSameAsImage => 'Same folder as the image';

  @override
  String get labelImage => 'XISO image';

  @override
  String get placeholderNoImageSelected => 'No image selected';

  @override
  String get labelSourceFolder => 'Source folder';

  @override
  String get placeholderSourceFolder => 'Folder with the game contents';

  @override
  String get labelOutputFile => 'Output file';

  @override
  String get labelOutputHint => 'where the .iso will be written';

  @override
  String get placeholderChooseOutput => 'Choose where to save the image';

  @override
  String get actionChoose => 'Choose';

  @override
  String get actionSaveAs => 'Save as';

  @override
  String get actionExtract => 'Extract';

  @override
  String get actionList => 'List contents';

  @override
  String get actionCreate => 'Create image';

  @override
  String get actionOptimize => 'Optimize';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get optSkipSystemUpdate => 'Skip the \$SystemUpdate folder';

  @override
  String get optSkipSystemUpdateHint =>
      'Same as -s: skips the embedded dashboard updates.';

  @override
  String get optPerIsoFolder => 'One subfolder per image';

  @override
  String get optPerIsoFolderHint => 'Keeps files from different images apart.';

  @override
  String get optNoPatch => 'Do not patch media flags on .xbe files';

  @override
  String get optNoPatchHint =>
      'Same as -m. Not recommended: the game may not be recognized.';

  @override
  String get optDeleteOld => 'Delete the original image after optimizing';

  @override
  String get optDeleteOldHint => 'Same as -D. Irreversible.';

  @override
  String get logHeader => 'OUTPUT';

  @override
  String get logEmpty => 'Command output appears here.';

  @override
  String get statusInitializing => 'initializing…';

  @override
  String statusReady(Object version) {
    return 'extract-xiso v$version embedded and ready';
  }

  @override
  String statusDone(Object label) {
    return 'Done: $label';
  }

  @override
  String statusFailed(Object code, Object label) {
    return 'Failed (exit $code): $label';
  }

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String statusError(Object message) {
    return 'Error while running: $message';
  }

  @override
  String get statusToolFailed => 'Failed to prepare the embedded tool';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuClearLog => 'Clear log';

  @override
  String get menuOpenOutput => 'Open output folder';

  @override
  String get menuAbout => 'About';

  @override
  String get tooltipClearPath => 'Clear';

  @override
  String get languageSystem => 'System';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get aboutTitle => 'About XISO Studio';

  @override
  String aboutBody(Object version) {
    return 'A graphical front-end for extract-xiso (v$version).\nThe extract-xiso binary is embedded in this executable.\nBuilt by LucianoSkx.';
  }

  @override
  String entriesFound(Object count) {
    return '$count entries found';
  }

  @override
  String progressFiles(Object done, Object total) {
    return '$done / $total files';
  }

  @override
  String imagesSelected(Object count) {
    return '$count images selected';
  }

  @override
  String extractSingle(Object name) {
    return 'Extraction of $name';
  }

  @override
  String extractMulti(Object index, Object name, Object total) {
    return 'Extraction $index/$total: $name';
  }

  @override
  String createLabel(Object name) {
    return 'Creation of $name.iso';
  }

  @override
  String optimizeSingle(Object name) {
    return 'Optimization of $name';
  }

  @override
  String optimizeMulti(Object index, Object name, Object total) {
    return 'Optimization $index/$total: $name';
  }

  @override
  String listLabel(Object name) {
    return 'File list of $name';
  }

  @override
  String doneAllExtract(Object count) {
    return 'Done: $count images extracted';
  }

  @override
  String toolVersion(Object version) {
    return 'extract-xiso v$version';
  }

  @override
  String logHidden(int count) {
    return '… $count earlier lines hidden';
  }

  @override
  String get logSave => 'Save log';

  @override
  String logSaved(String path) {
    return 'Log saved to $path';
  }

  @override
  String logSaveFailed(String message) {
    return 'Could not save the log: $message';
  }

  @override
  String get openOutputFolder => 'Open folder';

  @override
  String get recentLabel => 'Recent images';
}
