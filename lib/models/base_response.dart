
class BaseResponse {
  final String? returnStatus;
  final String? returnDetail;
  final dynamic data; // Adjust the type of data as needed

  BaseResponse({this.returnStatus, this.returnDetail, this.data});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      returnStatus: json['returnStatus'] as String?,
      returnDetail: json['returnDetail'] as String?,
      data: json['data'],
    );
  }
}