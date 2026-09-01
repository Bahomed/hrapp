import 'package:co.injazathr.injazathr/data/local/preferences.dart';

final Preferences preferences = Preferences();

// Keep this as Future<String>
Future<String> get workspaceBaseUrl async => await preferences.getWorkspaceUrl();

const liveurl = 'https://injazathr.co/api';
const baseurl = liveurl;


// Leave Request URLs
const String leaveRequestsUrl = '/api/requests/leave';

// Permit Request URLs  
const String permitRequestsUrl = '/api/requests/permit';

// Loan Request URLs
const String loanRequestsUrl = '/api/requests/loan';
const String loanRequestDetailUrl = '/api/requests/loan';

// Letter Request URLs
const String letterRequestsUrl = '/api/requests/letter';

// Overtime Request URLs
const String overtimeRequestsUrl = '/api/requests/overtime';

// Missing Punch Request URLs
const String missingPunchRequestsUrl = '/api/requests/missing-punch';

// General Request URLs
const String allRequestsUrl = '/api/requests/all';
const String requestTypesUrl = '/api/requests/types';
const String payrollBaseUrl = '/api/payroll';
const String documentBaseUrl='/api/documents';
const dashBoardUrl='/api/get-dashboard';
const getGreetingUrl='/api/greeting';
const getUnexecutedRequestsUrl='/api/get-dashboard-unexecuted-approved-requests';
const notificationsUrl='/api/notifications';
const getallholidayurl = '/api/get-all-holiday';
const getEmployeesUrl = '/api/manager/employees';
const getEmployeeProfileUrl = '/api/manager/employee-profile/';
const getEmployeeRequestsUrl = '/api/manager/employee-request/';
const getLeaveBalanceUrl = '/api/manager/get-leave-balance/';

// Asset URLs
const updatePreferredLanguageUrl = '/api/update-preferred-language';

const myAssetsUrl = '/api/my-assets';
const myAssetsSummaryUrl = '/api/my-assets/summary';

// ==================== CHAT ====================
// Mirrors App\Http\Controllers\Api\ChatController — routes are registered under
// Route::prefix('chat') inside routes/api.php, i.e. everything sits at /api/chat.
// This is the single place to adjust if the backend prefix changes.
const String chatBaseUrl = '/api/chat';
const String chatConversationsUrl = '$chatBaseUrl/conversations';
const String chatUnreadCountUrl = '$chatBaseUrl/unread-count';
const String chatHeartbeatUrl = '$chatBaseUrl/heartbeat';
const String chatSearchUsersUrl = '$chatBaseUrl/search-users';
const String chatMyTeamUrl = '$chatBaseUrl/my-team';
const String chatStartDirectUrl = '$chatBaseUrl/start-direct';
const String chatStartGroupUrl = '$chatBaseUrl/start-group';
const String chatMyDepartmentSectionsUrl = '$chatBaseUrl/my-department-sections';

String chatMessagesUrl(int id) => '$chatBaseUrl/$id/messages';
String chatSendMessageUrl(int id) => '$chatBaseUrl/$id/send';
String chatPinUrl(int id) => '$chatBaseUrl/$id/pin';
String chatMuteUrl(int id) => '$chatBaseUrl/$id/mute';
String chatRenameUrl(int id) => '$chatBaseUrl/$id/rename';
String chatParticipantsUrl(int id) => '$chatBaseUrl/$id/participants';
String chatLeaveUrl(int id) => '$chatBaseUrl/$id/leave';
String chatRemoveParticipantUrl(int id, int userId) =>
    '$chatBaseUrl/$id/participants/$userId';
String chatReactUrl(int messageId) => '$chatBaseUrl/message/$messageId/react';
String chatDeleteMessageUrl(int messageId) => '$chatBaseUrl/message/$messageId';
String chatDepartmentGroupUrl(int departmentId) =>
    '$chatBaseUrl/open-department-group/$departmentId';
String chatSectionGroupUrl(int deptSectionId) =>
    '$chatBaseUrl/open-section-group/$deptSectionId';
