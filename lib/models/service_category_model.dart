// To parse this JSON data, do
//
//     final categoriesModel = categoriesModelFromJson(jsonString);

import 'dart:convert';

CategoriesModel categoriesModelFromJson(String str) =>
    CategoriesModel.fromJson(json.decode(str));

String categoriesModelToJson(CategoriesModel data) =>
    json.encode(data.toJson());

class CategoriesModel {
  final bool? success;
  final int? code;
  final String? message;
  final Data? data;
  final List<dynamic>? payload;

  CategoriesModel({
    this.success,
    this.code,
    this.message,
    this.data,
    this.payload,
  });

  factory CategoriesModel.fromJson(Map<String, dynamic> json) =>
      CategoriesModel(
        success: _readBool(json["success"]),
        code: _readInt(json["code"]),
        message: json["message"]?.toString(),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        payload: json["payload"] == null
            ? []
            : List<dynamic>.from(json["payload"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "message": message,
    "data": data?.toJson(),
    "payload": payload == null
        ? []
        : List<dynamic>.from(payload!.map((x) => x)),
  };
}

class Data {
  final List<Servicecategory>? servicecategories;

  Data({this.servicecategories});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    servicecategories: json["servicecategories"] == null
        ? []
        : List<Servicecategory>.from(
            json["servicecategories"]!.map((x) => Servicecategory.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "servicecategories": servicecategories == null
        ? []
        : List<dynamic>.from(servicecategories!.map((x) => x.toJson())),
  };
}

class Servicecategory {
  final int? id;
  final String? categoryName;
  final String? type;
  final bool? requiresCountrySelection;
  final dynamic serviceCategorySubTypeId;
  final String? categoryImageUrl;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic inputFormSchema;
  final dynamic performedBy;
  final String? displayOrder;
  final List<Service>? services;

  Servicecategory({
    this.id,
    this.categoryName,
    this.type,
    this.requiresCountrySelection,
    this.serviceCategorySubTypeId,
    this.categoryImageUrl,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.inputFormSchema,
    this.performedBy,
    this.displayOrder,
    this.services,
  });

  factory Servicecategory.fromJson(Map<String, dynamic> json) =>
      Servicecategory(
        id: _readInt(json["id"]),
        categoryName: json["category_name"]?.toString(),
        type: json["type"]?.toString(),
        requiresCountrySelection: _readBool(json["requires_country_selection"]),
        serviceCategorySubTypeId: json["service_category_sub_type_id"],
        categoryImageUrl: json["category_image_url"]?.toString(),
        deletedAt: json["deleted_at"],
        createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
        updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
        inputFormSchema: json["input_form_schema"],
        performedBy: json["performed_by"],
        displayOrder: json["display_order"]?.toString(),
        services: json["services"] == null
            ? []
            : List<Service>.from(
                json["services"]!.map((x) => Service.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_name": categoryName,
    "type": type,
    "requires_country_selection": requiresCountrySelection,
    "service_category_sub_type_id": serviceCategorySubTypeId,
    "category_image_url": categoryImageUrl,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "input_form_schema": inputFormSchema,
    "performed_by": performedBy,
    "display_order": displayOrder,
    "services": services == null
        ? []
        : List<dynamic>.from(services!.map((x) => x.toJson())),
  };
}

class Service {
  final int? id;
  final String? serviceCategoryId;
  final String? companyId;
  final String? telegramChatId;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic inputFormSchema;
  final dynamic performedBy;
  final bool? isRobotEnabled;
  final bool? isApiEnabled;
  final String? apiProviderId;
  final int? displayOrder;
  final Company? company;

  Service({
    this.id,
    this.serviceCategoryId,
    this.companyId,
    this.telegramChatId,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.inputFormSchema,
    this.performedBy,
    this.isRobotEnabled,
    this.isApiEnabled,
    this.apiProviderId,
    this.displayOrder,
    this.company,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: _readInt(json["id"]),
    serviceCategoryId: json["service_category_id"]?.toString(),
    companyId: json["company_id"]?.toString(),
    telegramChatId: json["telegram_chat_id"]?.toString(),
    deletedAt: json["deleted_at"],
    createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
    updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
    inputFormSchema: json["input_form_schema"],
    performedBy: json["performed_by"],
    isRobotEnabled: _readBool(json["is_robot_enabled"]),
    isApiEnabled: _readBool(json["is_api_enabled"]),
    apiProviderId: json["api_provider_id"]?.toString(),
    displayOrder: _readInt(json["display_order"]),
    company: json["company"] == null ? null : Company.fromJson(json["company"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "service_category_id": serviceCategoryId,
    "company_id": companyId,
    "telegram_chat_id": telegramChatId,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "input_form_schema": inputFormSchema,
    "performed_by": performedBy,
    "is_robot_enabled": isRobotEnabled,
    "is_api_enabled": isApiEnabled,
    "api_provider_id": apiProviderId,
    "display_order": displayOrder,
    "company": company?.toJson(),
  };
}

class Company {
  final int? id;
  final String? companyName;
  final String? companyCode;
  final String? companyLogo;
  final String? countryId;
  final String? telegramChatId;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic inputFormSchema;
  final dynamic performedBy;
  final bool? isRobotEnabled;
  final bool? isApiEnabled;
  final dynamic apiProviderId;
  final int? displayOrder;
  final Country? country;
  final List<Companycode>? companycodes;

  Company({
    this.id,
    this.companyName,
    this.companyCode,
    this.companyLogo,
    this.countryId,
    this.telegramChatId,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.inputFormSchema,
    this.performedBy,
    this.isRobotEnabled,
    this.isApiEnabled,
    this.apiProviderId,
    this.displayOrder,
    this.country,
    this.companycodes,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: _readInt(json["id"]),
    companyName: json["company_name"]?.toString(),
    companyCode: json["company_code"]?.toString(),
    companyLogo: json["company_logo"]?.toString(),
    countryId: json["country_id"]?.toString(),
    telegramChatId: json["telegram_chat_id"]?.toString(),
    deletedAt: json["deleted_at"],
    createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
    updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
    inputFormSchema: json["input_form_schema"],
    performedBy: json["performed_by"],
    isRobotEnabled: _readBool(json["is_robot_enabled"]),
    isApiEnabled: _readBool(json["is_api_enabled"]),
    apiProviderId: json["api_provider_id"],
    displayOrder: _readInt(json["display_order"]),
    country: json["country"] == null ? null : Country.fromJson(json["country"]),
    companycodes: json["companycodes"] == null
        ? []
        : List<Companycode>.from(
            json["companycodes"]!.map((x) => Companycode.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company_name": companyName,
    "company_code": companyCode,
    "company_logo": companyLogo,
    "country_id": countryId,
    "telegram_chat_id": telegramChatId,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "input_form_schema": inputFormSchema,
    "performed_by": performedBy,
    "is_robot_enabled": isRobotEnabled,
    "is_api_enabled": isApiEnabled,
    "api_provider_id": apiProviderId,
    "display_order": displayOrder,
    "country": country?.toJson(),
    "companycodes": companycodes == null
        ? []
        : List<dynamic>.from(companycodes!.map((x) => x.toJson())),
  };
}

class Companycode {
  final int? id;
  final String? companyId;
  final String? reservedDigit;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic performedBy;

  Companycode({
    this.id,
    this.companyId,
    this.reservedDigit,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.performedBy,
  });

  factory Companycode.fromJson(Map<String, dynamic> json) => Companycode(
    id: _readInt(json["id"]),
    companyId: json["company_id"]?.toString(),
    reservedDigit: json["reserved_digit"]?.toString(),
    deletedAt: json["deleted_at"],
    createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
    updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
    performedBy: json["performed_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company_id": companyId,
    "reserved_digit": reservedDigit,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "performed_by": performedBy,
  };
}

class Country {
  final int? id;
  final String? countryName;
  final String? countryFlagImageUrl;
  final String? languageId;
  final String? currencyId;
  final String? countryTelecomCode;
  final String? phoneNumberLength;
  final bool? enableOperatorLookup;
  final OperatorLookupConfig? operatorLookupConfig;
  final OperatorMapping? operatorMapping;
  final bool? isActive;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic performedBy;

  Country({
    this.id,
    this.countryName,
    this.countryFlagImageUrl,
    this.languageId,
    this.currencyId,
    this.countryTelecomCode,
    this.phoneNumberLength,
    this.enableOperatorLookup,
    this.operatorLookupConfig,
    this.operatorMapping,
    this.isActive,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.performedBy,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    id: _readInt(json["id"]),
    countryName: json["country_name"]?.toString(),
    countryFlagImageUrl: json["country_flag_image_url"]?.toString(),
    languageId: json["language_id"]?.toString(),
    currencyId: json["currency_id"]?.toString(),
    countryTelecomCode: json["country_telecom_code"]?.toString(),
    phoneNumberLength: json["phone_number_length"]?.toString(),
    enableOperatorLookup: _readBool(json["enable_operator_lookup"]),
    operatorLookupConfig: json["operator_lookup_config"] == null
        ? null
        : OperatorLookupConfig.fromJson(json["operator_lookup_config"]),
    operatorMapping: json["operator_mapping"] == null
        ? null
        : OperatorMapping.fromJson(json["operator_mapping"]),
    isActive: _readBool(json["is_active"]),
    deletedAt: json["deleted_at"],
    createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ""),
    updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
    performedBy: json["performed_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "country_name": countryName,
    "country_flag_image_url": countryFlagImageUrl,
    "language_id": languageId,
    "currency_id": currencyId,
    "country_telecom_code": countryTelecomCode,
    "phone_number_length": phoneNumberLength,
    "enable_operator_lookup": enableOperatorLookup,
    "operator_lookup_config": operatorLookupConfig?.toJson(),
    "operator_mapping": operatorMapping?.toJson(),
    "is_active": isActive,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "performed_by": performedBy,
  };
}

class OperatorLookupConfig {
  final String? method;
  final String? apiUrl;
  final Headers? headers;
  final int? timeout;
  final String? authKey;
  final String? authType;
  final String? responsePath;
  final String? parameterName;

  OperatorLookupConfig({
    this.method,
    this.apiUrl,
    this.headers,
    this.timeout,
    this.authKey,
    this.authType,
    this.responsePath,
    this.parameterName,
  });

  factory OperatorLookupConfig.fromJson(Map<String, dynamic> json) =>
      OperatorLookupConfig(
        method: json["method"]?.toString(),
        apiUrl: json["api_url"]?.toString(),
        headers: json["headers"] == null
            ? null
            : Headers.fromJson(json["headers"]),
        timeout: _readInt(json["timeout"]),
        authKey: json["auth_key"]?.toString(),
        authType: json["auth_type"]?.toString(),
        responsePath: json["response_path"]?.toString(),
        parameterName: json["parameter_name"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "method": method,
    "api_url": apiUrl,
    "headers": headers?.toJson(),
    "timeout": timeout,
    "auth_key": authKey,
    "auth_type": authType,
    "response_path": responsePath,
    "parameter_name": parameterName,
  };
}

class Headers {
  final String? accept;
  final String? authorization;

  Headers({this.accept, this.authorization});

  factory Headers.fromJson(Map<String, dynamic> json) => Headers(
    accept: json["Accept"]?.toString(),
    authorization: json["Authorization"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "Accept": accept,
    "Authorization": authorization,
  };
}

class OperatorMapping {
  final String? tt;
  final String? avea;
  final String? tcell;
  final String? vodafon;
  final String? turkcell;
  final String? vodafone;
  final String? turktelekom;
  final String? turkTelekom;

  OperatorMapping({
    this.tt,
    this.avea,
    this.tcell,
    this.vodafon,
    this.turkcell,
    this.vodafone,
    this.turktelekom,
    this.turkTelekom,
  });

  factory OperatorMapping.fromJson(Map<String, dynamic> json) =>
      OperatorMapping(
        tt: json["TT"]?.toString(),
        avea: json["AVEA"]?.toString(),
        tcell: json["TCELL"]?.toString(),
        vodafon: json["VODAFON"]?.toString(),
        turkcell: json["TURKCELL"]?.toString(),
        vodafone: json["VODAFONE"]?.toString(),
        turktelekom: json["TURKTELEKOM"]?.toString(),
        turkTelekom: json["TURK TELEKOM"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "TT": tt,
    "AVEA": avea,
    "TCELL": tcell,
    "VODAFON": vodafon,
    "TURKCELL": turkcell,
    "VODAFONE": vodafone,
    "TURKTELEKOM": turktelekom,
    "TURK TELEKOM": turkTelekom,
  };
}

// Accept JSON numbers/strings while retaining the existing model field types.
int? _readInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

bool? _readBool(dynamic value) {
  if (value is bool) return value;
  switch (value?.toString().trim().toLowerCase()) {
    case 'true':
    case '1':
      return true;
    case 'false':
    case '0':
      return false;
    default:
      return null;
  }
}
