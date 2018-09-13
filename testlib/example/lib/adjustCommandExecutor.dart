import 'package:adjust_sdk_plugin/adjust_config.dart';
import 'package:adjust_sdk_plugin/adjust_event.dart';
import 'package:adjust_sdk_plugin/adjust_sdk_plugin.dart';
import 'package:adjust_sdk_plugin/nullable.dart';
import 'package:testlib_example/command.dart';

class AdjustCommandExecutor {
  String _baseUrl;
  String _basePath;
  String _gdprUrl;
  String _gdprPath;
  Map<int, AdjustEvent> _savedEvents = new Map<int, AdjustEvent>();
  Map<int, AdjustConfig> _savedConfigs = new Map<int, AdjustConfig>();
  Command _command;

  AdjustCommandExecutor(String baseUrl, String gdprUrl) {
    _baseUrl = baseUrl;
    _gdprUrl = gdprUrl;
  }

  void executeCommand(Command command) {
    _command = command;
    switch (command.methodName) {
        case "testOptions": _testOptions(); break;
        case "config": _config(); break;
        case "start": _start(); break;
        case "event": _event(); break;
        case "trackEvent": _trackEvent(); break;
        case "resume": _resume(); break;
        case "pause": _pause(); break;
        case "setEnabled": _setEnabled(); break;
        case "setReferrer": _setReferrer(); break; //TODO: check
        case "sendReferrer": _setReferrer(); break; //TODO: check
        case "setOfflineMode": _setOfflineMode(); break;
        case "sendFirstPackages": _sendFirstPackages(); break;
        case "addSessionCallbackParameter": _addSessionCallbackParameter(); break;
        case "addSessionPartnerParameter": _addSessionPartnerParameter(); break;
        case "removeSessionCallbackParameter": _removeSessionCallbackParameter(); break;
        case "removeSessionPartnerParameter": _removeSessionPartnerParameter(); break;
        case "resetSessionCallbackParameters": _resetSessionCallbackParameters(); break;
        case "resetSessionPartnerParameters": _resetSessionPartnerParameters(); break;
        case "setPushToken": _setPushToken(); break;
        case "openDeeplink": _openDeeplink(); break;
        case "gdprForgetMe": _gdprForgetMe(); break;
    }
  }

  void _testOptions() {
    final dynamic testOptions = {};
    testOptions['baseUrl'] = _baseUrl;
    testOptions['gdprUrl'] = _gdprUrl;
    if (_command.containsParameter("basePath")) {
      _basePath = _command.getFirstParameterValue("basePath");
      _gdprPath = _command.getFirstParameterValue("basePath");
    }
    if (_command.containsParameter("timerInterval")) {
      testOptions['timerIntervalInMilliseconds'] = _command.getFirstParameterValue("timerInterval");
    }
    if (_command.containsParameter("timerStart")) {
      testOptions['timerStartInMilliseconds'] = _command.getFirstParameterValue("timerStart");
    }
    if (_command.containsParameter("sessionInterval")) {
      testOptions['sessionIntervalInMilliseconds'] = _command.getFirstParameterValue("sessionInterval");
    }
    if (_command.containsParameter("subsessionInterval")) {
      testOptions['subsessionIntervalInMilliseconds'] = _command.getFirstParameterValue("subsessionInterval");
    }
    if (_command.containsParameter("tryInstallReferrer")) {
      testOptions['tryInstallReferrer'] = _command.getFirstParameterValue("tryInstallReferrer");
    }
    if (_command.containsParameter("noBackoffWait")) {
      testOptions['noBackoffWait'] = _command.getFirstParameterValue("noBackoffWait");
    }
    if (_command.containsParameter("teardown")) {
      List<dynamic> teardownOptions = _command.getParamteters("teardown");
      for (String teardownOption in teardownOptions) {
        if (teardownOption == "resetSdk") {
          testOptions['teardown'] = 'true';
          testOptions['basePath'] = _basePath;
          testOptions['gdprPath'] = _gdprPath;
          // android specific
          testOptions['useTestConnectionOptions'] = 'true';
          testOptions['tryInstallReferrer'] = 'false';
          // TODO: ios specific
        }
        if (teardownOption == "deleteState") {
          testOptions['deleteState'] = 'true';
        }
        if (teardownOption == "resetTest") {
          if (_savedEvents != null) {
            _savedEvents.clear();
          }
          if (_savedConfigs != null) {
            _savedConfigs.clear();
          }
          testOptions['timerIntervalInMilliseconds'] = '-1';
          testOptions['timerStartInMilliseconds'] = '-1';
          testOptions['sessionIntervalInMilliseconds'] = '-1';
          testOptions['subsessionIntervalInMilliseconds'] = '-1';
        }
        if (teardownOption == "sdk") {
          testOptions['teardown'] = 'true';
          testOptions['basePath'] = null;
          testOptions['gdprPath'] = null;
          // android specific
          testOptions['useTestConnectionOptions'] = 'false';
        }
        if (teardownOption == "test") {
          _savedEvents = null;
          _savedConfigs = null;
          testOptions['timerIntervalInMilliseconds'] = '-1';
          testOptions['timerStartInMilliseconds'] = '-1';
          testOptions['sessionIntervalInMilliseconds'] = '-1';
          testOptions['subsessionIntervalInMilliseconds'] = '-1';
        }
      }
    }
    AdjustSdkPlugin.setTestOptions(testOptions);
  }

  void _config() {
    int configNumber = 0;
    if (_command.containsParameter("configName")) {
      String configName = _command.getFirstParameterValue("configName");
      configNumber = int.parse(configName.substring(configName.length - 1));
    }

    AdjustConfig adjustConfig;
    if (_savedConfigs[configNumber] != null) {
      adjustConfig = _savedConfigs[configNumber];
    } else {
      adjustConfig = new AdjustConfig();
      String environmentString = _command.getFirstParameterValue("environment");
      adjustConfig.environment = environmentString == 'sandbox' ? AdjustEnvironment.sandbox : AdjustEnvironment.production;
      adjustConfig.appToken = _command.getFirstParameterValue("appToken");
      adjustConfig.logLevel = AdjustLogLevel.VERBOSE;
      _savedConfigs.putIfAbsent(configNumber, () => adjustConfig);
    }

    if (_command.containsParameter("logLevel")) {
      String logLevelString = _command.getFirstParameterValue("logLevel");
      AdjustLogLevel logLevel;
      switch (logLevelString) {
          case "verbose": logLevel = AdjustLogLevel.VERBOSE;
              break;
          case "debug": logLevel = AdjustLogLevel.DEBUG;
              break;
          case "info": logLevel = AdjustLogLevel.INFO;
              break;
          case "warn": logLevel = AdjustLogLevel.WARN;
              break;
          case "error": logLevel = AdjustLogLevel.ERROR;
              break;
          case "assert": logLevel = AdjustLogLevel.ASSERT;
              break;
          case "suppress": logLevel = AdjustLogLevel.SUPRESS;
              break;
      }
      adjustConfig.logLevel = logLevel;
    }

    if (_command.containsParameter("sdkPrefix")) {
      // not needed
      print('Setting sdkPrefix not supported!');
    }

    if (_command.containsParameter("defaultTracker")) {
      adjustConfig.defaultTracker = _command.getFirstParameterValue("defaultTracker");
    }

    if (_command.containsParameter("appSecret")) {
      List<dynamic> appSecretArray = _command.getParamteters("appSecret");
      num secretId = num.parse(appSecretArray[0]);
      num info1 = num.parse(appSecretArray[1]);
      num info2 = num.parse(appSecretArray[2]);
      num info3 = num.parse(appSecretArray[3]);
      num info4 = num.parse(appSecretArray[4]);
      adjustConfig.setAppSecret(secretId, info1, info2, info3, info4);
    }

    if (_command.containsParameter("delayStart")) {
      double delayStart = double.parse(_command.getFirstParameterValue("delayStart"));
      adjustConfig.delayStart = new Nullable<double>(delayStart);
    }

    if (_command.containsParameter("deviceKnown")) {
      bool isDeviceKnown = _command.getFirstParameterValue("deviceKnown") == 'true';
      adjustConfig.isDeviceKnown = new Nullable<bool>(isDeviceKnown);
    }

    if (_command.containsParameter("eventBufferingEnabled")) {
      bool eventBufferingEnabled = _command.getFirstParameterValue("eventBufferingEnabled") == 'true';
      adjustConfig.sendInBackground = new Nullable<bool>(eventBufferingEnabled);
    }

    if (_command.containsParameter("sendInBackground")) {
      bool sendInBackground = _command.getFirstParameterValue("sendInBackground") == 'true';
      adjustConfig.sendInBackground = new Nullable<bool>(sendInBackground);
    }

    if (_command.containsParameter("userAgent")) {
      adjustConfig.userAgent = _command.getFirstParameterValue("userAgent");
    }

    if(_command.containsParameter("deferredDeeplinkCallback")) {
      
    }

    if(_command.containsParameter("attributionCallbackSendAll")) {
      
    }

    if(_command.containsParameter("sessionCallbackSendSuccess")) {
      
    }

    if(_command.containsParameter("sessionCallbackSendFailure")) {
      
    }

    if(_command.containsParameter("eventCallbackSendSuccess")) {
      
    }

    if(_command.containsParameter("eventCallbackSendFailure")) {
      
    }
  }

  void _start() {
    _config();
    int configNumber = 0;
    if (_command.containsParameter("configName")) {
      String configName = _command.getFirstParameterValue("configName");
      configNumber = int.parse(configName.substring(configName.length - 1));
    }

    AdjustConfig adjustConfig = _savedConfigs[configNumber];
    AdjustSdkPlugin.onCreate(adjustConfig);
    _savedConfigs.remove(configNumber);
  }

  void _event() {
    int eventNumber = 0;
    if (_command.containsParameter("eventNumber")) {
      String eventName = _command.getFirstParameterValue("eventName");
      eventNumber = int.parse(eventName.substring(eventName.length - 1));
    }

    AdjustEvent adjustEvent;
    if (_savedConfigs[eventNumber] != null) {
        adjustEvent = _savedEvents[eventNumber];
    } else {
      String eventToken = _command.getFirstParameterValue("eventToken");
      adjustEvent = new AdjustEvent(eventToken);
      _savedEvents.putIfAbsent(eventNumber, () => adjustEvent);
    }

    if (_command.containsParameter("revenue")) {
      List<String> revenueParams = _command.getParamteters("revenue");
      adjustEvent.currency = revenueParams[0];
      adjustEvent.revenue = new Nullable<num>(num.parse(revenueParams[1]));
    }
    if (_command.containsParameter("callbackParams")) {
      List<String> callbackParams = _command.getParamteters("callbackParams");
      for (int i = 0; i < callbackParams.length; i = i + 2) {
        String key = callbackParams[i];
        String value = callbackParams[i + 1];
        adjustEvent.addCallbackParameter(key, value);
      }
    }
    if (_command.containsParameter("partnerParams")) {
      List<String> partnerParams = _command.getParamteters("partnerParams");
      for (int i = 0; i < partnerParams.length; i = i + 2) {
        String key = partnerParams[i];
        String value = partnerParams[i + 1];
        adjustEvent.addPartnerParameter(key, value);
      }
    }
    if (_command.containsParameter("orderId")) {
      adjustEvent.orderId = _command.getFirstParameterValue("orderId");
    }
    // from 4.15.0
    if (_command.containsParameter("callbackId")) {
      // adjustEvent.callbackId = _command.getFirstParameterValue("callbackId");
    }
  }

  void _trackEvent() {
    _event();
    int eventNumber = 0;
    if (_command.containsParameter("eventName")) {
      String eventName = _command.getFirstParameterValue("eventName");
      eventNumber = int.parse(eventName.substring(eventName.length - 1));
    }

    AdjustEvent adjustEvent = _savedEvents[eventNumber];
    AdjustSdkPlugin.trackEvent(adjustEvent);

    _savedConfigs.remove(eventNumber);
  }

  void _resume() {
    AdjustSdkPlugin.onResume();
  }

  void _pause() {
    AdjustSdkPlugin.onPause();
  }

  void _setEnabled() {
    bool isEnabled = _command.getFirstParameterValue("enabled") == 'true';
    AdjustSdkPlugin.setIsEnabled(isEnabled);
  }

  void _setReferrer() {
    String referrer = _command.getFirstParameterValue("referrer");
    AdjustSdkPlugin.setReferrer(referrer);
  }

  void _setOfflineMode() {
    bool isEnabled = _command.getFirstParameterValue("enabled") == 'true';
    AdjustSdkPlugin.setOfflineMode(isEnabled);
  }

  void _sendFirstPackages() {
    AdjustSdkPlugin.sendFirstPackages();
  }

  void _setPushToken() {
    String token = _command.getFirstParameterValue("pushToken");
    AdjustSdkPlugin.setPushToken(token);
  }

  void _openDeeplink() {
    String deeplink = _command.getFirstParameterValue("deeplink");
    AdjustSdkPlugin.appWillOpenUrl(deeplink);
  }

  void _gdprForgetMe() {
    AdjustSdkPlugin.gdprForgetMe();
  }

  void _addSessionCallbackParameter() {
    if (!_command.containsParameter("KeyValue")) {
      return;
    }

    List<String> keyValuePairs = _command.getParamteters("KeyValue");
    for (int i = 0; i<keyValuePairs.length; i = i + 2) {
      String key = keyValuePairs[i];
      String value = keyValuePairs[i + 1];
      AdjustSdkPlugin.addSessionCallbackParameter(key, value);
    }
  }

  void _addSessionPartnerParameter() {
    if (!_command.containsParameter("KeyValue")) {
      return;
    }

    List<String> keyValuePairs = _command.getParamteters("KeyValue");
    for (int i = 0; i<keyValuePairs.length; i = i + 2) {
      String key = keyValuePairs[i];
      String value = keyValuePairs[i + 1];
      AdjustSdkPlugin.addSessionPartnerParameter(key, value);
    }
  }

  void _removeSessionCallbackParameter() {
    if (!_command.containsParameter("key")) {
      return;
    }

    List<String> keys = _command.getParamteters("key");
    for (int i = 0; i<keys.length; i = i + 1) {
      String key = keys[i];
      AdjustSdkPlugin.removeSessionCallbackParameter(key);
    }
  }

  void _removeSessionPartnerParameter() {
    if (!_command.containsParameter("key")) {
      return;
    }
    
    List<String> keys = _command.getParamteters("key");
    for (int i = 0; i<keys.length; i = i + 1) {
      String key = keys[i];
      AdjustSdkPlugin.removeSessionPartnerParameter(key);
    }
  }

  void _resetSessionCallbackParameters() {
    AdjustSdkPlugin.resetSessionCallbackParameters();
  }

  void _resetSessionPartnerParameters() {
    AdjustSdkPlugin.resetSessionPartnerParameters();
  }
}
