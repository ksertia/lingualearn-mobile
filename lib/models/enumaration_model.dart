import 'dart:convert';

EnumerationsModel enumerationsModelFromJson(String str) =>
    EnumerationsModel.fromJson(json.decode(str));

String enumerationsModelToJson(EnumerationsModel data) =>
    json.encode(data.toJson());

class EnumerationsModel {
  String? returnStatus;
  String? returnDetail;
  EnumData? data;

  EnumerationsModel({
    this.returnStatus,
    this.returnDetail,
    this.data,
  });

  factory EnumerationsModel.fromJson(Map<String, dynamic> json) =>
      EnumerationsModel(
        returnStatus: json["returnStatus"],
        returnDetail: json["returnDetail"],
        data: json["data"] == null ? null : EnumData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "returnStatus": returnStatus,
        "returnDetail": returnDetail,
        "data": data?.toJson(),
      };
}

class EnumData {
  Languages? language;
  Enumerations? enumerations;

  EnumData({
    this.language,
    this.enumerations,
  });

  factory EnumData.fromJson(Map<String, dynamic> json) => EnumData(
        language: json["language"] == null
            ? null
            : Languages.fromJson(json["language"]),
        enumerations: json["enumerations"] == null
            ? null
            : Enumerations.fromJson(json["enumerations"]),
      );

  Map<String, dynamic> toJson() => {
        "language": language?.toJson(),
        "enumerations": enumerations?.toJson(),
      };
}

class Enumerations {
  List<ContributionVisibility>? gender;
  List<ChargingParkStatus>? rfidTagStatus;
  List<ContributionVisibility>? withdrawRequestApprovalKind;
  List<ContributionVisibility>? poolKind;
  List<Country>? country;
  List<ContributionVisibility>? poolRecurrence;
  List<ContributionVisibility>? userAccountStatus;
  List<ContributionVisibility>? contributionVisibility;
  List<ContributionVisibility>? kycStatus;
  List<ContributionVisibility>? walletTransactionStatus;
  List<ContributionVisibility>? walletStatus;
  List<dynamic>? cpoTag;
  List<ContributionVisibility>? identityProofKind;
  List<CurrencyModel>? currency;
  List<ContributionVisibility>? walletOwnerType;
  List<ContributionVisibility>? walletTransactionType;
  List<ContributionVisibility>? membershipStatus;
  List<ContributionVisibility>? walletPaymentMethodType;
  List<ContributionVisibility>? poolStatus;
  List<dynamic>? tooltip;
  List<ContributionVisibility>? poolVisibility;
  List<ContributionVisibility>? withdrawStatus;
  List<ContributionVisibility>? membershipKind;
  List<ContributionVisibility>? tokenStatus;
  List<ContributionVisibility>? userAccountKind;
  List<Config>? config;
  List<dynamic>? typePerteExploitation;
  List<Config>? vehicleModel;
  List<Config>? vehicleBrand;


  Enumerations({
    this.gender,
    this.country,
    this.rfidTagStatus,
    this.poolRecurrence,
    this.userAccountStatus,
    this.contributionVisibility,
    this.kycStatus,
    this.walletTransactionStatus,
    this.walletStatus,
    this.cpoTag,
    this.identityProofKind,
    this.currency,
    this.walletOwnerType,
    this.walletTransactionType,
    this.membershipStatus,
    this.walletPaymentMethodType,
    this.poolStatus,
    this.tooltip,
    this.poolVisibility,
    this.poolKind,
    this.withdrawStatus,
    this.membershipKind,
    this.withdrawRequestApprovalKind,
    this.tokenStatus,
    this.userAccountKind,
    this.config,
    this.typePerteExploitation,
    this.vehicleModel,
    this.vehicleBrand,
  });

  factory Enumerations.fromJson(Map<String, dynamic> json) => Enumerations(
        gender: json["GENDER"] == null
            ? []
            : List<ContributionVisibility>.from(
                json["GENDER"]!.map((x) => ContributionVisibility.fromJson(x))),
        country: json["COUNTRY"] == null
            ? []
            : List<Country>.from(
                json["COUNTRY"]!.map((x) => Country.fromJson(x))),
    rfidTagStatus: json["RFID_TAG_STATUS"] == null ? [] : List<ChargingParkStatus>.from(json["RFID_TAG_STATUS"]!.map((x) => ChargingParkStatus.fromMap(x))),
    poolRecurrence: json["POOL_RECURRENCE"] == null
            ? []
            : List<ContributionVisibility>.from(json["POOL_RECURRENCE"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        userAccountStatus: json["USER_ACCOUNT_STATUS"] == null
            ? []
            : List<ContributionVisibility>.from(json["USER_ACCOUNT_STATUS"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        contributionVisibility: json["CONTRIBUTION_VISIBILITY"] == null
            ? []
            : List<ContributionVisibility>.from(json["CONTRIBUTION_VISIBILITY"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        kycStatus: json["KYC_STATUS"] == null
            ? []
            : List<ContributionVisibility>.from(json["KYC_STATUS"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        walletTransactionStatus: json["WALLET_TRANSACTION_STATUS"] == null
            ? []
            : List<ContributionVisibility>.from(
                json["WALLET_TRANSACTION_STATUS"]!
                    .map((x) => ContributionVisibility.fromJson(x))),
        walletStatus: json["WALLET_STATUS"] == null
            ? []
            : List<ContributionVisibility>.from(json["WALLET_STATUS"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        cpoTag: json["CPO_TAG"] == null
            ? []
            : List<dynamic>.from(json["CPO_TAG"]!.map((x) => x)),
        identityProofKind: json["IDENTITY_PROOF_KIND"] == null
            ? []
            : List<ContributionVisibility>.from(json["IDENTITY_PROOF_KIND"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        currency: json["CURRENCY"] == null
            ? []
            : List<CurrencyModel>.from(
                json["CURRENCY"]!.map((x) => CurrencyModel.fromJson(x))),
        walletOwnerType: json["WALLET_OWNER_TYPE"] == null
            ? []
            : List<ContributionVisibility>.from(json["WALLET_OWNER_TYPE"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        walletTransactionType: json["WALLET_TRANSACTION_TYPE"] == null
            ? []
            : List<ContributionVisibility>.from(json["WALLET_TRANSACTION_TYPE"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        membershipStatus: json["MEMBERSHIP_STATUS"] == null
            ? []
            : List<ContributionVisibility>.from(json["MEMBERSHIP_STATUS"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        walletPaymentMethodType: json["WALLET_PAYMENT_METHOD_TYPE"] == null
            ? []
            : List<ContributionVisibility>.from(
                json["WALLET_PAYMENT_METHOD_TYPE"]!
                    .map((x) => ContributionVisibility.fromJson(x))),
        poolStatus: json["POOL_STATUS"] == null
            ? []
            : List<ContributionVisibility>.from(json["POOL_STATUS"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        tooltip: json["TOOLTIP"] == null
            ? []
            : List<dynamic>.from(json["TOOLTIP"]!.map((x) => x)),
        poolVisibility: json["POOL_VISIBILITY"] == null
            ? []
            : List<ContributionVisibility>.from(json["POOL_VISIBILITY"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        withdrawStatus: json["WITHDRAW_STATUS"] == null
            ? []
            : List<ContributionVisibility>.from(json["WITHDRAW_STATUS"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        membershipKind: json["MEMBERSHIP_KIND"] == null
            ? []
            : List<ContributionVisibility>.from(json["MEMBERSHIP_KIND"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        tokenStatus: json["TOKEN_STATUS"] == null
            ? []
            : List<ContributionVisibility>.from(json["TOKEN_STATUS"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        userAccountKind: json["USER_ACCOUNT_KIND"] == null
            ? []
            : List<ContributionVisibility>.from(json["USER_ACCOUNT_KIND"]!
                .map((x) => ContributionVisibility.fromJson(x))),
        config: json["CONFIG"] == null
            ? []
            : List<Config>.from(json["CONFIG"]!.map((x) => Config.fromMap(x))),
        typePerteExploitation: json["TYPE_PERTE_EXPLOITATION"] == null
            ? []
            : List<dynamic>.from(
                json["TYPE_PERTE_EXPLOITATION"]!.map((x) => x)),
        withdrawRequestApprovalKind:
            json["WITHDRAW_REQUEST_APPROVAL_KIND"] == null
                ? []
                : List<ContributionVisibility>.from(
                    json["WITHDRAW_REQUEST_APPROVAL_KIND"]!
                        .map((x) => ContributionVisibility.fromJson(x))),
        poolKind: json["POOL_KIND"] == null
            ? []
            : List<ContributionVisibility>.from(json["POOL_KIND"]!
                .map((x) => ContributionVisibility.fromJson(x))),
    vehicleModel: json["VEHICLE_MODEL"] == null ? [] : List<Config>.from(json["VEHICLE_MODEL"]!.map((x) => Config.fromMap(x))),
    vehicleBrand: json["VEHICLE_BRAND"] == null ? [] : List<Config>.from(json["VEHICLE_BRAND"]!.map((x) => Config.fromMap(x))),

  );

  Map<String, dynamic> toJson() => {
        "GENDER": gender == null
            ? []
            : List<dynamic>.from(gender!.map((x) => x.toJson())),
        "COUNTRY": country == null
            ? []
            : List<dynamic>.from(country!.map((x) => x.toJson())),
    "RFID_TAG_STATUS": rfidTagStatus == null ? [] : List<dynamic>.from(rfidTagStatus!.map((x) => x.toMap())),
    "POOL_RECURRENCE": poolRecurrence == null
            ? []
            : List<dynamic>.from(poolRecurrence!.map((x) => x.toJson())),
        "USER_ACCOUNT_STATUS": userAccountStatus == null
            ? []
            : List<dynamic>.from(userAccountStatus!.map((x) => x.toJson())),
        "CONTRIBUTION_VISIBILITY": contributionVisibility == null
            ? []
            : List<dynamic>.from(
                contributionVisibility!.map((x) => x.toJson())),
        "KYC_STATUS": kycStatus == null
            ? []
            : List<dynamic>.from(kycStatus!.map((x) => x.toJson())),
        "WALLET_TRANSACTION_STATUS": walletTransactionStatus == null
            ? []
            : List<dynamic>.from(
                walletTransactionStatus!.map((x) => x.toJson())),
        "WALLET_STATUS": walletStatus == null
            ? []
            : List<dynamic>.from(walletStatus!.map((x) => x.toJson())),
        "CPO_TAG":
            cpoTag == null ? [] : List<dynamic>.from(cpoTag!.map((x) => x)),
        "IDENTITY_PROOF_KIND": identityProofKind == null
            ? []
            : List<dynamic>.from(identityProofKind!.map((x) => x.toJson())),
        "CURRENCY": currency == null
            ? []
            : List<dynamic>.from(currency!.map((x) => x.toJson())),
        "WALLET_OWNER_TYPE": walletOwnerType == null
            ? []
            : List<dynamic>.from(walletOwnerType!.map((x) => x.toJson())),
        "WALLET_TRANSACTION_TYPE": walletTransactionType == null
            ? []
            : List<dynamic>.from(walletTransactionType!.map((x) => x.toJson())),
        "MEMBERSHIP_STATUS": membershipStatus == null
            ? []
            : List<dynamic>.from(membershipStatus!.map((x) => x.toJson())),
        "WALLET_PAYMENT_METHOD_TYPE": walletPaymentMethodType == null
            ? []
            : List<dynamic>.from(
                walletPaymentMethodType!.map((x) => x.toJson())),
        "POOL_STATUS": poolStatus == null
            ? []
            : List<dynamic>.from(poolStatus!.map((x) => x.toJson())),
        "TOOLTIP":
            tooltip == null ? [] : List<dynamic>.from(tooltip!.map((x) => x)),
        "POOL_VISIBILITY": poolVisibility == null
            ? []
            : List<dynamic>.from(poolVisibility!.map((x) => x.toJson())),
        "WITHDRAW_STATUS": withdrawStatus == null
            ? []
            : List<dynamic>.from(withdrawStatus!.map((x) => x.toJson())),
        "MEMBERSHIP_KIND": membershipKind == null
            ? []
            : List<dynamic>.from(membershipKind!.map((x) => x.toJson())),
        "TOKEN_STATUS": tokenStatus == null
            ? []
            : List<dynamic>.from(tokenStatus!.map((x) => x.toJson())),
        "USER_ACCOUNT_KIND": userAccountKind == null
            ? []
            : List<dynamic>.from(userAccountKind!.map((x) => x.toJson())),
        "CONFIG": config == null
            ? []
            : List<dynamic>.from(config!.map((x) => x.toMap())),
        "TYPE_PERTE_EXPLOITATION": typePerteExploitation == null
            ? []
            : List<dynamic>.from(typePerteExploitation!.map((x) => x)),
        "WITHDRAW_REQUEST_APPROVAL_KIND": withdrawRequestApprovalKind == null
            ? []
            : List<dynamic>.from(
                withdrawRequestApprovalKind!.map((x) => x.toJson())),
        "POOL_KIND": poolKind == null
            ? []
            : List<dynamic>.from(poolKind!.map((x) => x.toJson())),
    "VEHICLE_MODEL": vehicleModel == null ? [] : List<dynamic>.from(vehicleModel!.map((x) => x.toMap())),
    "VEHICLE_BRAND": vehicleBrand == null ? [] : List<dynamic>.from(vehicleBrand!.map((x) => x.toMap())),

  };
}

class ChargingParkStatus {
  String? label;
  String? value;
  String? text;

  ChargingParkStatus({
    this.label,
    this.value,
    this.text,
  });

  factory ChargingParkStatus.fromMap(Map<String, dynamic> json) => ChargingParkStatus(
    label: json["label"],
    value: json["value"],
    text: json["text"],
  );

  Map<String, dynamic> toMap() => {
    "label": label,
    "value": value,
    "text": text,
  };
}

class Config {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? label;
  String? value;
  String? status;
  String? category;
  ConfigAdditionalInfos? additionalInfos;
  List<Config>? children;

  Config({
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
    this.children,
  });

  factory Config.fromMap(Map<String, dynamic> json) => Config(
    uuid: json["uuid"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
    comment: json["comment"],
    version: json["version"],
    label: json["label"],
    value: json["value"],
    status: json["status"],
    category: json["category"],
    additionalInfos: json["additionalInfos"] == null ? null : ConfigAdditionalInfos.fromJson(json["additionalInfos"]),
    children: json["children"] == null ? [] : List<Config>.from(json["children"]!.map((x) => Config.fromMap(x))),
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
    "additionalInfos": additionalInfos?.toJson(),
    "children": children == null ? [] : List<dynamic>.from(children!.map((x) => x.toMap())),
  };
}

class ConfigAdditionalInfos {
  ConfigAdditionalInfos();

  factory ConfigAdditionalInfos.fromJson(Map<String, dynamic> json) =>
      ConfigAdditionalInfos();

  Map<String, dynamic> toJson() => {};
}

class ContributionVisibility {
  String? label;
  String? value;
  String? text;
  bool isSelected;

  ContributionVisibility(
      {this.label, this.value, this.text, this.isSelected = false});

  factory ContributionVisibility.fromJson(Map<String, dynamic> json) =>
      ContributionVisibility(
        label: json["label"],
        value: json["value"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "value": value,
        "text": text,
      };
}

class Country {
  String? uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String? comment;
  int? version;
  String? label;
  String? value;
  String? status;
  String? category;
  CountryAdditionalInfos? additionalInfos;
  List<dynamic>? children;

  Country({
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
    this.children,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        uuid: json["uuid"],
        creationDate: json["creationDate"] == null
            ? null
            : DateTime.parse(json["creationDate"]),
        lastModifiedDate: json["lastModifiedDate"] == null
            ? null
            : DateTime.parse(json["lastModifiedDate"]),
        comment: json["comment"],
        version: json["version"],
        label: json["label"],
        value: json["value"],
        status: json["status"],
        category: json["category"],
        additionalInfos: json["additionalInfos"] == null
            ? null
            : CountryAdditionalInfos.fromJson(json["additionalInfos"]),
        children: json["children"] == null
            ? []
            : List<dynamic>.from(json["children"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "creationDate": creationDate?.toIso8601String(),
        "lastModifiedDate": lastModifiedDate?.toIso8601String(),
        "comment": comment,
        "version": version,
        "label": label,
        "value": value,
        "status": status,
        "category": category,
        "additionalInfos": additionalInfos?.toJson(),
        "children":
            children == null ? [] : List<dynamic>.from(children!.map((x) => x)),
      };
}

class CountryAdditionalInfos {
  String? flag;
  String? name;
  String? region;
  List<String>? timezones;
  String? alpha2Code;
  String? alpha3Code;
  List<AdditionalInfos>? currencies;
  List<String>? callingCodes;
  Translations? translations;

  CountryAdditionalInfos({
    this.flag,
    this.name,
    this.region,
    this.timezones,
    this.alpha2Code,
    this.alpha3Code,
    this.currencies,
    this.callingCodes,
    this.translations,
  });

  factory CountryAdditionalInfos.fromJson(Map<String, dynamic> json) =>
      CountryAdditionalInfos(
        flag: json["flag"],
        name: json["name"],
        region: json["region"],
        timezones: json["timezones"] == null
            ? []
            : List<String>.from(json["timezones"]!.map((x) => x)),
        alpha2Code: json["alpha2Code"],
        alpha3Code: json["alpha3Code"],
        currencies: json["currencies"] == null
            ? []
            : List<AdditionalInfos>.from(
                json["currencies"]!.map((x) => AdditionalInfos.fromJson(x))),
        callingCodes: json["callingCodes"] == null
            ? []
            : List<String>.from(json["callingCodes"]!.map((x) => x)),
        translations: json["translations"] == null
            ? null
            : Translations.fromJson(json["translations"]),
      );

  Map<String, dynamic> toJson() => {
        "flag": flag,
        "name": name,
        "region": region,
        "timezones": timezones == null
            ? []
            : List<dynamic>.from(timezones!.map((x) => x)),
        "alpha2Code": alpha2Code,
        "alpha3Code": alpha3Code,
        "currencies": currencies == null
            ? []
            : List<dynamic>.from(currencies!.map((x) => x.toJson())),
        "callingCodes": callingCodes == null
            ? []
            : List<dynamic>.from(callingCodes!.map((x) => x)),
        "translations": translations?.toJson(),
      };
}

class AdditionalInfos {
  String? flag;
  String? code;
  String? name;
  String? symbol;

  AdditionalInfos({
    this.flag,
    this.code,
    this.name,
    this.symbol,
  });

  factory AdditionalInfos.fromJson(Map<String, dynamic> json) =>
      AdditionalInfos(
        flag: json["flag"],
        code: json["code"],
        name: json["name"],
        symbol: json["symbol"],
      );

  Map<String, dynamic> toJson() => {
        "flag": flag,
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

  factory Translations.fromJson(Map<String, dynamic> json) => Translations(
        en: json["en"],
        fr: json["fr"],
      );

  Map<String, dynamic> toJson() => {
        "en": en,
        "fr": fr,
      };
}

class CurrencyModel {
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
  List<Country>? children;

  CurrencyModel({
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
    this.children,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) => CurrencyModel(
        uuid: json["uuid"],
        creationDate: json["creationDate"] == null
            ? null
            : DateTime.parse(json["creationDate"]),
        lastModifiedDate: json["lastModifiedDate"] == null
            ? null
            : DateTime.parse(json["lastModifiedDate"]),
        comment: json["comment"],
        version: json["version"],
        label: json["label"],
        value: json["value"],
        status: json["status"],
        category: json["category"],
        additionalInfos: json["additionalInfos"] == null
            ? null
            : AdditionalInfos.fromJson(json["additionalInfos"]),
        children: json["children"] == null
            ? []
            : List<Country>.from(
                json["children"]!.map((x) => Country.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "creationDate": creationDate?.toIso8601String(),
        "lastModifiedDate": lastModifiedDate?.toIso8601String(),
        "comment": comment,
        "version": version,
        "label": label,
        "value": value,
        "status": status,
        "category": category,
        "additionalInfos": additionalInfos?.toJson(),
        "children": children == null
            ? []
            : List<dynamic>.from(children!.map((x) => x.toJson())),
      };
}

class Languages {
  String? label;
  String? value;

  Languages({
    this.label,
    this.value,
  });

  factory Languages.fromJson(Map<String, dynamic> json) => Languages(
        label: json["label"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "value": value,
      };
}
