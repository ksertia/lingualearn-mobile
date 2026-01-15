import 'package:intl/intl.dart';

final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
final DateFormat timeFormatter = DateFormat('jms');

class AppConstant {
  // static const String baseAPI = 'https://api.helios.preprod.link2digit.com/helios-core';
  static const String baseAPI = 'https://projectwise.onrender.com';
  static const String baseURl = '$baseAPI/api';

  static const String GOOGLE_MAPS_API_KEY =
      "AIzaSyBNCe6MI-3F33A81XYdiIogk2ewWYp7DSk";
  static const String baseURl_ = '$baseAPI/api/public/v1/';

  // static const String baseURl1 = 'https://api.link2digit.com/link2digit/api/v1/';

  static const String baseFlagURl =
      'https://cdn.kcak11.com/CountryFlags/countries';
  // static const String baseV2URl = '$baseAPI/api/v2/';
  static const String socketURl = '$baseAPI/websocket/connect';
  static const String enumerations = 'enumerations';
  // static const String stripePublishableKey =
  //     'pk_test_51Q30fsP5Fm4LPu59MokaqiPir33BS5zG9OR1byiY5GMAmIS9AEaf3KlDErVbol0Z1x8znM45K0fwvlXsYwv9kfuP00HMEgwGKy';
  static const String pools = 'pools';
  static const String involvedPools = 'involved-pools';
  static const String activesPools = 'actives-pools';
  static const String close = 'close';
  static const String share = 'share';
  static const String publish = 'publish';
  static const String draftPools = 'draft-pools';
  static const String draft = 'draft';
  static const String phone_numbers = 'phone-numbers';
  static const String resources = 'resources';
  static const String renditions = 'renditions';
  static const String imgPreview = 'imgpreview';
  static const String contributions = 'contributions';
  static const String contributedPools = 'contributed-pools';
  static const String contributed = 'contribute';
  static const String publicPools = 'public-pools';
  static const String periodicPools = 'periodic-pools';
  static const String poolsCounts = 'pools-counts';
  static const String poolsStatistics = 'pools-statistics';
  static const String wallets = 'wallets';
  static const String goals = 'goals';
  static const String sendersWallets = 'senders-wallets';

  static const String transfer = 'transfer';
  static const String pendingInvitedPools = 'pending-invited-pools';
  static const String invitedPools = 'invited-pools';
  static const String pendingWithdrawApprovalsPools =
      'pending-withdraw-request-approvals';
  static const String poolMembership = 'pools-memberships';
  static const String multiple = 'multiple';
  static const String yyyyMMddTHHmm = "yyyy-MM-ddTHH:mm:ss'Z'";
  static const String yyyyMMdd = "yyyy-MM-dd";
  static const String ddMMyyyy = "dd-MM-yyyy";
  static const String ddMMyyHHmmS = "dd/MM/yy hh:mm a";
  static const String yyyyMMddHHMMs = "yyyy-MM-dd hh:mm a";
  static String truncateWithEllipsis(int cutoff, String text) {
    if (text.isEmpty) return text;
    return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
  }
  static const String group = "groups";
  static const String p2p = "p2p";
  static const String requesters = "requesters";
  static const String partners = "partners";
  static const String memberships = "memberships";
  static const String topics = "topics";
  static const String messages = "messages";
  static const String accept = "accept";
  static const String reject = "reject";
  static const String withdrawRequest = "withdraw-requests";
  static const String stopContributions = "stop-contributions";
  static const String resumeContributions = "resume-contributions";
  static const String receivers = "receivers";
  static const String received = "received";
  static const String countries = "countries";
  static const String create = "create";
  static const String paymentsOperators = "payment-operators";
  static const String assignReceiver = "assign-receiver";
  static const String transactions = "transactions";
  static const String events = "events";
  static const String eventParticipants = "event-participants";
  static const String payPalClientID =
      "AX_PEMF9N-xwjaSOCqg_NJYPf3rksJyiDk7woTxs7HGsvotBHF1edzPIDQGUUuQbozUTgPo6jCqAs2L2";
  static const String payPalSecret =
      "EKD-6KOF33-epl1ADSgIYH8cLUChDWAdHRPu4NYJ98mt4QmWFSyn4uVgYUZx80LfWBev_DScCaP1rDbM";
  static const String notifiedUsers = "notified-users";
  static const String notifications = "notifications";
  static const String paymentMethods = "payment-methods";
  static const String withdrawRequestApprovals = "withdraw-request-approvals";
  static const String approve = "approve";
  static const String approvals = "approvals";
  static const String registrations = "registrations";
  static const String announcementDisplays = "announcement-displays";
  static const String url = "url";
  static const String pollChoices = "poll-choices";
  static const String participation = "participations";
  static const String like = "like";
  static const String unlike = "unlike";
  static const String dislike = "dislike";
  static const String operatorDetails = "operator-details";
  static const String buckets = "buckets";

  ///////////////////////////////////////////////////////////////////////

  static const String tickets = 'tickets';
  static const String users = "users";

  ///enumerations
  static const String countryEnumerations = 'COUNTRY/enumerations';

  ///profile
  static const String profile = "profile";

  ///password
  static const String logged = "logged";
  static const String password = "password";
  static const String requestPasswordReset = "request-password-reset";

  ///authentication
  static const String validate = "validate";
  static const String resendValidationCode = "resend-validation-code";

  ///registration
  static const String register = 'register';
  static const String adminRegister = 'admin-register';
  static const String verificationCode = "verification-code";
  static const String availability = 'availability';

  ///tokens
  static const String tokens = 'tokens';

  ///e-vehicle
  static const String electricVehicles = 'electric-vehicles';
  static const String customers = 'customers';

  ///home
  static const String chargingStations = 'charging-stations';

  /// rfid-tags
  static const String myRFIDTags = 'rfid-tags';

  ///attached-file
  static const String attachedFile = 'attached-file';

  ///charging-parks
  static const String chargingParks = 'charging-parks';

  /// like unlike charging_parks
  static const String charging_Parks = 'charging_parks';

  ///charging-transactions
  static const String chargingTransactions = 'charging-transactions';

  ///swap-transactions
  static const String swapTransactions = 'swap-transactions';

  ///modules
  static const String modules = 'modules';

  ///FAQ_HELIOS
  static const String FAQ_HELIOS = 'FAQ_HELIOS';

  ///faqs
  static const String faqs = 'faqs';

  ///FR
  static const String FR = 'FR';

  ///reactions
  static const String reactions = 'reactions';

  ///reactions
  static const String reaction_comments = 'reaction-comments';

  ///comment
  static const String comment = 'comment';

  ///payment-operators
  static const String paymentOperators = 'payment-operators';

  ///charging-points
  static const String chargingPoints = 'charging-points';

  ///start-transaction
  static const String startTransaction = 'start-transaction';

  ///stop-transaction
  static const String stopTransaction = 'stop-transaction';

  ///roots
  static const String roots = 'roots';

  ///helios_flutter
  static const String heliosFlutter = 'helios_flutter';

  ///services
  static const String services = 'services';

  static const String swapStations = 'swap-stations';
  static const String swapProcess = 'swap-process';
}
