import 'dart:convert';

AccountCurrencyModel accountCurrencyModelFromJson(String str) =>
    AccountCurrencyModel.fromJson(json.decode(str));

String accountCurrencyModelToJson(AccountCurrencyModel data) =>
    json.encode(data.toJson());

class AccountCurrencyModel {
  final bool? success;
  final int? code;
  final String? message;
  final List<Datum>? data;
  final List<dynamic>? payload;

  AccountCurrencyModel({
    this.success,
    this.code,
    this.message,
    this.data,
    this.payload,
  });

  factory AccountCurrencyModel.fromJson(Map<String, dynamic> json) =>
      AccountCurrencyModel(
        success: json["success"],
        code: json["code"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        payload: List<dynamic>.from(json["payload"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "payload": List<dynamic>.from(payload!.map((x) => x)),
  };
}

class Datum {
  final int? id;
  final String? name;
  final String? code;
  final String? symbol;
  final String? ignoreDigitsCount;
  final String? exchangeRatePerUsd;

  Datum({
    this.id,
    this.name,
    this.code,
    this.symbol,
    this.ignoreDigitsCount,
    this.exchangeRatePerUsd,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    code: json["code"] == null ? null : json["code"],
    symbol: json["symbol"] == null ? null : json["symbol"],
    ignoreDigitsCount: json["ignore_digits_count"] == null
        ? null
        : json["ignore_digits_count"],
    exchangeRatePerUsd: json["exchange_rate_per_usd"] == null
        ? null
        : json["exchange_rate_per_usd"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "symbol": symbol,
    "ignore_digits_count": ignoreDigitsCount,
    "exchange_rate_per_usd": exchangeRatePerUsd,
  };
}
