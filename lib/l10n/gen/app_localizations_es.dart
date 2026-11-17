// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'XISO Studio';

  @override
  String get navExtract => 'Extraer';

  @override
  String get navList => 'Listar';

  @override
  String get navCreate => 'Crear';

  @override
  String get navOptimize => 'Optimizar';

  @override
  String get extractTitle => 'Extraer';

  @override
  String get extractSubtitle =>
      'Expande el contenido de una o más imágenes XISO en carpetas.';

  @override
  String get listTitle => 'Listar';

  @override
  String get listSubtitle =>
      'Muestra el árbol de archivos dentro de una imagen XISO, sin extraer.';

  @override
  String get createTitle => 'Crear';

  @override
  String get createSubtitle =>
      'Arma una nueva imagen XISO a partir de una carpeta con los archivos del juego.';

  @override
  String get optimizeTitle => 'Optimizar (rewrite)';

  @override
  String get optimizeSubtitle =>
      'Reescribe la estructura del sistema de archivos, reduciendo el tamaño final de la imagen.';

  @override
  String get labelSourceImages => 'Imágenes de origen';

  @override
  String get labelSourceImagesHint => 'use el botón o pegue la ruta';

  @override
  String get labelDestFolder => 'Carpeta de destino';

  @override
  String get labelDestHint => 'vacío = carpeta actual';

  @override
  String get placeholderNoImage => 'Ninguna imagen XISO seleccionada';

  @override
  String get placeholderSameAsImage => 'Misma carpeta de la imagen';

  @override
  String get labelImage => 'Imagen XISO';

  @override
  String get placeholderNoImageSelected => 'Ninguna imagen seleccionada';

  @override
  String get labelSourceFolder => 'Carpeta de origen';

  @override
  String get placeholderSourceFolder => 'Carpeta con el contenido del juego';

  @override
  String get labelOutputFile => 'Archivo de salida';

  @override
  String get labelOutputHint => 'dónde se escribirá la .iso';

  @override
  String get placeholderChooseOutput => 'Elija dónde guardar la imagen';

  @override
  String get actionChoose => 'Elegir';

  @override
  String get actionSaveAs => 'Guardar como';

  @override
  String get actionExtract => 'Extraer';

  @override
  String get actionList => 'Listar contenido';

  @override
  String get actionCreate => 'Crear imagen';

  @override
  String get actionOptimize => 'Optimizar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get optSkipSystemUpdate => 'Omitir la carpeta \$SystemUpdate';

  @override
  String get optSkipSystemUpdateHint =>
      'Igual a -s: no extrae las actualizaciones de dashboard incluidas.';

  @override
  String get optPerIsoFolder => 'Una subcarpeta por imagen';

  @override
  String get optPerIsoFolderHint =>
      'Evita mezclar archivos cuando hay más de una imagen.';

  @override
  String get optNoPatch =>
      'No aplicar el parche de medios en los archivos .xbe';

  @override
  String get optNoPatchHint =>
      'Igual a -m. No recomendado: el juego puede no ser reconocido.';

  @override
  String get optDeleteOld => 'Borrar la imagen original después de optimizar';

  @override
  String get optDeleteOldHint => 'Igual a -D. Irreversible.';

  @override
  String get logHeader => 'SALIDA';

  @override
  String get logEmpty => 'El log de la ejecución aparece aquí.';

  @override
  String get statusInitializing => 'inicializando…';

  @override
  String statusReady(Object version) {
    return 'extract-xiso v$version incluido y listo';
  }

  @override
  String statusDone(Object label) {
    return 'Listo: $label';
  }

  @override
  String statusFailed(Object code, Object label) {
    return 'Falló (código $code): $label';
  }

  @override
  String get statusCancelled => 'Cancelado';

  @override
  String statusError(Object message) {
    return 'Error al ejecutar: $message';
  }

  @override
  String get statusToolFailed => 'No se pudo preparar la herramienta incluida';

  @override
  String get menuLanguage => 'Idioma';

  @override
  String get menuClearLog => 'Limpiar log';

  @override
  String get menuOpenOutput => 'Abrir carpeta de salida';

  @override
  String get menuAbout => 'Acerca de';

  @override
  String get tooltipClearPath => 'Limpiar';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get aboutTitle => 'Acerca de XISO Studio';

  @override
  String aboutBody(Object version) {
    return 'Interfaz gráfica para extract-xiso (v$version).\nEl binario de extract-xiso va incluido en este ejecutable.\nDesarrollado por LucianoSkx.';
  }

  @override
  String entriesFound(Object count) {
    return '$count entradas encontradas';
  }

  @override
  String progressFiles(Object done, Object total) {
    return '$done / $total archivos';
  }

  @override
  String imagesSelected(Object count) {
    return '$count imágenes seleccionadas';
  }

  @override
  String extractSingle(Object name) {
    return 'Extracción de $name';
  }

  @override
  String extractMulti(Object index, Object name, Object total) {
    return 'Extracción $index/$total: $name';
  }

  @override
  String createLabel(Object name) {
    return 'Creación de $name.iso';
  }

  @override
  String optimizeSingle(Object name) {
    return 'Optimización de $name';
  }

  @override
  String optimizeMulti(Object index, Object name, Object total) {
    return 'Optimización $index/$total: $name';
  }

  @override
  String listLabel(Object name) {
    return 'Lista de archivos de $name';
  }

  @override
  String doneAllExtract(Object count) {
    return 'Listo: $count imágenes extraídas';
  }

  @override
  String toolVersion(Object version) {
    return 'extract-xiso v$version';
  }

  @override
  String logHidden(int count) {
    return '… $count líneas anteriores ocultas';
  }

  @override
  String get logSave => 'Guardar registro';

  @override
  String logSaved(String path) {
    return 'Registro guardado en $path';
  }

  @override
  String logSaveFailed(String message) {
    return 'No se pudo guardar el registro: $message';
  }

  @override
  String get openOutputFolder => 'Abrir carpeta';

  @override
  String get recentLabel => 'Imágenes recientes';
}
