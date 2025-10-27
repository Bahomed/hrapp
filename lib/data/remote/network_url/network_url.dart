import 'package:co.injazathr.injazathr/data/local/preferences.dart';

final Preferences preferences = Preferences();

// Keep this as Future<String>
Future<String> get workspaceBaseUrl async => await preferences.getWorkspaceUrl();

const liveurl = 'https://digitalhrface.cyclonenepal.com';
const demourl = 'http://10.10.3.18/digital-hr-admin-files/public';

const baseurl = 'https://injazathr.co/api';

const loginurl = '$baseurl=/api/v2/login';
const logouturl = '$baseurl=/api/1.0v/logout';
const getallnoticeurl = '$baseurl=/api/1.0v/get-all-notice';
const getallshifturl = '$baseurl=/api/1.0v/get-shift';
const saveUserurl='$baseurl=/api/1.0v/save-user';
const getuserListurl='$baseurl=/api/1.0v/list-user';
const updateUserurl='$baseurl=/api/1.0v/update-user';
const savefaceidurl='$baseurl=/api/1.0v/save-face_ids';
const getuserDetailurl='$baseurl=/api/1.0v/get-user-detail';
const deleteUserUrl='$baseurl=/api/1.0v/delete-user';
const deleteFaceIdUrl='$baseurl=/api/1.0v/delete-face_ids';
const saveemployeeattendancedUrl='$baseurl=/api/1.0v/save-employee-attendance';
const getallFaceIdUrl='$baseurl=/api/1.0v/get-all-faceIds';
const todayattendanceUrl='$baseurl=/api/1.0v/get-today-attendance';
const updatecompanydetailsUrl='$baseurl=/api/1.0v/update-company-details';
const getcompanydetaiilsuRL='$baseurl=/api/1.0v/get-company-details';
const getdepartmentUrl='$baseurl=/api/1.0v/get-department';
const checkWorkspaceUrl='$baseurl/companies';

// Leave Request URLs
const String leaveRequestsUrl = '/api/requests/leave';

// Permit Request URLs  
const String permitRequestsUrl = '/api/requests/permit';

// Loan Request URLs
const String loanRequestsUrl = '/api/requests/loan';

// Letter Request URLs
const String letterRequestsUrl = '/api/requests/letter';

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
