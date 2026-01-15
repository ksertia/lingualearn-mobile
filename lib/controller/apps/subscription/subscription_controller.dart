// import 'package:carousel_slider/carousel_controller.dart';
import 'package:fasolingo/controller/my_controller.dart';
import 'package:get/get.dart';

class SubscriptionController extends MyController {

  // final CarouselController carouselController = Get.put(CarouselController());

  var currentIndex = 0.obs;
  final subscriptions = [
    {'planName': 'Free','price':'0', 'details': 'Lorem ipsum dolor sit amet consectetut.'},
    {'planName': 'Premium','price':'9.99', 'details': 'Lorem ipsum dolor sit amet consectetut.'},
  ].obs;

  void updateIndex(int index) {
    currentIndex.value = index;
  }

}