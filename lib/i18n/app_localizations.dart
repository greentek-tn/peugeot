import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context, [String? languageCode]) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Odoo App',
      'hometitle': 'Home',
      'settingsPageTitle': 'Settings',
      'languageSelectionLabel': 'Select Language',
      'StartButton': 'Start',
      'ConfigServer': 'Config Server',
      'ValidButton': 'Valid',
      'inValidButton': 'Invalid',
      'RetouchedButton': 'Retouched',
      'unRetouchedButton': 'Unretouched',
      'ResetButton': 'Reset',
      'ValidAllButton': 'Valid All',
      'NextButton': 'Next',
      'ResultButton': 'Result',
      'CreateCheckList': ' Create Checklist',
      'ManifacturingOrder': 'Fab Order',
      'CarColor': 'Car Color',
      'CarModel': 'Car Model',
      'Config': 'Config',
      'ServerURL': 'Server URL',
      'EntertheServerURL': 'Enter the Server URL',
      'ServerWarning': 'Please enter the Server URL',
      'Database': 'Database',
      'EntertheDatabase': 'Enter the Database',
      'PleaseentertheDatabase': 'Please enter the Database',
      'Save': 'Save',
      'Erroroccurred': 'Error occurred',
      'ConfigTablet': 'Config Tablet',
      'Back': 'Back',
      'Error': 'Error ',
      'Login': 'Login ',
      'Username': 'Username ',
      'Enteryourusername': 'Enter your username ',
      'Password': 'Password',
      'Enteryourpassword': 'Enter your password',
      'Checklist': 'Checklist',
      'Checklist-Zone': 'Checklist  - Zone',
      'Confirmation': 'Confirmation',
      'Areyousureyouwanttocancelthechecklist':
          'Are you sure you want to cancel the checklist?',
      'Entertheresult': 'Enter the result',
      'Cancel': 'Cancel',
      'Retouched': 'Retouched',
      'unRetouched': 'unRetouched',
      'CancelGotonextVehicle': 'Cancel / Go to next Vehicle',
      'Validate': 'Validate',
      'NumeroOF': 'Fanrication order : ',
      'ChecklistsList': 'List of checklists',
      'OF': 'Fabrication order number',
      'FabricationOrdernotfound': 'Fabrication Order not found',
      'Pleasecreatethechecklistbeforestartingit.':
          'Please create the checklist before starting it.',
      'OK': 'OK',
      'TitrePageConfig': 'Config Page',
      'configtabwizardWarning': 'Please select an option before proceeding',
      'configtabwizardSavingWarning': 'Please select all options before saving',
      'step': 'Step',
      'step1': 'Etape 1 : Factory',
      'step2': 'Etape 2 : Line',
      'step3': 'Etape 3 : Workstation',
      'checklist': 'Checklist',
      'ScanOF': 'Scan fabrication Order',
      'underexemption': 'Under Exemption'
    },
    'fr': {
      'title': 'Application Odoo',
      'hometitle': 'Accueil',
      'settingsPageTitle': 'Paramètres',
      'languageSelectionLabel': 'Sélectionner la langue',
      'StartButton': 'Démarrer',
      'ConfigServer': 'Configurer Serveur',
      'ValidButton': 'Valide',
      'inValidButton': 'Invalide',
      'RetouchedButton': 'Retoucher',
      'unRetouchedButton': 'Non Retoucher',
      'ResetButton': 'Reset',
      'ValidAllButton': 'Valider tout',
      'NextButton': 'Suivant',
      'ResultButton': 'Résultat',
      'CreateCheckList': ' Créer Checklist',
      'ManifacturingOrder': 'Ordre De Fabrication',
      'CarColor': 'Couleur ',
      'CarModel': 'Modèle',
      'Config': 'Configuration',
      'ServerURL': 'Lien du serveur',
      'EntertheServerURL': 'Entrez l URL du serveur',
      'ServerWarning': 'Veuillez entrer l URL du serveur',
      'Database': 'Base de données',
      'EntertheDatabase': 'Entrez  la base de données',
      'PleaseentertheDatabase': 'Veuillez entrer la base de données',
      'Save': 'Sauvegarder',
      'Erroroccurred': 'Erreur est survenue',
      'ConfigTablet': 'Configuration de Tablette',
      'Back': 'Retour ',
      'Error': 'Erreur ',
      'Login': 'Connexion ',
      'Username': 'Nom d\'utilisateur ',
      'Enteryourusername': 'Entrez votre nom d utilisateur',
      'Password': 'Mot de passe',
      'Enteryourpassword': 'Entrez votre mot de passe',
      'Checklist': 'Liste de contrôle',
      'ChecklistZone': 'Liste de contrôle - Zone : ',
      'Confirmation': 'Confirmation',
      'Areyousureyouwanttocancelthechecklist':
          'Voulez-vous vraiment annuler la liste de contrôle ?',
      'Entertheresult': 'Saisir le résultat',
      'Cancel': 'Annuler',
      'Retouched': 'Retouché',
      'unRetouched': 'non retouché',
      'CancelGotonextVehicle': 'Annuler / Aller au véhicule suivant',
      'Validate': 'Valider',
      'ChecklistsList': 'Liste des listes de contrôle',
      'NumeroOF': 'Ordre de fabrication : ',
      'OF': 'Odre de fabrication',
      'FabricationOrdernotfound': 'Ordre de fabrication introuvable',
      'Pleasecreatethechecklistbeforestartingit.':
          'Veuillez créer la liste de contrôle avant de la commencer.',
      'OK': 'OK',
      'TitrePageConfig': 'Page de configuration',
      'configtabwizardWarning':
          'Veuillez sélectionner une option avant de continuer',
      'configtabwizardSavingWarning':
          'Veuillez sélectionner toutes les options avant d\'enregistrer',
      'step': 'Etape',
      'step1': 'Etape 1 : Usine',
      'step2': 'Etape 2 : Ligne',
      'step3': 'Etape 3 : Poste de contrôle',
      'checklist': 'Listes de contrôle',
      'ScanOF': 'Scanner L\'ordre de Fabrication',
      'underexemption': 'Sous Dérogation'
    },
  };

  String? get title {
    return _localizedValues[locale.languageCode]!['title'];
  }

  String? get ScanOF {
    return _localizedValues[locale.languageCode]!['ScanOF'];
  }

  String? get underexemption {
    return _localizedValues[locale.languageCode]!['underexemption'];
  }

  String? get checklist {
    return _localizedValues[locale.languageCode]!['checklist'];
  }

  String? get step {
    return _localizedValues[locale.languageCode]!['step'];
  }

  String? get step1 {
    return _localizedValues[locale.languageCode]!['step1'];
  }

  String? get step2 {
    return _localizedValues[locale.languageCode]!['step2'];
  }

  String? get step3 {
    return _localizedValues[locale.languageCode]!['step3'];
  }

  String? get configtabwizardWarning {
    return _localizedValues[locale.languageCode]!['configtabwizardWarning'];
  }

  String? get configtabwizardSavingWarning {
    return _localizedValues[locale.languageCode]![
        'configtabwizardSavingWarning'];
  }

  String? get TitrePageConfig {
    return _localizedValues[locale.languageCode]!['TitrePageConfig'];
  }

  String? get OK {
    return _localizedValues[locale.languageCode]!['OK'];
  }

  String? get Pleasecreatethechecklistbeforestartingit {
    return _localizedValues[locale.languageCode]![
        'Pleasecreatethechecklistbeforestartingit'];
  }

  String? get FabricationOrdernotfound {
    return _localizedValues[locale.languageCode]!['FabricationOrdernotfound'];
  }

  String? get OF {
    return _localizedValues[locale.languageCode]!['OF'];
  }

  String? get NumeroOF {
    return _localizedValues[locale.languageCode]!['NumeroOF'];
  }

  String? get ChecklistsList {
    return _localizedValues[locale.languageCode]!['ChecklistsList'];
  }

  String? get Validate {
    return _localizedValues[locale.languageCode]!['Validate'];
  }

  String? get CancelGotonextVehicle {
    return _localizedValues[locale.languageCode]!['CancelGotonextVehicle'];
  }

  String? get unRetouched {
    return _localizedValues[locale.languageCode]!['unRetouched'];
  }

  String? get Retouched {
    return _localizedValues[locale.languageCode]!['Retouched'];
  }

  String? get Entertheresult {
    return _localizedValues[locale.languageCode]!['Entertheresult'];
  }

  String? get Cancel {
    return _localizedValues[locale.languageCode]!['Cancel'];
  }

  String? get Areyousureyouwanttocancelthechecklist {
    return _localizedValues[locale.languageCode]![
        'Areyousureyouwanttocancelthechecklist'];
  }

  String? get Confirmation {
    return _localizedValues[locale.languageCode]!['Confirmation'];
  }

  String? get ChecklistZone {
    return _localizedValues[locale.languageCode]!['ChecklistZone'];
  }

  String? get Checklist {
    return _localizedValues[locale.languageCode]!['Checklist'];
  }

  String? get Password {
    return _localizedValues[locale.languageCode]!['Password'];
  }

  String? get Enteryourpassword {
    return _localizedValues[locale.languageCode]!['Enteryourpassword'];
  }

  String? get Enteryourusername {
    return _localizedValues[locale.languageCode]!['Enteryourusername'];
  }

  String? get Username {
    return _localizedValues[locale.languageCode]!['Username'];
  }

  String? get Login {
    return _localizedValues[locale.languageCode]!['Login'];
  }

  String? get Back {
    return _localizedValues[locale.languageCode]!['Back'];
  }

  String? get Error {
    return _localizedValues[locale.languageCode]!['Error'];
  }

  String? get ConfigTablet {
    return _localizedValues[locale.languageCode]!['ConfigTablet'];
  }

  String? get Erroroccurred {
    return _localizedValues[locale.languageCode]!['Erroroccurred'];
  }

  String? get PleaseentertheDatabase {
    return _localizedValues[locale.languageCode]!['PleaseentertheDatabase'];
  }

  String? get Save {
    return _localizedValues[locale.languageCode]!['Save'];
  }

  String? get EntertheDatabase {
    return _localizedValues[locale.languageCode]!['EntertheDatabase'];
  }

  String? get Database {
    return _localizedValues[locale.languageCode]!['Database'];
  }

  String? get ServerWarning {
    return _localizedValues[locale.languageCode]!['ServerWarning'];
  }

  String? get EntertheServerURL {
    return _localizedValues[locale.languageCode]!['EntertheServerURL'];
  }

  String? get ServerURL {
    return _localizedValues[locale.languageCode]!['ServerURL'];
  }

  String? get Config {
    return _localizedValues[locale.languageCode]!['Config'];
  }

  String? get CreateCheckList {
    return _localizedValues[locale.languageCode]!['CreateCheckList'];
  }

  String? get ManifacturingOrder {
    return _localizedValues[locale.languageCode]!['ManifacturingOrder'];
  }

  String? get CarColor {
    return _localizedValues[locale.languageCode]!['CarColor'];
  }

  String? get CarModel {
    return _localizedValues[locale.languageCode]!['CarModel'];
  }

  String? get homePageTitle {
    return _localizedValues[locale.languageCode]!['hometitle'];
  }

  String? get settingsPageTitle {
    return _localizedValues[locale.languageCode]!['settingsPageTitle'];
  }

  String? get languageSelectionLabel {
    return _localizedValues[locale.languageCode]!['languageSelectionLabel'];
  }

  String? get StartButton {
    return _localizedValues[locale.languageCode]!['StartButton'];
  }

  String? get ConfigServer {
    return _localizedValues[locale.languageCode]!['ConfigServer'];
  }

//
  String? get ValidButton {
    return _localizedValues[locale.languageCode]!['ValidButton'];
  }

  String? get inValidButton {
    return _localizedValues[locale.languageCode]!['inValidButton'];
  }

  String? get RetouchedButton {
    return _localizedValues[locale.languageCode]!['RetouchedButton'];
  }

  String? get unRetouchedButton {
    return _localizedValues[locale.languageCode]!['unRetouchedButton'];
  }

  String? get ResetButton {
    return _localizedValues[locale.languageCode]!['ResetButton'];
  }

  String? get ValidAllButton {
    return _localizedValues[locale.languageCode]!['ValidAllButton'];
  }

  String? get NextButton {
    return _localizedValues[locale.languageCode]!['NextButton'];
  }

  String? get ResultButton {
    return _localizedValues[locale.languageCode]!['ResultButton'];
  }

//

  static Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}
