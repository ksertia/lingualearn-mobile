import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:fasolingo/controller/my_controller.dart';
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/services/auth_services.dart';
import 'package:fasolingo/helpers/services/error_handling.dart';
import 'package:fasolingo/helpers/services/navigation_service.dart';
import 'package:fasolingo/helpers/services/profile_service.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/theme/app_notifier.dart';
import 'package:fasolingo/helpers/utils/app_snackbar.dart';
import 'package:fasolingo/helpers/my_widgets/my_form_validator.dart';
import 'package:fasolingo/helpers/my_widgets/my_text_utils.dart';
import 'package:fasolingo/models/enumaration_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/route_manager.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();
  bool filled = false;
  DateTime? selectedDate;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isProfileLoading = false;
  bool isDeleteUser = false;

  RxInt selectedPaymentIndex = 0.obs;
  TextEditingController paymentPhoneNumber = TextEditingController();
  TextEditingController paymentOTP = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController countryCode = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController identityNumber = TextEditingController();
  RxString userProfileImage = "".obs;
  RxString selectedGender = "".obs;
  RxString returnStatus = "".obs;
  RxString attachedFileName = "".obs;
  RxString birthdate = "".obs;
  List<PlatformFile>? files = [];

  RxString selectedIdentityProof = "".obs;
  RxList<String> identityProof = ["IDENTITY_CARD"].obs;
  RxString selectedCountry = "".obs;
  Rx<Country> selectedCountryModel = Country().obs;
  Rx<EnumerationsModel> enumerationsModel = EnumerationsModel().obs;
  List<PlatformFile> profileFiles = [];
  RxString profileImageID = "".obs;
  RxInt selectedAvatafasolingoageIndex = 0.obs;
  RxString selectedAvatafasolingoageName = "".obs;
  RxString selectedAvatafasolingoagePath = "".obs;
  RxInt selectedColorIndex = 0.obs;
  RxString selectedColorName = "".obs;
  RxString selectedColorPath = "".obs;
  RxList<String> languageList = <String>["english".tr(), "french".tr()].obs;
  RxList<String> labelList =
      <String>["mobile".tr(), "work".tr(), "home".tr(), "main".tr()].obs;
  RxString selectedLanguage = "english".tr().obs;
  RxString selectedPaymentOperatorID = "".obs;
  RxString selectedPaymentLabelName = "".obs;
  RxBool isProfilePublic = false.obs;
  GlobalKey<FormState> paymentMethodAPI = GlobalKey();
  GlobalKey<FormState> paymentMethodAddAPI = GlobalKey();
  RxBool isPaymentMethodLoading = false.obs;
  RxBool isLogoutLoading = false.obs;
  var searchQuery = "".obs;
  TextEditingController searchController = TextEditingController();

  List<String> dummyTexts =
      List.generate(12, (index) => MyTextUtils.getDummyText(60));

  MyFormValidator validation = MyFormValidator();

  Future<List<PlatformFile>?> pickFile() async {
    var result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ["jpg", "png"],
        type: FileType.custom);
    if (result?.files[0] != null) {
      return result?.files;
    } else {
      return null;
    }
  }

  getData() {
    enumerationsModel(Provider.of<AppNotifier>(NavigationService.globalContext!,
            listen: false)
        .enumerationsModel);
  }

  ///******************************** Get Payment Method ********************************///
  // Future<void> getPaymentMethodData({required String context}) async {
  //   PaymentOperatorModel? model = await PaymentService.getPaymentMethodAPI(
  //       context: context,
  //       countryUUid: LocalStorage.getCountryID() ?? "",
  //       offset: 0,
  //       limit: 25);
  //   if (model != null) {
  //     paymentModel(model);
  //   }
  // }

  ///******************************** Get User Payment Method ********************************///
  // Future<void> getUserPaymentMethodData() async {
  //   isPaymentMethodLoading(true);
  //   List<PaymentItem>? list = await PaymentService.getUserPaymentMethodAPI(
  //       userUUid: LocalStorage.getUserID() ?? "", offset: 0, limit: 25);
  //   if (list != null) {
  //     paymentMethodList(list);
  //     isPaymentMethodLoading(false);
  //   } else {
  //     isPaymentMethodLoading(false);
  //   }
  // }

  // @override
  // void onInit() {
  //   super.onInit();
  //
  //   getPaymentMethodData(context: "");
  //
  //   getUserPaymentMethodData();
  // }

  void onChangedFilledChecked(bool? value) {
    filled = value ?? filled;

    update();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
        context: Get.context!,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
    }
  }

  // Upload Image From Gallery
  Future<void> uploadImageFromGallery() async {
    Get.back<void>();
    // EasyLoading.show();
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);

    if (photo != null) {
      if (photo.name.split('.').last == 'jpg' ||
          photo.name.split('.').last == 'png') {
        // File file = File(photo.path);
      } else {
        // EasyLoading.dismiss();
      }
    } else {
      // EasyLoading.dismiss();
    }
    update();
  }

  Future<void> onDeleteAccount() async {
    try {
      final Map<String, dynamic>? response = await ProfileService.deleteAccount(
        LocalStorage.getUserID() ?? "",
      );
      if (response?["returnStatus"] == "OK") {
        AuthService.isLoggedIn = false;
        LocalStorage.removeLoggedInUser();
        Get.offAllNamed('/splash');
      } else {
        appSnackbar(
          heading: response?["returnDetail"] ?? "",
          message: response?["returnDetail"] ?? "",
          snackbarState: SnackbarState.warning,
        );
      }
    } on dio.DioException catch (e) {
      letMeHandleAllErrors(e);
    }
  }

  loadingUpdate(bool value) {
    isProfileLoading = value;
    update();
  }

  Future<bool> onUpdateProfile({
    required String phone,
    required String firstName,
    required String lastName,
    required String countryID,
    required String dateOfBirth,
    required String email,
    required String address,
    required String idProofType,
    required String idProofNumber,
    required String gender,
    required String countryId,
    PlatformFile? profilePhoto,
    bool discoverable = false,
    String? avatarPreference,
  }) async {
    try {
      loadingUpdate(true);
      Map<String, dynamic>? response = await ProfileService.updateProfileData(
          data: dio.FormData.fromMap((profilePhoto != null)
              ? {
                  "avatar": await dio.MultipartFile.fromFile(
                      '${profilePhoto.path}',
                      filename: '${profilePhoto.path?.split("/").last}',
                      contentType: MediaType('image', 'png')),
                  "data": dio.MultipartFile.fromString(
                      jsonEncode({
                        "email": email,
                        "lastName": lastName,
                        "firstName": firstName,
                        "birthdate": dateOfBirth,
                        "countryId": countryId,
                        "gender": gender,
                        "discoverable": discoverable,
                        "preferences": {
                          "misc": {
                            "additionalProp1": {
                              "avatar": avatarPreference ?? ""
                            },
                          }
                        }
                      }),
                      contentType: MediaType('application', 'json')),
                }
              : {
                  "data": dio.MultipartFile.fromString(
                      jsonEncode({
                        "email": email,
                        "lastName": lastName,
                        "firstName": firstName,
                        "birthdate": dateOfBirth,
                        "countryId": countryId,
                        "gender": gender,
                        "discoverable": discoverable,
                        "preferences": {
                          "misc": {
                            "additionalProp1": {
                              "avatar": avatarPreference ?? ""
                            },
                          }
                        }
                      }),
                      contentType: MediaType('application', 'json')),
                }));

      if (response?['returnStatus'] == "OK") {
        loadingUpdate(false);
        await LocalStorage.setUserName(
            "${response?["data"]["firstName"]} ${response?["data"]["lastName"]}");
        appSnackbar(
          heading: response?["returnDetail"],
          message: "Profile Update Successfully",
        );
        return true;
      } else {
        loadingUpdate(false);
        return false;
      }
    } on dio.DioException catch (e) {
      loadingUpdate(false);
      letMeHandleAllErrors(e);
      return false;
    }
  }

  Future<void> onLogout() async {
    AuthService.isLoggedIn = false;
    bool isLogout = await ProfileService.userSignOut();

    if (isLogout) {
      await LocalStorage.removeLoggedInUser();
      Get.offNamed("/splash");
      isLogoutLoading(false);
    } else {
      isLogoutLoading(false);
    }
  }
}
