import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'XISO Studio'**
  String get appName;

  /// No description provided for @navExtract.
  ///
  /// In pt, this message translates to:
  /// **'Extrair'**
  String get navExtract;

  /// No description provided for @navList.
  ///
  /// In pt, this message translates to:
  /// **'Listar'**
  String get navList;

  /// No description provided for @navCreate.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get navCreate;

  /// No description provided for @navOptimize.
  ///
  /// In pt, this message translates to:
  /// **'Otimizar'**
  String get navOptimize;

  /// No description provided for @extractTitle.
  ///
  /// In pt, this message translates to:
  /// **'Extrair'**
  String get extractTitle;

  /// No description provided for @extractSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Expande o conteúdo de uma ou mais imagens XISO em pastas.'**
  String get extractSubtitle;

  /// No description provided for @listTitle.
  ///
  /// In pt, this message translates to:
  /// **'Listar'**
  String get listTitle;

  /// No description provided for @listSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Mostra a árvore de arquivos dentro de uma imagem XISO, sem extrair.'**
  String get listSubtitle;

  /// No description provided for @createTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get createTitle;

  /// No description provided for @createSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Monta uma nova imagem XISO a partir de uma pasta com os arquivos do jogo.'**
  String get createSubtitle;

  /// No description provided for @optimizeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Otimizar (rewrite)'**
  String get optimizeTitle;

  /// No description provided for @optimizeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Reescreve a estrutura do sistema de arquivos, reduzindo o tamanho final da imagem.'**
  String get optimizeSubtitle;

  /// No description provided for @labelSourceImages.
  ///
  /// In pt, this message translates to:
  /// **'Imagens de origem'**
  String get labelSourceImages;

  /// No description provided for @labelSourceImagesHint.
  ///
  /// In pt, this message translates to:
  /// **'use o botão ou cole o caminho'**
  String get labelSourceImagesHint;

  /// No description provided for @labelDestFolder.
  ///
  /// In pt, this message translates to:
  /// **'Pasta de destino'**
  String get labelDestFolder;

  /// No description provided for @labelDestHint.
  ///
  /// In pt, this message translates to:
  /// **'vazio = pasta atual'**
  String get labelDestHint;

  /// No description provided for @placeholderNoImage.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma imagem XISO selecionada'**
  String get placeholderNoImage;

  /// No description provided for @placeholderSameAsImage.
  ///
  /// In pt, this message translates to:
  /// **'Mesma pasta da imagem'**
  String get placeholderSameAsImage;

  /// No description provided for @labelImage.
  ///
  /// In pt, this message translates to:
  /// **'Imagem XISO'**
  String get labelImage;

  /// No description provided for @placeholderNoImageSelected.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma imagem selecionada'**
  String get placeholderNoImageSelected;

  /// No description provided for @labelSourceFolder.
  ///
  /// In pt, this message translates to:
  /// **'Pasta de origem'**
  String get labelSourceFolder;

  /// No description provided for @placeholderSourceFolder.
  ///
  /// In pt, this message translates to:
  /// **'Pasta com o conteúdo do jogo'**
  String get placeholderSourceFolder;

  /// No description provided for @labelOutputFile.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo de saída'**
  String get labelOutputFile;

  /// No description provided for @labelOutputHint.
  ///
  /// In pt, this message translates to:
  /// **'onde a .iso será gravada'**
  String get labelOutputHint;

  /// No description provided for @placeholderChooseOutput.
  ///
  /// In pt, this message translates to:
  /// **'Escolha onde salvar a imagem'**
  String get placeholderChooseOutput;

  /// No description provided for @actionChoose.
  ///
  /// In pt, this message translates to:
  /// **'Escolher'**
  String get actionChoose;

  /// No description provided for @actionSaveAs.
  ///
  /// In pt, this message translates to:
  /// **'Salvar como'**
  String get actionSaveAs;

  /// No description provided for @actionExtract.
  ///
  /// In pt, this message translates to:
  /// **'Extrair'**
  String get actionExtract;

  /// No description provided for @actionList.
  ///
  /// In pt, this message translates to:
  /// **'Listar conteúdo'**
  String get actionList;

  /// No description provided for @actionCreate.
  ///
  /// In pt, this message translates to:
  /// **'Criar imagem'**
  String get actionCreate;

  /// No description provided for @actionOptimize.
  ///
  /// In pt, this message translates to:
  /// **'Otimizar'**
  String get actionOptimize;

  /// No description provided for @actionCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @optSkipSystemUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Ignorar a pasta \$SystemUpdate'**
  String get optSkipSystemUpdate;

  /// No description provided for @optSkipSystemUpdateHint.
  ///
  /// In pt, this message translates to:
  /// **'Equivale a -s: não extrai as atualizações de dashboard embutidas.'**
  String get optSkipSystemUpdateHint;

  /// No description provided for @optPerIsoFolder.
  ///
  /// In pt, this message translates to:
  /// **'Uma subpasta por imagem'**
  String get optPerIsoFolder;

  /// No description provided for @optPerIsoFolderHint.
  ///
  /// In pt, this message translates to:
  /// **'Evita misturar arquivos quando há mais de uma imagem.'**
  String get optPerIsoFolderHint;

  /// No description provided for @optNoPatch.
  ///
  /// In pt, this message translates to:
  /// **'Não aplicar o patch de mídia nos arquivos .xbe'**
  String get optNoPatch;

  /// No description provided for @optNoPatchHint.
  ///
  /// In pt, this message translates to:
  /// **'Equivale a -m. Não recomendado: o jogo pode não ser reconhecido.'**
  String get optNoPatchHint;

  /// No description provided for @optDeleteOld.
  ///
  /// In pt, this message translates to:
  /// **'Apagar a imagem original depois de otimizar'**
  String get optDeleteOld;

  /// No description provided for @optDeleteOldHint.
  ///
  /// In pt, this message translates to:
  /// **'Equivale a -D. Irreversível.'**
  String get optDeleteOldHint;

  /// No description provided for @logHeader.
  ///
  /// In pt, this message translates to:
  /// **'SAÍDA'**
  String get logHeader;

  /// No description provided for @logEmpty.
  ///
  /// In pt, this message translates to:
  /// **'O log da execução aparece aqui.'**
  String get logEmpty;

  /// No description provided for @statusInitializing.
  ///
  /// In pt, this message translates to:
  /// **'inicializando…'**
  String get statusInitializing;

  /// No description provided for @statusReady.
  ///
  /// In pt, this message translates to:
  /// **'extract-xiso v{version} embarcado e pronto'**
  String statusReady(Object version);

  /// No description provided for @statusDone.
  ///
  /// In pt, this message translates to:
  /// **'Concluído: {label}'**
  String statusDone(Object label);

  /// No description provided for @statusFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falhou (código {code}): {label}'**
  String statusFailed(Object code, Object label);

  /// No description provided for @statusCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelado'**
  String get statusCancelled;

  /// No description provided for @statusError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao executar: {message}'**
  String statusError(Object message);

  /// No description provided for @statusToolFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao preparar a ferramenta'**
  String get statusToolFailed;

  /// No description provided for @menuLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get menuLanguage;

  /// No description provided for @menuClearLog.
  ///
  /// In pt, this message translates to:
  /// **'Limpar log'**
  String get menuClearLog;

  /// No description provided for @menuOpenOutput.
  ///
  /// In pt, this message translates to:
  /// **'Abrir pasta de saída'**
  String get menuOpenOutput;

  /// No description provided for @menuAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get menuAbout;

  /// No description provided for @tooltipClearPath.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get tooltipClearPath;

  /// No description provided for @languageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get languageSystem;

  /// No description provided for @languagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @aboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o XISO Studio'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In pt, this message translates to:
  /// **'Interface gráfica para o extract-xiso (v{version}).\nO binário do extract-xiso vai embutido neste executável.\nDesenvolvido por LucianoSkx.'**
  String aboutBody(Object version);

  /// No description provided for @entriesFound.
  ///
  /// In pt, this message translates to:
  /// **'{count} entradas encontradas'**
  String entriesFound(Object count);

  /// No description provided for @progressFiles.
  ///
  /// In pt, this message translates to:
  /// **'{done} / {total} arquivos'**
  String progressFiles(Object done, Object total);

  /// No description provided for @imagesSelected.
  ///
  /// In pt, this message translates to:
  /// **'{count} imagens selecionadas'**
  String imagesSelected(Object count);

  /// No description provided for @extractSingle.
  ///
  /// In pt, this message translates to:
  /// **'Extração de {name}'**
  String extractSingle(Object name);

  /// No description provided for @extractMulti.
  ///
  /// In pt, this message translates to:
  /// **'Extração {index}/{total}: {name}'**
  String extractMulti(Object index, Object name, Object total);

  /// No description provided for @createLabel.
  ///
  /// In pt, this message translates to:
  /// **'Criação de {name}.iso'**
  String createLabel(Object name);

  /// No description provided for @optimizeSingle.
  ///
  /// In pt, this message translates to:
  /// **'Otimização de {name}'**
  String optimizeSingle(Object name);

  /// No description provided for @optimizeMulti.
  ///
  /// In pt, this message translates to:
  /// **'Otimização {index}/{total}: {name}'**
  String optimizeMulti(Object index, Object name, Object total);

  /// No description provided for @listLabel.
  ///
  /// In pt, this message translates to:
  /// **'Listagem de {name}'**
  String listLabel(Object name);

  /// No description provided for @doneAllExtract.
  ///
  /// In pt, this message translates to:
  /// **'Concluído: {count} imagens extraídas'**
  String doneAllExtract(Object count);

  /// No description provided for @toolVersion.
  ///
  /// In pt, this message translates to:
  /// **'extract-xiso v{version}'**
  String toolVersion(Object version);

  /// Aviso no topo do console quando só o fim do log é exibido
  ///
  /// In pt, this message translates to:
  /// **'… {count} linhas anteriores ocultas'**
  String logHidden(int count);

  /// Dica do botão que exporta o console para um arquivo
  ///
  /// In pt, this message translates to:
  /// **'Salvar log'**
  String get logSave;

  /// Confirmação após gravar o log
  ///
  /// In pt, this message translates to:
  /// **'Log salvo em {path}'**
  String logSaved(String path);

  /// Falha ao gravar o log
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o log: {message}'**
  String logSaveFailed(String message);

  /// Botão que abre a pasta onde a execução gravou os arquivos
  ///
  /// In pt, this message translates to:
  /// **'Abrir pasta'**
  String get openOutputFolder;

  /// Dica do botão de histórico no campo de imagem
  ///
  /// In pt, this message translates to:
  /// **'Imagens recentes'**
  String get recentLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
