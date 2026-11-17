// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'XISO Studio';

  @override
  String get navExtract => 'Extrair';

  @override
  String get navList => 'Listar';

  @override
  String get navCreate => 'Criar';

  @override
  String get navOptimize => 'Otimizar';

  @override
  String get extractTitle => 'Extrair';

  @override
  String get extractSubtitle =>
      'Expande o conteúdo de uma ou mais imagens XISO em pastas.';

  @override
  String get listTitle => 'Listar';

  @override
  String get listSubtitle =>
      'Mostra a árvore de arquivos dentro de uma imagem XISO, sem extrair.';

  @override
  String get createTitle => 'Criar';

  @override
  String get createSubtitle =>
      'Monta uma nova imagem XISO a partir de uma pasta com os arquivos do jogo.';

  @override
  String get optimizeTitle => 'Otimizar (rewrite)';

  @override
  String get optimizeSubtitle =>
      'Reescreve a estrutura do sistema de arquivos, reduzindo o tamanho final da imagem.';

  @override
  String get labelSourceImages => 'Imagens de origem';

  @override
  String get labelSourceImagesHint => 'use o botão ou cole o caminho';

  @override
  String get labelDestFolder => 'Pasta de destino';

  @override
  String get labelDestHint => 'vazio = pasta atual';

  @override
  String get placeholderNoImage => 'Nenhuma imagem XISO selecionada';

  @override
  String get placeholderSameAsImage => 'Mesma pasta da imagem';

  @override
  String get labelImage => 'Imagem XISO';

  @override
  String get placeholderNoImageSelected => 'Nenhuma imagem selecionada';

  @override
  String get labelSourceFolder => 'Pasta de origem';

  @override
  String get placeholderSourceFolder => 'Pasta com o conteúdo do jogo';

  @override
  String get labelOutputFile => 'Arquivo de saída';

  @override
  String get labelOutputHint => 'onde a .iso será gravada';

  @override
  String get placeholderChooseOutput => 'Escolha onde salvar a imagem';

  @override
  String get actionChoose => 'Escolher';

  @override
  String get actionSaveAs => 'Salvar como';

  @override
  String get actionExtract => 'Extrair';

  @override
  String get actionList => 'Listar conteúdo';

  @override
  String get actionCreate => 'Criar imagem';

  @override
  String get actionOptimize => 'Otimizar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get optSkipSystemUpdate => 'Ignorar a pasta \$SystemUpdate';

  @override
  String get optSkipSystemUpdateHint =>
      'Equivale a -s: não extrai as atualizações de dashboard embutidas.';

  @override
  String get optPerIsoFolder => 'Uma subpasta por imagem';

  @override
  String get optPerIsoFolderHint =>
      'Evita misturar arquivos quando há mais de uma imagem.';

  @override
  String get optNoPatch => 'Não aplicar o patch de mídia nos arquivos .xbe';

  @override
  String get optNoPatchHint =>
      'Equivale a -m. Não recomendado: o jogo pode não ser reconhecido.';

  @override
  String get optDeleteOld => 'Apagar a imagem original depois de otimizar';

  @override
  String get optDeleteOldHint => 'Equivale a -D. Irreversível.';

  @override
  String get logHeader => 'SAÍDA';

  @override
  String get logEmpty => 'O log da execução aparece aqui.';

  @override
  String get statusInitializing => 'inicializando…';

  @override
  String statusReady(Object version) {
    return 'extract-xiso v$version embarcado e pronto';
  }

  @override
  String statusDone(Object label) {
    return 'Concluído: $label';
  }

  @override
  String statusFailed(Object code, Object label) {
    return 'Falhou (código $code): $label';
  }

  @override
  String get statusCancelled => 'Cancelado';

  @override
  String statusError(Object message) {
    return 'Erro ao executar: $message';
  }

  @override
  String get statusToolFailed => 'Falha ao preparar a ferramenta';

  @override
  String get menuLanguage => 'Idioma';

  @override
  String get menuClearLog => 'Limpar log';

  @override
  String get menuOpenOutput => 'Abrir pasta de saída';

  @override
  String get menuAbout => 'Sobre';

  @override
  String get tooltipClearPath => 'Limpar';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get aboutTitle => 'Sobre o XISO Studio';

  @override
  String aboutBody(Object version) {
    return 'Interface gráfica para o extract-xiso (v$version).\nO binário do extract-xiso vai embutido neste executável.\nDesenvolvido por LucianoSkx.';
  }

  @override
  String entriesFound(Object count) {
    return '$count entradas encontradas';
  }

  @override
  String progressFiles(Object done, Object total) {
    return '$done / $total arquivos';
  }

  @override
  String imagesSelected(Object count) {
    return '$count imagens selecionadas';
  }

  @override
  String extractSingle(Object name) {
    return 'Extração de $name';
  }

  @override
  String extractMulti(Object index, Object name, Object total) {
    return 'Extração $index/$total: $name';
  }

  @override
  String createLabel(Object name) {
    return 'Criação de $name.iso';
  }

  @override
  String optimizeSingle(Object name) {
    return 'Otimização de $name';
  }

  @override
  String optimizeMulti(Object index, Object name, Object total) {
    return 'Otimização $index/$total: $name';
  }

  @override
  String listLabel(Object name) {
    return 'Listagem de $name';
  }

  @override
  String doneAllExtract(Object count) {
    return 'Concluído: $count imagens extraídas';
  }

  @override
  String toolVersion(Object version) {
    return 'extract-xiso v$version';
  }

  @override
  String logHidden(int count) {
    return '… $count linhas anteriores ocultas';
  }
}
