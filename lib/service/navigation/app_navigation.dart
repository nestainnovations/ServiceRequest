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

import 'package:flutter/material.dart';
import 'package:meserve/service/constants/app_routes.dart';
import 'package:meserve/service/models/ticket/ticket_details.dart';
import 'package:meserve/service/repository/dashboard_repository/dashboard_repository_impl.dart';
import 'package:meserve/service/repository/login_repository/login_repository_impl.dart';
import 'package:meserve/service/repository/ticket_detail_repository/ticket_detail_repository_impl.dart';
import 'package:meserve/service/repository/ticket_reply_repository/ticket_reply_repository_impl.dart';
import 'package:meserve/service/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:meserve/service/screens/dashboard/view/dashboard_screen.dart';
import 'package:meserve/service/screens/login/bloc/login_bloc.dart';
import 'package:meserve/service/screens/login/view/login_screen.dart';
import 'package:meserve/service/screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meserve/service/screens/ticketCustomerInfo/bloc/ticket_customer_info_bloc.dart';
import 'package:meserve/service/screens/ticketCustomerInfo/view/ticket_customer_info_screen.dart';
import 'package:meserve/service/screens/ticketDetail/bloc/ticket_detail_bloc.dart';
import 'package:meserve/service/screens/ticketDetail/view/ticket_detail_screen.dart';
import 'package:meserve/service/screens/ticketReply/bloc/ticket_reply_bloc.dart';
import 'package:meserve/service/screens/ticketReply/view/ticket_reply_screen.dart';
import 'package:meserve/service/screens/ticketUpdateInfo/bloc/ticket_update_info_bloc.dart';
import 'package:meserve/service/screens/ticketUpdateInfo/view/ticket_update_info_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case AppRoutes.dashboard:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) =>
              DashboardBloc(repository: DashboardRepositoryImpl()),
          child: const DashboardScreen(),
        ),
      );
    case AppRoutes.login:
      return MaterialPageRoute(
        builder: (_) => BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(repository: LoginRepositoryImpl()),
          child: const LoginScreen(),
        ),
      );
    case AppRoutes.ticketDetails:
      return MaterialPageRoute(
        builder: (_) => BlocProvider<TicketDetailBloc>(
          create: (context) => TicketDetailBloc(
              repository: TicketDetailRepositoryImpl(),
              ticketId: settings.arguments as int),
          child: TicketDetailScreen(ticketId: (settings.arguments as int)),
        ),
      );
    case AppRoutes.ticketCustomerInfo:
      return MaterialPageRoute(
        builder: (_) => BlocProvider<TicketCustomerInfoBloc>(
          create: (context) => TicketCustomerInfoBloc(
              model: settings.arguments as TicketDetails),
          child: const TicketCustomerInfoScreen(),
        ),
      );
    case AppRoutes.ticketUpdateInfo:
      return MaterialPageRoute(
        builder: (_) => BlocProvider<TicketUpdateInfoBloc>(
          create: (context) =>
              TicketUpdateInfoBloc(model: settings.arguments as TicketDetails),
          child: const TicketUpdateInfoScreen(),
        ),
      );
    case AppRoutes.ticketReply:
      return MaterialPageRoute(
        builder: (_) => BlocProvider<TicketReplyBloc>(
          create: (context) => TicketReplyBloc(
              repository: TicketReplyRepositoryImpl(),
              ticketData: (settings.arguments as TicketDetails)),
          child: const TicketReplyScreen(),
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
