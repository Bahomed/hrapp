import 'package:co.injazathr.injazathr/data/local/preferences.dart';

final Preferences preferences = Preferences();

// Keep this as Future<String>
Future<String> get workspaceBaseUrl async => await preferences.getWorkspaceUrl();

//const liveurl = 'https://injazathr.co/api';
// TEST BUILD ONLY: local hrsaas server with the Nov 2026 API. Revert before release.
const liveurl = 'http://newhr.192.168.10.207.nip.io/api';

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

// ==================== TASK MANAGEMENT ====================
// Mirrors App\Http\Controllers\Api\TaskController — routes registered under
// Route::prefix('tasks') in routes/api.php, i.e. everything sits at /api/tasks.
// Single place to adjust if the backend prefix changes.
const String tasksBaseUrl = '/api/tasks';
const String tasksMyBoardUrl = '$tasksBaseUrl/my-board';
const String tasksAllBoardUrl = '$tasksBaseUrl/all-board';
const String tasksTeamBoardUrl = '$tasksBaseUrl/team-board';
const String taskStatusesUrl = '$tasksBaseUrl/statuses';
const String taskTypesUrl = '$tasksBaseUrl/types';
const String taskEmployeesSearchUrl = '$tasksBaseUrl/employees/search';
const String taskCountUrl = '$tasksBaseUrl/count';
const String createTaskUrl = tasksBaseUrl;

String taskStatusUpdateUrl(int id) => '$tasksBaseUrl/$id/status';

// ==================== MY PORTAL (/api/my/...) ====================
// Same rules as the web "My Portal / My Approvals": signed-in user only.
const String myBaseUrl = '/api/my';
const String myHomeUrl = '$myBaseUrl/home';
const String myAppSettingsUrl = '$myBaseUrl/app-settings';
const String myContractUrl = '$myBaseUrl/contract';
const String myLeavesUrl = '$myBaseUrl/leaves';
const String myEarnedLeaveBalanceUrl = '$myBaseUrl/earned-leave-balance';
const String myRequestsUrl = '$myBaseUrl/requests';
const String myRequestOptionsUrl = '$myBaseUrl/requests/options';
const String myRequestCountDaysUrl = '$myBaseUrl/requests/count-days';
const String myPendingUrl = '$myBaseUrl/pending';
const String myApprovalsUrl = '$myBaseUrl/approvals';
const String myApprovalCountsUrl = '$myBaseUrl/approvals/counts';
String myRequestUrl(int id) => '$myRequestsUrl/$id';
String myApprovalUrl(int id) => '$myApprovalsUrl/$id';
String myApprovalStepUrl(int stepId) => '$myApprovalsUrl/steps/$stepId';
String myExecutionUrl(int id) => '$myBaseUrl/executions/$id';
String myExecutionSettlementUrl(int id) => '$myBaseUrl/executions/$id/settlement';
String myExecutionReturnUrl(int id) => '$myBaseUrl/executions/$id/return';
String myFinalSettlementPrintUrl(int taskId) => '$myBaseUrl/final-settlements/$taskId/print';
String myFinalSettlementPayUrl(int taskId) => '$myBaseUrl/final-settlements/$taskId/pay';
String myFinalSettlementReturnUrl(int taskId) => '$myBaseUrl/final-settlements/$taskId/return';
String myNotificationAttachmentUrl(int id) => '$myBaseUrl/notifications/attachments/$id';
String myDocumentRenewUrl(int id) => '$myBaseUrl/documents/$id/renew';

// ==================== ASSIGNED OVERTIME ====================
const String assignedOvertimeUrl = '/api/assigned-overtime';
String assignedOvertimeDetailUrl(int id) => '$assignedOvertimeUrl/$id';
String assignedOvertimeAcceptUrl(int id) => '$assignedOvertimeUrl/$id/accept';
String assignedOvertimeRejectUrl(int id) => '$assignedOvertimeUrl/$id/reject';
