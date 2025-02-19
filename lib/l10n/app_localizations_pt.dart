// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutSlogan => 'Próxima paragem: acessibilidade';

  @override
  String get aboutVersionLabel => 'Versão';

  @override
  String get aboutAuthorsLabel => 'Autores';

  @override
  String aboutAuthorsDescription(String appName) {
    return 'Colaboradores do $appName';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Política de privacidade';

  @override
  String get aboutIdeaLabel => 'Ideia';

  @override
  String get aboutIdeaDescription => 'Universidade de Tecnologia de Chemnitz\nProfessor de Design de Circuitos e Sistemas';

  @override
  String get aboutLicenseLabel => 'Licença';

  @override
  String get aboutLicensePackageLabel => 'Licenças de pacotes usados';

  @override
  String get aboutSourceCodeLabel => 'Código-fonte';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get helpOnboardingLabel => 'Ver novamente a introdução';

  @override
  String get helpReportErrorLabel => 'Reportar um erro';

  @override
  String get helpImproveTranslationLabel => 'Melhorar a tradução';

  @override
  String get onboardingGreetingTitle => 'Olá!';

  @override
  String get onboardingGreetingDescription => 'Estamos contentes por estar aqui e por querer fazer a sua parte para melhorar os transportes públicos.';

  @override
  String get onboardingGreetingButton => 'Eis como funciona';

  @override
  String get onboardingSurveyingTitle => 'Dê uma olhada';

  @override
  String get onboardingSurveyingDescription => 'Dirija-se a uma paragem próxima para verificar o seu estado atual.';

  @override
  String get onboardingSurveyingButton => 'Vou fazer isso';

  @override
  String get onboardingAnsweringTitle => 'Agora é a sua vez';

  @override
  String get onboardingAnsweringDescription => 'Para recolher dados, selecione um marcador na aplicação e responda às perguntas apresentadas.';

  @override
  String get onboardingAnsweringButton => 'Ok, entendi';

  @override
  String get onboardingContributingTitle => 'Partilhar é cuidar';

  @override
  String get onboardingContributingDescription => 'Envie as suas respostas para o OpenStreetMap para as partilhar com o mundo inteiro.';

  @override
  String get onboardingContributingButton => 'Aqui vamos nós';

  @override
  String get privacyPolicyTitle => 'Política de privacidade';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsProfessionalQuestionsLabel => 'Mostrar perguntas profissionais';

  @override
  String get settingsProfessionalQuestionsDescription => 'Por razões de segurança, destinado apenas a profissionais';

  @override
  String get settingsThemeLabel => 'Esquema de cores da aplicação';

  @override
  String get settingsThemeDialogTitle => 'Selecionar tema';

  @override
  String get settingsThemeOptionSystem => 'Configuração do sistema';

  @override
  String get settingsThemeOptionLight => 'Claro';

  @override
  String get settingsThemeOptionDark => 'Escuro';

  @override
  String get logoutDialogTitle => 'Encerrar sessão do OSM?';

  @override
  String get logoutDialogDescription => 'Se terminar a sessão, não pode enviar as alterações para o OpenStreetMap.';

  @override
  String get loginHint => 'Inicie sessão com a sua conta do OpenStreetMap para enviar as suas alterações.';

  @override
  String get numberInputPlaceholder => 'Introduzir aqui…';

  @override
  String get numberInputFallbackName => 'Valor';

  @override
  String get numberInputValidationError => 'Número inválido';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString deve ser menor que $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString deve ser maior que $min$unit.';
  }

  @override
  String get stringInputPlaceholder => 'Introduzir aqui…';

  @override
  String get stringInputValidationErrorMin => 'Demasiado curto';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Detalhes adicionados a $mapFeaturesString na área de paragem $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'e';

  @override
  String get uploadMessageSuccess => 'Alterações enviadas com sucesso.';

  @override
  String get uploadMessageServerConnectionError => 'Erro: sem conexão com o servidor OSM.';

  @override
  String get uploadMessageUnknownConnectionError => 'Erro desconhecido durante a transmissão.';

  @override
  String get queryMessageServerUnavailableError => 'Servidor indisponível ou sobrecarregado. Tente mais tarde.';

  @override
  String get queryMessageTooManyRequestsError => 'Demasiadas solicitações ao servidor.';

  @override
  String get queryMessageConnectionTimeoutError => 'Erro: a consulta ao servidor expirou.';

  @override
  String get queryMessageReceiveTimeoutError => 'Erro: o tempo limite de recebimento de dados foi ultrapassado.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Erro desconhecido durante a comunicação do servidor.';

  @override
  String get queryMessageUnknownError => 'Erro desconhecido.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Obrigado $userName pelas suas respostas.\nPor favor verifique-as antes de fazer o envio.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Obrigado pelas suas respostas.\nPor favor verifique-as antes de fazer o envio.';

  @override
  String get back => 'Anterior';

  @override
  String get next => 'Seguinte';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get finish => 'Finalizar';

  @override
  String get login => 'Iniciar sessão';

  @override
  String get logout => 'Sair';

  @override
  String get skip => 'Ignorar';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get and => 'e';

  @override
  String get more => 'mais';

  @override
  String get element => 'elemento';

  @override
  String get durationInputDaysLabel => 'dias';

  @override
  String get durationInputHoursLabel => 'horas';

  @override
  String get durationInputMinutesLabel => 'minutos';

  @override
  String get durationInputSecondsLabel => 'segundos';

  @override
  String get osmCreditsText => 'Dados © colaboradores do OpenStreetMap';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Adicionados detalhes a $elements na área de paragem $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Adicionados detalhes a $elements na área de paragem.';
  }

  @override
  String get mapFeatureBusStop => 'Paragem de autocarro';

  @override
  String get mapFeatureTramStop => 'Paragem de metro';

  @override
  String get mapFeatureTrainPlatform => 'Plataforma de comboio';

  @override
  String get mapFeaturePlatform => 'Plataforma';

  @override
  String get mapFeatureStopPole => 'Poste da paragem';

  @override
  String get mapFeatureStation => 'Estação';

  @override
  String get mapFeatureTicketSalesPoint => 'Ponto de venda de bilhetes';

  @override
  String get mapFeatureInformationPoint => 'Ponto de informação';

  @override
  String get mapFeatureStationMap => 'Mapa de estações/paragens';

  @override
  String get mapFeatureTicketMachine => 'Máquina de bilhetes';

  @override
  String get mapFeatureParkingSpot => 'Lugar de estacionamento';

  @override
  String get mapFeatureTaxiStand => 'Ponto de táxis';

  @override
  String get mapFeatureToilets => 'Casas de banho';

  @override
  String get mapFeatureLuggageLockers => 'Cacifos de bagagens';

  @override
  String get mapFeatureLuggageTransport => 'Transporte de bagagens';

  @override
  String get mapFeatureInformationTerminal => 'Terminal de informações';

  @override
  String get mapFeatureInformationCallPoint => 'Coluna de informações';

  @override
  String get mapFeatureHelpPoint => 'Ponto de ajuda';

  @override
  String get mapFeatureEmergencyCallPoint => 'Ponto de chamada de emergência';

  @override
  String get mapFeatureEntrance => 'Entrada';

  @override
  String get mapFeatureFootpath => 'Caminho';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Escadas';

  @override
  String get mapFeatureElevator => 'Elevador';

  @override
  String get mapFeatureEscalator => 'Escadas rolantes';

  @override
  String get mapFeatureCycleBarrier => 'Barreira de bicicletas';

  @override
  String get mapFeatureCrossing => 'Travessia de peões';

  @override
  String get mapFeatureTramCrossing => 'Travessia de metro';

  @override
  String get mapFeatureRailroadCrossing => 'Travessia ferroviária';

  @override
  String get mapFeatureFootwayCrossing => 'Travessia rodoviária';

  @override
  String get mapFeatureCyclewayCrossing => 'Travessia de ciclovia';

  @override
  String get mapFeatureCurb => 'Lancil';

  @override
  String get mapFeaturePedestrianLights => 'Semáforo para peões';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Plataforma: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Plataforma: $number';
  }

  @override
  String get semanticsLoginHint => 'Log in with your OpenStreetMap account to upload your changes.';

  @override
  String get semanticsFlutterMap => 'Map screen';

  @override
  String get semanticsReturnToMap => 'Close questionnaire and return to map';

  @override
  String semanticsDotsIndicator(num number) {
    return 'Page $number';
  }

  @override
  String semanticsPageIndicators(num number) {
    return 'There are $number introduction pages, select the one you would like to hear.';
  }

  @override
  String semanticsIntroductionPage(num number, num count) {
    return 'Introduction page $number of $count';
  }

  @override
  String get semanticsSlogan => 'Slogan';

  @override
  String get semanticsMFundImage => 'Funded by mFUND';

  @override
  String get semanticsFederalMinistryImage => 'Funded by Federal Ministry of Transport and Digital Infrastructure';

  @override
  String get semanticsSettingsDialogBox => 'Choose your preferred app theme';

  @override
  String get semanticsNavigationMenu => 'Navigation menu';

  @override
  String get semanticsResetRotationButton => 'Reset map rotation to north.';

  @override
  String get semanticsCurrentLocationButton => 'Set map to current location.';

  @override
  String get semanticsZoomInButton => 'Zoom in map';

  @override
  String get semanticsZoomOutButton => 'Zoom out map';

  @override
  String get semanticsQuestionSentence => 'The question is: ';

  @override
  String get semanticsUploadQuestionsButton => 'Upload answers';

  @override
  String get semanticsBackQuestionButton => 'Return to previous question.';

  @override
  String get semanticsNextQuestionButton => 'Next question';

  @override
  String get semanticsSkipQuestionButton => 'Skip question';

  @override
  String get semanticsFinishQuestionnaireButton => 'Finish questionnaire';

  @override
  String get semanticsSummary => 'Summary';

  @override
  String get semanticsCloseNavigationMenuButton => 'Close navigation menu.';

  @override
  String get semanticsCloseQuestionnaireAnnounce => 'Questionnaire is closed';

  @override
  String get semanticsOpenQuestionnaireAnnounce => 'Questionnaire is open';

  @override
  String semanticsUser(Object username) {
    return 'User $username activate to open browser profile';
  }

  @override
  String get semanticsLogout => 'Log out from your user account';

  @override
  String get semanticsClearField => 'Clear field';

  @override
  String get semanticsDurationAnswerReset => 'Reset duration';

  @override
  String get semanticsDurationAnswerStartStopwatch => 'Start stopwatch';

  @override
  String get semanticsDurationAnswerStopStopwatch => 'Stop stopwatch';

  @override
  String get semanticsReviewQuestion => 'Activate to return to question';

  @override
  String get semanticsNextStepOnboarding => 'Next page';

  @override
  String get semanticsFinishOnboarding => 'Finish introduction';

  @override
  String get semanticsCredits => 'Credits';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr(): super('pt_BR');

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutSlogan => 'Próxima parada: Acessibilidade';

  @override
  String get aboutVersionLabel => 'Versão';

  @override
  String get aboutAuthorsLabel => 'Autores';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName contribuidores';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Política de privacidade';

  @override
  String get aboutIdeaLabel => 'Ideia';

  @override
  String get aboutIdeaDescription => 'Universidade de Tecnologia de Chemnitz\nProfessor de Circuito e Design de Sistemas';

  @override
  String get aboutLicenseLabel => 'Licença';

  @override
  String get aboutLicensePackageLabel => 'Licenças de pacotes usados';

  @override
  String get aboutSourceCodeLabel => 'Código fonte';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get helpOnboardingLabel => 'Assista a introdução novamente';

  @override
  String get helpReportErrorLabel => 'Reportar um erro';

  @override
  String get helpImproveTranslationLabel => 'Melhorar a tradução';

  @override
  String get onboardingGreetingTitle => 'Olá!';

  @override
  String get onboardingGreetingDescription => 'Estamos felizes por você estar aqui e querer fazer a sua parte para melhorar o transporte público.';

  @override
  String get onboardingGreetingButton => 'Veja como funciona';

  @override
  String get onboardingSurveyingTitle => 'Dê uma olhada';

  @override
  String get onboardingSurveyingDescription => 'Vá até uma parada próxima para avaliar seu estado atual.';

  @override
  String get onboardingSurveyingButton => 'Eu vou fazer isso';

  @override
  String get onboardingAnsweringTitle => 'Agora é sua vez';

  @override
  String get onboardingAnsweringDescription => 'Para coletar dados selecione um marcador no app e responda às perguntas exibidas.';

  @override
  String get onboardingAnsweringButton => 'Ok, entendi';

  @override
  String get onboardingContributingTitle => 'Compartilhar é se importar';

  @override
  String get onboardingContributingDescription => 'Faça o upload de suas respostas no OpenStreetMap para compartilhá-las com o mundo inteiro.';

  @override
  String get onboardingContributingButton => 'Aqui vamos nós';

  @override
  String get privacyPolicyTitle => 'Política de privacidade';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsProfessionalQuestionsLabel => 'Exibir perguntas profissionais';

  @override
  String get settingsProfessionalQuestionsDescription => 'Por razões de segurança destinado apenas a profissionais';

  @override
  String get settingsThemeLabel => 'Esquema de cores do app';

  @override
  String get settingsThemeDialogTitle => 'Selecione o tema';

  @override
  String get settingsThemeOptionSystem => 'Padrão';

  @override
  String get settingsThemeOptionLight => 'Claro';

  @override
  String get settingsThemeOptionDark => 'Escuro';

  @override
  String get logoutDialogTitle => 'Sair do OSM?';

  @override
  String get logoutDialogDescription => 'Se você sair, não poderá mais enviar alterações para o OpenStreetMap.';

  @override
  String get loginHint => 'Faça login com sua conta OpenStreetMap para enviar suas alterações.';

  @override
  String get numberInputPlaceholder => 'Introduzir aqui…';

  @override
  String get numberInputFallbackName => 'Valor';

  @override
  String get numberInputValidationError => 'Número inválido';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString deve ser menor que $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString deve ser maior que $min$unit.';
  }

  @override
  String get stringInputPlaceholder => 'Introduzir aqui…';

  @override
  String get stringInputValidationErrorMin => 'Muito curta';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Detalhes adicionados $mapFeaturesString na área de parada $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'e';

  @override
  String get uploadMessageSuccess => 'Alterações enviadas com sucesso.';

  @override
  String get uploadMessageServerConnectionError => 'Erro: Sem conexão com o servidor OSM.';

  @override
  String get uploadMessageUnknownConnectionError => 'Erro desconhecido durante a transmissão.';

  @override
  String get queryMessageServerUnavailableError => 'Servidor indisponível ou sobrecarregado. Tente mais tarde.';

  @override
  String get queryMessageTooManyRequestsError => 'Muitas solicitações ao servidor.';

  @override
  String get queryMessageConnectionTimeoutError => 'Erro: A consulta do servidor expirou.';

  @override
  String get queryMessageReceiveTimeoutError => 'Erro: O tempo limite de recebimento de dados expirou.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Erro desconhecido durante a comunicação do servidor.';

  @override
  String get queryMessageUnknownError => 'Erro desconhecido.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Obrigado $userName pelas suas respostas.\nPor favor, verifique-os antes de fazer o upload.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Obrigado por suas respostas.\nPor favor, verifique-os antes de fazer o upload.';

  @override
  String get back => 'Voltar';

  @override
  String get next => 'Próximo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get finish => 'Finalizar';

  @override
  String get login => 'Entrar';

  @override
  String get logout => 'Sair';

  @override
  String get skip => 'Pular';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get and => 'e';

  @override
  String get more => 'mais';

  @override
  String get element => 'elemento';

  @override
  String get durationInputDaysLabel => 'dias';

  @override
  String get durationInputHoursLabel => 'horas';

  @override
  String get durationInputMinutesLabel => 'minutos';

  @override
  String get durationInputSecondsLabel => 'segundos';

  @override
  String get osmCreditsText => 'Dados © contribuidores do OpenStreetMap';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Adicionados detalhes a $elements na área de parada $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Adicionados detalhes a $elements na área de parada.';
  }

  @override
  String get mapFeatureBusStop => 'Ponto de ônibus';

  @override
  String get mapFeatureTramStop => 'Parada de bonde';

  @override
  String get mapFeatureTrainPlatform => 'Plataforma de trem';

  @override
  String get mapFeaturePlatform => 'Plataforma';

  @override
  String get mapFeatureStopPole => 'Poste de parada';

  @override
  String get mapFeatureStation => 'Estação';

  @override
  String get mapFeatureTicketSalesPoint => 'Ponto de venda de ingressos';

  @override
  String get mapFeatureInformationPoint => 'Ponto de informação';

  @override
  String get mapFeatureStationMap => 'Mapa de estações/paradas';

  @override
  String get mapFeatureTicketMachine => 'Máquina de bilhetes';

  @override
  String get mapFeatureParkingSpot => 'Vaga de estacionamento';

  @override
  String get mapFeatureTaxiStand => 'Ponto de taxi';

  @override
  String get mapFeatureToilets => 'Banheiros';

  @override
  String get mapFeatureLuggageLockers => 'Armários de bagagem';

  @override
  String get mapFeatureLuggageTransport => 'Transporte de bagagem';

  @override
  String get mapFeatureInformationTerminal => 'Terminal de informações';

  @override
  String get mapFeatureInformationCallPoint => 'Coluna de informações';

  @override
  String get mapFeatureHelpPoint => 'Ponto de ajuda';

  @override
  String get mapFeatureEmergencyCallPoint => 'Ponto de chamada de emergência';

  @override
  String get mapFeatureEntrance => 'Entrada';

  @override
  String get mapFeatureFootpath => 'Caminho';

  @override
  String get mapFeatureStairs => 'Escadaria';

  @override
  String get mapFeatureElevator => 'Elevador';

  @override
  String get mapFeatureEscalator => 'Escada rolante';

  @override
  String get mapFeatureCycleBarrier => 'Barreira de bicicletas';

  @override
  String get mapFeatureCrossing => 'Travessia';

  @override
  String get mapFeatureTramCrossing => 'Travessia de bonde';

  @override
  String get mapFeatureRailroadCrossing => 'Cruzamento de linha férrea';

  @override
  String get mapFeatureFootwayCrossing => 'Travessia de pedestres';

  @override
  String get mapFeatureCyclewayCrossing => 'Travessia de bicicletas';

  @override
  String get mapFeatureCurb => 'Meio-fio';

  @override
  String get mapFeaturePedestrianLights => 'Luzes para pedestres';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Plataforma: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Plataforma: $number';
  }
}
