// To parse this JSON data, do
//
//     final webSocketEvent = webSocketEventFromMap(jsonString);

import 'dart:convert';

WebSocketEvent webSocketEventFromMap(String str) => WebSocketEvent.fromMap(json.decode(str));

String webSocketEventToMap(WebSocketEvent data) => json.encode(data.toMap());

class WebSocketEvent {
  String? eventKind;
  DateTime? eventTime;
  MeterValueEventData? data;

  WebSocketEvent({
    this.eventKind,
    this.eventTime,
    this.data,
  });

  factory WebSocketEvent.fromMap(Map<String, dynamic> json) => WebSocketEvent(
    eventKind: json["eventKind"],
    eventTime: json["eventTime"] == null ? null : DateTime.parse(json["eventTime"]),
    data: json["data"] == null ? null : MeterValueEventData.fromMap(json["data"]),
  );

  Map<String, dynamic> toMap() => {
    "eventKind": eventKind,
    "eventTime": eventTime?.toIso8601String(),
    "data": data?.toMap(),
  };
}

class MeterValueEventData {
  String? event;
  int? connector;
  String? chargingStation;
  Samples? samples;
  Transaction? transaction;

  MeterValueEventData({
    this.event,
    this.connector,
    this.chargingStation,
    this.samples,
    this.transaction,
  });

  factory MeterValueEventData.fromMap(Map<String, dynamic> json) => MeterValueEventData(
    event: json["event"],
    connector: json["connector"],
    chargingStation: json["chargingStation"],
    samples: json["samples"] == null ? null : Samples.fromMap(json["samples"]),
    transaction: json["transaction"] == null ? null : Transaction.fromMap(json["transaction"]),
  );

  Map<String, dynamic> toMap() => {
    "event": event,
    "connector": connector,
    "chargingStation": chargingStation,
    "samples": samples?.toMap(),
    "transaction": transaction?.toMap(),
  };
}

class Samples {
  int? energyQuantity;
  int? vehicleChargingLevel;
  int? temperature;
  int? power;
  List<dynamic>? samples;
  Values? values;

  Samples({
    this.energyQuantity,
    this.vehicleChargingLevel,
    this.temperature,
    this.power,
    this.samples,
    this.values,
  });

  factory Samples.fromMap(Map<String, dynamic> json) => Samples(
    energyQuantity: json["energyQuantity"],
    vehicleChargingLevel: json["vehicleChargingLevel"],
    temperature: json["temperature"],
    power: json["power"],
    samples: json["samples"] == null ? [] : List<dynamic>.from(json["samples"]!.map((x) => x)),
    values: json["values"] == null ? null : Values.fromMap(json["values"]),
  );

  Map<String, dynamic> toMap() => {
    "energyQuantity": energyQuantity,
    "vehicleChargingLevel": vehicleChargingLevel,
    "temperature": temperature,
    "power": power,
    "samples": samples == null ? [] : List<dynamic>.from(samples!.map((x) => x)),
    "values": values?.toMap(),
  };
}

class Values {
  String? temperature;
  String? powerActiveImport;
  String? currentImport;
  String? voltage;
  String? energyActiveImportRegister;

  Values({
    this.temperature,
    this.powerActiveImport,
    this.currentImport,
    this.voltage,
    this.energyActiveImportRegister,
  });

  factory Values.fromMap(Map<String, dynamic> json) => Values(
    temperature: json["Temperature"],
    powerActiveImport: json["Power.Active.Import"],
    currentImport: json["Current.Import"],
    voltage: json["Voltage"],
    energyActiveImportRegister: json["Energy.Active.Import.Register"],
  );

  Map<String, dynamic> toMap() => {
    "Temperature": temperature,
    "Power.Active.Import": powerActiveImport,
    "Current.Import": currentImport,
    "Voltage": voltage,
    "Energy.Active.Import.Register": energyActiveImportRegister,
  };
}

class Transaction {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  int? transactionId;
  dynamic rfidTag;
  Customer? customer;
  Connector? chargingConnector;
  DateTime? startTime;
  dynamic endTime;
  int? energyConsumed;
  int? amountConsumed;
  String? status;
  int? meterStart;
  dynamic meterStop;
  DateTime? chargingStartTime;
  dynamic chargingEndTime;
  int? maxAllowedEnergyInKWh;
  int? reservedAmount;
  OcppSession? ocppSession;
  Wallet? chargingWallet;
  dynamic walletTransaction;
  dynamic stopReason;
  TariffClass? tariffClass;
  dynamic initialBillingComputationLog;
  dynamic finalBillingComputationLog;
  dynamic vehicle;
  dynamic chargingPower;
  dynamic invoice;

  Transaction({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.transactionId,
    this.rfidTag,
    this.customer,
    this.chargingConnector,
    this.startTime,
    this.endTime,
    this.energyConsumed,
    this.amountConsumed,
    this.status,
    this.meterStart,
    this.meterStop,
    this.chargingStartTime,
    this.chargingEndTime,
    this.maxAllowedEnergyInKWh,
    this.reservedAmount,
    this.ocppSession,
    this.chargingWallet,
    this.walletTransaction,
    this.stopReason,
    this.tariffClass,
    this.initialBillingComputationLog,
    this.finalBillingComputationLog,
    this.vehicle,
    this.chargingPower,
    this.invoice,
  });

  factory Transaction.fromMap(Map<String, dynamic> json) => Transaction(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    transactionId: json["transactionId"],
    rfidTag: json["rfidTag"],
    customer: json["customer"] == null ? null : Customer.fromMap(json["customer"]),
    chargingConnector: json["chargingConnector"] == null ? null : Connector.fromMap(json["chargingConnector"]),
    startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
    endTime: json["endTime"],
    energyConsumed: json["energyConsumed"],
    amountConsumed: json["amountConsumed"],
    status: json["status"],
    meterStart: json["meterStart"],
    meterStop: json["meterStop"],
    chargingStartTime: json["chargingStartTime"] == null ? null : DateTime.parse(json["chargingStartTime"]),
    chargingEndTime: json["chargingEndTime"],
    maxAllowedEnergyInKWh: json["maxAllowedEnergyInKWh"],
    reservedAmount: json["reservedAmount"],
    ocppSession: json["ocppSession"] == null ? null : OcppSession.fromMap(json["ocppSession"]),
    chargingWallet: json["chargingWallet"] == null ? null : Wallet.fromMap(json["chargingWallet"]),
    walletTransaction: json["walletTransaction"],
    stopReason: json["stopReason"],
    tariffClass: json["tariffClass"] == null ? null : TariffClass.fromMap(json["tariffClass"]),
    initialBillingComputationLog: json["initialBillingComputationLog"],
    finalBillingComputationLog: json["finalBillingComputationLog"],
    vehicle: json["vehicle"],
    chargingPower: json["chargingPower"],
    invoice: json["invoice"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "transactionId": transactionId,
    "rfidTag": rfidTag,
    "customer": customer?.toMap(),
    "chargingConnector": chargingConnector?.toMap(),
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime,
    "energyConsumed": energyConsumed,
    "amountConsumed": amountConsumed,
    "status": status,
    "meterStart": meterStart,
    "meterStop": meterStop,
    "chargingStartTime": chargingStartTime?.toIso8601String(),
    "chargingEndTime": chargingEndTime,
    "maxAllowedEnergyInKWh": maxAllowedEnergyInKWh,
    "reservedAmount": reservedAmount,
    "ocppSession": ocppSession?.toMap(),
    "chargingWallet": chargingWallet?.toMap(),
    "walletTransaction": walletTransaction,
    "stopReason": stopReason,
    "tariffClass": tariffClass?.toMap(),
    "initialBillingComputationLog": initialBillingComputationLog,
    "finalBillingComputationLog": finalBillingComputationLog,
    "vehicle": vehicle,
    "chargingPower": chargingPower,
    "invoice": invoice,
  };
}

class Connector {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  int? connectorNumber;
  ChargingConnectorChargingStation? chargingStation;
  String? administrativeStatus;
  String? status;
  DateTime? statusUpdateDate;
  dynamic info;
  String? errorCode;
  ChargingConnectorRequesterData? requesterData;

  Connector({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.connectorNumber,
    this.chargingStation,
    this.administrativeStatus,
    this.status,
    this.statusUpdateDate,
    this.info,
    this.errorCode,
    this.requesterData,
  });

  factory Connector.fromMap(Map<String, dynamic> json) => Connector(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    connectorNumber: json["connectorNumber"],
    chargingStation: json["chargingStation"] == null ? null : ChargingConnectorChargingStation.fromMap(json["chargingStation"]),
    administrativeStatus: json["administrativeStatus"],
    status: json["status"],
    statusUpdateDate: json["statusUpdateDate"] == null ? null : DateTime.parse(json["statusUpdateDate"]),
    info: json["info"],
    errorCode: json["errorCode"],
    requesterData: json["_requesterData"] == null ? null : ChargingConnectorRequesterData.fromMap(json["_requesterData"]),
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "connectorNumber": connectorNumber,
    "chargingStation": chargingStation?.toMap(),
    "administrativeStatus": administrativeStatus,
    "status": status,
    "statusUpdateDate": statusUpdateDate?.toIso8601String(),
    "info": info,
    "errorCode": errorCode,
    "_requesterData": requesterData?.toMap(),
  };
}

class ChargingConnectorChargingStation {
  String? serial;
  String? uuid;
  ChargingStationChargingPark? chargingPark;

  ChargingConnectorChargingStation({
    this.serial,
    this.uuid,
    this.chargingPark,
  });

  factory ChargingConnectorChargingStation.fromMap(Map<String, dynamic> json) => ChargingConnectorChargingStation(
    serial: json["serial"],
    uuid: json["uuid"],
    chargingPark: json["chargingPark"] == null ? null : ChargingStationChargingPark.fromMap(json["chargingPark"]),
  );

  Map<String, dynamic> toMap() => {
    "serial": serial,
    "uuid": uuid,
    "chargingPark": chargingPark?.toMap(),
  };
}

class ChargingStationChargingPark {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? name;
  String? status;
  double? longitude;
  double? latitude;
  String? managerFirstName;
  String? managerLastName;
  String? managerEmail;
  String? managerPhoneNumber;
  String? address;
  CountryClass? country;
  Partner? partner;
  int? chargingStationCount;
  Connectors? connectors;
  dynamic socialData;
  List<CountryClass>? pointsOfInterest;
  List<OpeningHour>? openingHours;
  Logo? picture;
  String? link;
  ChargingParkRequesterData? requesterData;
  dynamic distance;
  dynamic distanceDetails;

  ChargingStationChargingPark({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.name,
    this.status,
    this.longitude,
    this.latitude,
    this.managerFirstName,
    this.managerLastName,
    this.managerEmail,
    this.managerPhoneNumber,
    this.address,
    this.country,
    this.partner,
    this.chargingStationCount,
    this.connectors,
    this.socialData,
    this.pointsOfInterest,
    this.openingHours,
    this.picture,
    this.link,
    this.requesterData,
    this.distance,
    this.distanceDetails,
  });

  factory ChargingStationChargingPark.fromMap(Map<String, dynamic> json) => ChargingStationChargingPark(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    name: json["name"],
    status: json["status"],
    longitude: json["longitude"]?.toDouble(),
    latitude: json["latitude"]?.toDouble(),
    managerFirstName: json["managerFirstName"],
    managerLastName: json["managerLastName"],
    managerEmail: json["managerEmail"],
    managerPhoneNumber: json["managerPhoneNumber"],
    address: json["address"],
    country: json["country"] == null ? null : CountryClass.fromMap(json["country"]),
    partner: json["partner"] == null ? null : Partner.fromMap(json["partner"]),
    chargingStationCount: json["chargingStationCount"],
    connectors: json["connectors"] == null ? null : Connectors.fromMap(json["connectors"]),
    socialData: json["socialData"],
    pointsOfInterest: json["pointsOfInterest"] == null ? [] : List<CountryClass>.from(json["pointsOfInterest"]!.map((x) => CountryClass.fromMap(x))),
    openingHours: json["openingHours"] == null ? [] : List<OpeningHour>.from(json["openingHours"]!.map((x) => OpeningHour.fromMap(x))),
    picture: json["picture"] == null ? null : Logo.fromMap(json["picture"]),
    link: json["link"],
    requesterData: json["_requesterData"] == null ? null : ChargingParkRequesterData.fromMap(json["_requesterData"]),
    distance: json["distance"],
    distanceDetails: json["distanceDetails"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "name": name,
    "status": status,
    "longitude": longitude,
    "latitude": latitude,
    "managerFirstName": managerFirstName,
    "managerLastName": managerLastName,
    "managerEmail": managerEmail,
    "managerPhoneNumber": managerPhoneNumber,
    "address": address,
    "country": country?.toMap(),
    "partner": partner?.toMap(),
    "chargingStationCount": chargingStationCount,
    "connectors": connectors?.toMap(),
    "socialData": socialData,
    "pointsOfInterest": pointsOfInterest == null ? [] : List<dynamic>.from(pointsOfInterest!.map((x) => x.toMap())),
    "openingHours": openingHours == null ? [] : List<dynamic>.from(openingHours!.map((x) => x.toMap())),
    "picture": picture?.toMap(),
    "link": link,
    "_requesterData": requesterData?.toMap(),
    "distance": distance,
    "distanceDetails": distanceDetails,
  };
}

class Connectors {
  int? available;
  int? charging;

  Connectors({
    this.available,
    this.charging,
  });

  factory Connectors.fromMap(Map<String, dynamic> json) => Connectors(
    available: json["available"],
    charging: json["charging"],
  );

  Map<String, dynamic> toMap() => {
    "available": available,
    "charging": charging,
  };
}

class CountryClass {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? label;
  String? value;
  String? status;
  String? category;
  AdditionalInfos? additionalInfos;

  CountryClass({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.label,
    this.value,
    this.status,
    this.category,
    this.additionalInfos,
  });

  factory CountryClass.fromMap(Map<String, dynamic> json) => CountryClass(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    label: json["label"],
    value: json["value"],
    status: json["status"],
    category: json["category"],
    additionalInfos: json["additionalInfos"] == null ? null : AdditionalInfos.fromMap(json["additionalInfos"]),
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "label": label,
    "value": value,
    "status": status,
    "category": category,
    "additionalInfos": additionalInfos?.toMap(),
  };
}

class AdditionalInfos {
  String? flag;
  String? name;
  String? region;
  List<String>? timezones;
  String? alpha2Code;
  String? alpha3Code;
  List<CurrencyElement>? currencies;
  List<String>? callingCodes;
  Translations? translations;
  String? code;
  String? symbol;

  AdditionalInfos({
    this.flag,
    this.name,
    this.region,
    this.timezones,
    this.alpha2Code,
    this.alpha3Code,
    this.currencies,
    this.callingCodes,
    this.translations,
    this.code,
    this.symbol,
  });

  factory AdditionalInfos.fromMap(Map<String, dynamic> json) => AdditionalInfos(
    flag: json["flag"],
    name: json["name"],
    region: json["region"],
    timezones: json["timezones"] == null ? [] : List<String>.from(json["timezones"]!.map((x) => x)),
    alpha2Code: json["alpha2Code"],
    alpha3Code: json["alpha3Code"],
    currencies: json["currencies"] == null ? [] : List<CurrencyElement>.from(json["currencies"]!.map((x) => CurrencyElement.fromMap(x))),
    callingCodes: json["callingCodes"] == null ? [] : List<String>.from(json["callingCodes"]!.map((x) => x)),
    translations: json["translations"] == null ? null : Translations.fromMap(json["translations"]),
    code: json["code"],
    symbol: json["symbol"],
  );

  Map<String, dynamic> toMap() => {
    "flag": flag,
    "name": name,
    "region": region,
    "timezones": timezones == null ? [] : List<dynamic>.from(timezones!.map((x) => x)),
    "alpha2Code": alpha2Code,
    "alpha3Code": alpha3Code,
    "currencies": currencies == null ? [] : List<dynamic>.from(currencies!.map((x) => x.toMap())),
    "callingCodes": callingCodes == null ? [] : List<dynamic>.from(callingCodes!.map((x) => x)),
    "translations": translations?.toMap(),
    "code": code,
    "symbol": symbol,
  };
}

class CurrencyElement {
  String? code;
  String? name;
  String? symbol;

  CurrencyElement({
    this.code,
    this.name,
    this.symbol,
  });

  factory CurrencyElement.fromMap(Map<String, dynamic> json) => CurrencyElement(
    code: json["code"],
    name: json["name"],
    symbol: json["symbol"],
  );

  Map<String, dynamic> toMap() => {
    "code": code,
    "name": name,
    "symbol": symbol,
  };
}

class Translations {
  String? en;
  String? fr;

  Translations({
    this.en,
    this.fr,
  });

  factory Translations.fromMap(Map<String, dynamic> json) => Translations(
    en: json["en"],
    fr: json["fr"],
  );

  Map<String, dynamic> toMap() => {
    "en": en,
    "fr": fr,
  };
}

class OpeningHour {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? label;
  String? openTime;
  String? closeTime;
  OpeningHourChargingPark? chargingPark;

  OpeningHour({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.label,
    this.openTime,
    this.closeTime,
    this.chargingPark,
  });

  factory OpeningHour.fromMap(Map<String, dynamic> json) => OpeningHour(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    label: json["label"],
    openTime: json["openTime"],
    closeTime: json["closeTime"],
    chargingPark: json["chargingPark"] == null ? null : OpeningHourChargingPark.fromMap(json["chargingPark"]),
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "label": label,
    "openTime": openTime,
    "closeTime": closeTime,
    "chargingPark": chargingPark?.toMap(),
  };
}

class OpeningHourChargingPark {
  String? uuid;
  String? name;

  OpeningHourChargingPark({
    this.uuid,
    this.name,
  });

  factory OpeningHourChargingPark.fromMap(Map<String, dynamic> json) => OpeningHourChargingPark(
    uuid: json["uuid"],
    name: json["name"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "name": name,
  };
}

class Partner {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? name;
  String? status;
  String? managerFirstName;
  String? managerLastName;
  String? managerEmail;
  String? managerPhoneNumber;
  String? address;
  CountryClass? country;
  Logo? logo;
  String? code;

  Partner({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.name,
    this.status,
    this.managerFirstName,
    this.managerLastName,
    this.managerEmail,
    this.managerPhoneNumber,
    this.address,
    this.country,
    this.logo,
    this.code,
  });

  factory Partner.fromMap(Map<String, dynamic> json) => Partner(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    name: json["name"],
    status: json["status"],
    managerFirstName: json["managerFirstName"],
    managerLastName: json["managerLastName"],
    managerEmail: json["managerEmail"],
    managerPhoneNumber: json["managerPhoneNumber"],
    address: json["address"],
    country: json["country"] == null ? null : CountryClass.fromMap(json["country"]),
    logo: json["logo"] == null ? null : Logo.fromMap(json["logo"]),
    code: json["code"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "name": name,
    "status": status,
    "managerFirstName": managerFirstName,
    "managerLastName": managerLastName,
    "managerEmail": managerEmail,
    "managerPhoneNumber": managerPhoneNumber,
    "address": address,
    "country": country?.toMap(),
    "logo": logo?.toMap(),
    "code": code,
  };
}

class Logo {
  String? id;
  String? name;
  String? mimeType;
  bool? deleted;

  Logo({
    this.id,
    this.name,
    this.mimeType,
    this.deleted,
  });

  factory Logo.fromMap(Map<String, dynamic> json) => Logo(
    id: json["id"],
    name: json["name"],
    mimeType: json["mimeType"],
    deleted: json["deleted"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "mimeType": mimeType,
    "deleted": deleted,
  };
}

class ChargingParkRequesterData {
  FluffyActions? actions;

  ChargingParkRequesterData({
    this.actions,
  });

  factory ChargingParkRequesterData.fromMap(Map<String, dynamic> json) => ChargingParkRequesterData(
    actions: json["actions"] == null ? null : FluffyActions.fromMap(json["actions"]),
  );

  Map<String, dynamic> toMap() => {
    "actions": actions?.toMap(),
  };
}

class FluffyActions {
  bool? navigate;
  bool? book;
  bool? share;

  FluffyActions({
    this.navigate,
    this.book,
    this.share,
  });

  factory FluffyActions.fromMap(Map<String, dynamic> json) => FluffyActions(
    navigate: json["navigate"],
    book: json["book"],
    share: json["share"],
  );

  Map<String, dynamic> toMap() => {
    "navigate": navigate,
    "book": book,
    "share": share,
  };
}

class ChargingConnectorRequesterData {
  PurpleActions? actions;

  ChargingConnectorRequesterData({
    this.actions,
  });

  factory ChargingConnectorRequesterData.fromMap(Map<String, dynamic> json) => ChargingConnectorRequesterData(
    actions: json["actions"] == null ? null : PurpleActions.fromMap(json["actions"]),
  );

  Map<String, dynamic> toMap() => {
    "actions": actions?.toMap(),
  };
}

class PurpleActions {
  bool? stop;
  bool? start;
  bool? status;

  PurpleActions({
    this.stop,
    this.start,
    this.status,
  });

  factory PurpleActions.fromMap(Map<String, dynamic> json) => PurpleActions(
    stop: json["stop"],
    start: json["start"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "stop": stop,
    "start": start,
    "status": status,
  };
}

class Wallet {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? title;
  String? password;
  double? balance;
  String? status;
  int? loyaltyPoints;
  int? loyaltyBonus;
  ChargingWalletOwner? owner;
  CountryClass? currency;
  int? totalPurchase;
  int? totalExpense;
  LastTransaction? lastTransaction;

  Wallet({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.title,
    this.password,
    this.balance,
    this.status,
    this.loyaltyPoints,
    this.loyaltyBonus,
    this.owner,
    this.currency,
    this.totalPurchase,
    this.totalExpense,
    this.lastTransaction,
  });

  factory Wallet.fromMap(Map<String, dynamic> json) => Wallet(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    title: json["title"],
    password: json["password"],
    balance: json["balance"]?.toDouble(),
    status: json["status"],
    loyaltyPoints: json["loyaltyPoints"],
    loyaltyBonus: json["loyaltyBonus"],
    owner: json["owner"] == null ? null : ChargingWalletOwner.fromMap(json["owner"]),
    currency: json["currency"] == null ? null : CountryClass.fromMap(json["currency"]),
    totalPurchase: json["totalPurchase"],
    totalExpense: json["totalExpense"],
    lastTransaction: json["lastTransaction"] == null ? null : LastTransaction.fromMap(json["lastTransaction"]),
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "title": title,
    "password": password,
    "balance": balance,
    "status": status,
    "loyaltyPoints": loyaltyPoints,
    "loyaltyBonus": loyaltyBonus,
    "owner": owner?.toMap(),
    "currency": currency?.toMap(),
    "totalPurchase": totalPurchase,
    "totalExpense": totalExpense,
    "lastTransaction": lastTransaction?.toMap(),
  };
}

class LastTransaction {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? wallet;
  String? transactionType;
  String? transactionReferenceId;
  String? transactionReferenceType;
  String? transactionReason;
  DateTime? transactionDate;
  String? transactionStatus;
  int? transactionAmount;
  int? transactionFees;

  LastTransaction({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.wallet,
    this.transactionType,
    this.transactionReferenceId,
    this.transactionReferenceType,
    this.transactionReason,
    this.transactionDate,
    this.transactionStatus,
    this.transactionAmount,
    this.transactionFees,
  });

  factory LastTransaction.fromMap(Map<String, dynamic> json) => LastTransaction(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    wallet: json["wallet"],
    transactionType: json["transactionType"],
    transactionReferenceId: json["transactionReferenceId"],
    transactionReferenceType: json["transactionReferenceType"],
    transactionReason: json["transactionReason"],
    transactionDate: json["transactionDate"] == null ? null : DateTime.parse(json["transactionDate"]),
    transactionStatus: json["transactionStatus"],
    transactionAmount: json["transactionAmount"],
    transactionFees: json["transactionFees"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "wallet": wallet,
    "transactionType": transactionType,
    "transactionReferenceId": transactionReferenceId,
    "transactionReferenceType": transactionReferenceType,
    "transactionReason": transactionReason,
    "transactionDate": transactionDate?.toIso8601String(),
    "transactionStatus": transactionStatus,
    "transactionAmount": transactionAmount,
    "transactionFees": transactionFees,
  };
}

class ChargingWalletOwner {
  OwnerOwner? owner;
  String? walletOwnerType;

  ChargingWalletOwner({
    this.owner,
    this.walletOwnerType,
  });

  factory ChargingWalletOwner.fromMap(Map<String, dynamic> json) => ChargingWalletOwner(
    owner: json["owner"] == null ? null : OwnerOwner.fromMap(json["owner"]),
    walletOwnerType: json["walletOwnerType"],
  );

  Map<String, dynamic> toMap() => {
    "owner": owner?.toMap(),
    "walletOwnerType": walletOwnerType,
  };
}

class OwnerOwner {
  String? uuid;
  String? kind;
  String? name;

  OwnerOwner({
    this.uuid,
    this.kind,
    this.name,
  });

  factory OwnerOwner.fromMap(Map<String, dynamic> json) => OwnerOwner(
    uuid: json["uuid"],
    kind: json["kind"],
    name: json["name"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "kind": kind,
    "name": name,
  };
}

class Customer {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? email;
  String? kind;
  String? status;
  String? phoneNumber;
  String? lastName;
  String? firstName;
  String? login;
  DateTime? lastLoginDate;
  DateTime? lastLoginTryDate;
  int? unsuccessfulTriesCount;
  Preferences? preferences;
  String? countryId;
  String? gender;
  String? kycStatus;
  bool? discoverable;
  String? language;
  TariffClass? tariffClass;
  Wallet? wallet;
  String? entireName;

  Customer({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.email,
    this.kind,
    this.status,
    this.phoneNumber,
    this.lastName,
    this.firstName,
    this.login,
    this.lastLoginDate,
    this.lastLoginTryDate,
    this.unsuccessfulTriesCount,
    this.preferences,
    this.countryId,
    this.gender,
    this.kycStatus,
    this.discoverable,
    this.language,
    this.tariffClass,
    this.wallet,
    this.entireName,
  });

  factory Customer.fromMap(Map<String, dynamic> json) => Customer(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    email: json["email"],
    kind: json["kind"],
    status: json["status"],
    phoneNumber: json["phoneNumber"],
    lastName: json["lastName"],
    firstName: json["firstName"],
    login: json["login"],
    lastLoginDate: json["lastLoginDate"] == null ? null : DateTime.parse(json["lastLoginDate"]),
    lastLoginTryDate: json["lastLoginTryDate"] == null ? null : DateTime.parse(json["lastLoginTryDate"]),
    unsuccessfulTriesCount: json["unsuccessfulTriesCount"],
    preferences: json["preferences"] == null ? null : Preferences.fromMap(json["preferences"]),
    countryId: json["countryId"],
    gender: json["gender"],
    kycStatus: json["kycStatus"],
    discoverable: json["discoverable"],
    language: json["language"],
    tariffClass: json["tariffClass"] == null ? null : TariffClass.fromMap(json["tariffClass"]),
    wallet: json["wallet"] == null ? null : Wallet.fromMap(json["wallet"]),
    entireName: json["entireName"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "email": email,
    "kind": kind,
    "status": status,
    "phoneNumber": phoneNumber,
    "lastName": lastName,
    "firstName": firstName,
    "login": login,
    "lastLoginDate": lastLoginDate?.toIso8601String(),
    "lastLoginTryDate": lastLoginTryDate?.toIso8601String(),
    "unsuccessfulTriesCount": unsuccessfulTriesCount,
    "preferences": preferences?.toMap(),
    "countryId": countryId,
    "gender": gender,
    "kycStatus": kycStatus,
    "discoverable": discoverable,
    "language": language,
    "tariffClass": tariffClass?.toMap(),
    "wallet": wallet?.toMap(),
    "entireName": entireName,
  };
}

class Preferences {
  bool? multiFactorAuthentication;
  String? theme;
  dynamic profilePicture;
  Misc? misc;

  Preferences({
    this.multiFactorAuthentication,
    this.theme,
    this.profilePicture,
    this.misc,
  });

  factory Preferences.fromMap(Map<String, dynamic> json) => Preferences(
    multiFactorAuthentication: json["multiFactorAuthentication"],
    theme: json["theme"],
    profilePicture: json["profilePicture"],
    misc: json["misc"] == null ? null : Misc.fromMap(json["misc"]),
  );

  Map<String, dynamic> toMap() => {
    "multiFactorAuthentication": multiFactorAuthentication,
    "theme": theme,
    "profilePicture": profilePicture,
    "misc": misc?.toMap(),
  };
}

class Misc {
  Misc();

  factory Misc.fromMap(Map<String, dynamic> json) => Misc(
  );

  Map<String, dynamic> toMap() => {
  };
}

class TariffClass {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  TimePeriodClass? timePeriodClass;
  Partner? partner;
  String? name;
  int? licenceFees;
  int? fixedFees;
  String? tariffLevelMode;
  String? tariffStackMode;
  int? threshold;
  int? aboveThresholdItemCost;
  int? aboveThresholdServiceCost;
  int? countOfTariff;

  TariffClass({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.timePeriodClass,
    this.partner,
    this.name,
    this.licenceFees,
    this.fixedFees,
    this.tariffLevelMode,
    this.tariffStackMode,
    this.threshold,
    this.aboveThresholdItemCost,
    this.aboveThresholdServiceCost,
    this.countOfTariff,
  });

  factory TariffClass.fromMap(Map<String, dynamic> json) => TariffClass(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    timePeriodClass: json["timePeriodClass"] == null ? null : TimePeriodClass.fromMap(json["timePeriodClass"]),
    partner: json["partner"] == null ? null : Partner.fromMap(json["partner"]),
    name: json["name"],
    licenceFees: json["licenceFees"],
    fixedFees: json["fixedFees"],
    tariffLevelMode: json["tariffLevelMode"],
    tariffStackMode: json["tariffStackMode"],
    threshold: json["threshold"],
    aboveThresholdItemCost: json["aboveThresholdItemCost"],
    aboveThresholdServiceCost: json["aboveThresholdServiceCost"],
    countOfTariff: json["countOfTariff"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "timePeriodClass": timePeriodClass?.toMap(),
    "partner": partner?.toMap(),
    "name": name,
    "licenceFees": licenceFees,
    "fixedFees": fixedFees,
    "tariffLevelMode": tariffLevelMode,
    "tariffStackMode": tariffStackMode,
    "threshold": threshold,
    "aboveThresholdItemCost": aboveThresholdItemCost,
    "aboveThresholdServiceCost": aboveThresholdServiceCost,
    "countOfTariff": countOfTariff,
  };
}

class TimePeriodClass {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  Partner? partner;
  String? timePeriodClassName;
  String? defaultTimePeriodName;
  List<String>? labels;

  TimePeriodClass({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.partner,
    this.timePeriodClassName,
    this.defaultTimePeriodName,
    this.labels,
  });

  factory TimePeriodClass.fromMap(Map<String, dynamic> json) => TimePeriodClass(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    partner: json["partner"] == null ? null : Partner.fromMap(json["partner"]),
    timePeriodClassName: json["timePeriodClassName"],
    defaultTimePeriodName: json["defaultTimePeriodName"],
    labels: json["labels"] == null ? [] : List<String>.from(json["labels"]!.map((x) => x)),
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "partner": partner?.toMap(),
    "timePeriodClassName": timePeriodClassName,
    "defaultTimePeriodName": defaultTimePeriodName,
    "labels": labels == null ? [] : List<dynamic>.from(labels!.map((x) => x)),
  };
}

class OcppSession {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? identifier;
  String? hostIpAddress;
  int? port;
  String? soapToUrl;
  String? proxiedAddress;
  OcppSessionChargingStation? chargingStation;
  DateTime? startTime;
  dynamic endTime;
  String? status;

  OcppSession({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.identifier,
    this.hostIpAddress,
    this.port,
    this.soapToUrl,
    this.proxiedAddress,
    this.chargingStation,
    this.startTime,
    this.endTime,
    this.status,
  });

  factory OcppSession.fromMap(Map<String, dynamic> json) => OcppSession(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    identifier: json["identifier"],
    hostIpAddress: json["hostIpAddress"],
    port: json["port"],
    soapToUrl: json["soapToURL"],
    proxiedAddress: json["proxiedAddress"],
    chargingStation: json["chargingStation"] == null ? null : OcppSessionChargingStation.fromMap(json["chargingStation"]),
    startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
    endTime: json["endTime"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "identifier": identifier,
    "hostIpAddress": hostIpAddress,
    "port": port,
    "soapToURL": soapToUrl,
    "proxiedAddress": proxiedAddress,
    "chargingStation": chargingStation?.toMap(),
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime,
    "status": status,
  };
}

class OcppSessionChargingStation {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  dynamic idChargingStation;
  String? identifier;
  String? status;
  String? kind;
  String? type;
  String? serial;
  dynamic longitude;
  dynamic latitude;
  ChargingStationChargingPark? chargingPark;
  int? powerInKw;
  Partner? provider;
  String? networkStatus;
  String? vendor;
  String? model;
  String? firmwareVersion;
  dynamic meterSerialNumber;
  dynamic meterType;
  String? networkAddress;
  DateTime? lastOnlineDate;
  dynamic simCard;
  List<Connector>? connectors;
  Connectors? connectorsStatuses;
  dynamic socialData;
  int? temperature;
  TariffClass? tariffClass;
  dynamic picture;

  OcppSessionChargingStation({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
    this.idChargingStation,
    this.identifier,
    this.status,
    this.kind,
    this.type,
    this.serial,
    this.longitude,
    this.latitude,
    this.chargingPark,
    this.powerInKw,
    this.provider,
    this.networkStatus,
    this.vendor,
    this.model,
    this.firmwareVersion,
    this.meterSerialNumber,
    this.meterType,
    this.networkAddress,
    this.lastOnlineDate,
    this.simCard,
    this.connectors,
    this.connectorsStatuses,
    this.socialData,
    this.temperature,
    this.tariffClass,
    this.picture,
  });

  factory OcppSessionChargingStation.fromMap(Map<String, dynamic> json) => OcppSessionChargingStation(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    idChargingStation: json["idChargingStation"],
    identifier: json["identifier"],
    status: json["status"],
    kind: json["kind"],
    type: json["type"],
    serial: json["serial"],
    longitude: json["longitude"],
    latitude: json["latitude"],
    chargingPark: json["chargingPark"] == null ? null : ChargingStationChargingPark.fromMap(json["chargingPark"]),
    powerInKw: json["powerInKw"],
    provider: json["provider"] == null ? null : Partner.fromMap(json["provider"]),
    networkStatus: json["networkStatus"],
    vendor: json["vendor"],
    model: json["model"],
    firmwareVersion: json["firmwareVersion"],
    meterSerialNumber: json["meterSerialNumber"],
    meterType: json["meterType"],
    networkAddress: json["networkAddress"],
    lastOnlineDate: json["lastOnlineDate"] == null ? null : DateTime.parse(json["lastOnlineDate"]),
    simCard: json["simCard"],
    connectors: json["connectors"] == null ? [] : List<Connector>.from(json["connectors"]!.map((x) => Connector.fromMap(x))),
    connectorsStatuses: json["connectorsStatuses"] == null ? null : Connectors.fromMap(json["connectorsStatuses"]),
    socialData: json["socialData"],
    temperature: json["temperature"],
    tariffClass: json["tariffClass"] == null ? null : TariffClass.fromMap(json["tariffClass"]),
    picture: json["picture"],
  );

  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
    "idChargingStation": idChargingStation,
    "identifier": identifier,
    "status": status,
    "kind": kind,
    "type": type,
    "serial": serial,
    "longitude": longitude,
    "latitude": latitude,
    "chargingPark": chargingPark?.toMap(),
    "powerInKw": powerInKw,
    "provider": provider?.toMap(),
    "networkStatus": networkStatus,
    "vendor": vendor,
    "model": model,
    "firmwareVersion": firmwareVersion,
    "meterSerialNumber": meterSerialNumber,
    "meterType": meterType,
    "networkAddress": networkAddress,
    "lastOnlineDate": lastOnlineDate?.toIso8601String(),
    "simCard": simCard,
    "connectors": connectors == null ? [] : List<dynamic>.from(connectors!.map((x) => x.toMap())),
    "connectorsStatuses": connectorsStatuses?.toMap(),
    "socialData": socialData,
    "temperature": temperature,
    "tariffClass": tariffClass?.toMap(),
    "picture": picture,
  };
}
