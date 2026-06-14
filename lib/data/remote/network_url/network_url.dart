import 'package:co.injazathr.injazathr/data/local/preferences.dart';

final Preferences preferences = Preferences();

// Keep this as Future<String>
Future<String> get workspaceBaseUrl async => await preferences.getWorkspaceUrl();

const liveurl = 'http://192.168.10.207.nip.io/api';
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
const myAssetsUrl = '/api/my-assets';
const myAssetsSummaryUrl = '/api/my-assets/summary';
