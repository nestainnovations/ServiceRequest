/*
 *  Webkul Software.
 *  @package  Mobikul Application Code.
 *  @Category Mobikul
 *  @author Webkul <support@webkul.com>
 *  @Copyright (c) Webkul Software Private Limited (https://webkul.com)
 *  @license https://store.webkul.com/license.html 
 *  @link https://store.webkul.com/license.html
 *
 */

const String baseUrl = "https://service.sunsenz.com/public/api/v1";
const String demoUserName = "";
const String demoPassword = "";
const bool logApiCalls = true;






class ApiRoutes {
  static const String loginApiPath = "/session/login";
  static const String logoutApiPath = "/session/logout";
  static const String ticketListApiPath = "/tickets";
  static const String myProfileApiPath = "/me";
  static const String ticketDetailsPath = "/ticket/{ticketId}";
  static const String ticketReplyPath = "/ticket/{ticketId}/thread";


}