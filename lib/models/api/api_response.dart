import 'dart:convert';

abstract class Serializable {
  Map<String, dynamic> toMap();
}

class ApiData  extends Serializable {
  String?   uuid;
  DateTime? creationDate;
  DateTime? lastModifiedDate;
  String?   comment;
  int?      version;

  ApiData({
    this.uuid,
    this.creationDate,
    this.lastModifiedDate,
    this.comment,
    this.version,
  });

  factory ApiData.fromMap(Map<String, dynamic> json) => ApiData(
      uuid: json["uuid"],
      creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
      lastModifiedDate: json["lastModifiedDate"] == null ? null : DateTime.parse(json["lastModifiedDate"]),
      comment: json["comment"],
      version: json["version"],
  );

  @override
  Map<String, dynamic> toMap() => {
    "uuid": uuid,
    "creationDate": creationDate?.toIso8601String(),
    "lastModifiedDate": lastModifiedDate?.toIso8601String(),
    "comment": comment,
    "version": version,
  };
}




class WsResponse<T extends Serializable> extends Serializable {
  String? returnStatus;
  String? returnDetail;
  T?      data;

  WsResponse({
    this.returnStatus,
    this.returnDetail,
    this.data,
  });

  factory WsResponse.fromMap(Map<String, dynamic> map,
      T Function(Map<String, dynamic>) dataFactory) {
    return WsResponse<T>(
      returnStatus: map['returnStatus'] as String?,
      returnDetail: map['returnDetail'] as String?,
      data: map['data'] != null ? dataFactory(map['data'] as Map<String, dynamic>) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    "returnStatus": returnStatus,
    "returnDetail": returnDetail,
    "data": data?.toMap(),
  };
}

class SearchResult<T extends Serializable> {
  int? itemCountMatchingSearchCriteria;
  Pagination? pagination;
  List<T>? items;

  SearchResult({
    this.itemCountMatchingSearchCriteria,
    this.pagination,
    this.items,
  });

  factory SearchResult.fromMap(Map<String, dynamic> json, T Function(Map<String, dynamic>) dataFactory ) => SearchResult(
    itemCountMatchingSearchCriteria: json["itemCountMatchingSearchCriteria"],
    pagination: json["pagination"] == null ? null : Pagination.fromMap(json["pagination"]),
    items: json["items"] == null ? [] : List<T>.from(json["items"]!.map((x) => dataFactory(x))),
  );

  Map<String, dynamic> toMap() => {
    "itemCountMatchingSearchCriteria": itemCountMatchingSearchCriteria,
    "pagination": pagination?.toMap(),
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toMap())),
  };
}

class Pagination extends Serializable {
  int? offset;
  int? limit;
  int? itemsCount;

  Pagination({
    this.offset,
    this.limit,
    this.itemsCount,
  });

  factory Pagination.fromMap(Map<String, dynamic> json) => Pagination(
    offset: json["offset"],
    limit: json["limit"],
    itemsCount: json["itemsCount"],
  );

  @override
  Map<String, dynamic> toMap() => {
    "offset": offset,
    "limit": limit,
    "itemsCount": itemsCount,
  };
}
