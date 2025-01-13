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
import 'dart:async';

import 'package:flutter_easy_search_bar/flutter_easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meserve/service/configuration/meserve_theme.dart';
import 'package:meserve/service/constants/app_routes.dart';
import 'package:meserve/service/constants/string_keys.dart';
import 'package:meserve/service/helper/app_storage_pref.dart';
import 'package:meserve/service/helper/application_localization.dart';
import 'package:meserve/service/helper/utils.dart';
import 'package:meserve/service/helper_widgets/app_dialog_helper.dart';
import 'package:meserve/service/helper_widgets/loader.dart';
import 'package:meserve/service/models/dashboard/dashboard_ticket_list.dart';
import 'package:meserve/service/screens/dashboard/bloc/dashboard_bloc.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return DashboardScreenState();
  }
}

class DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  DashboardBloc? bloc;
  bool _loading = false;
  bool isFromSearch = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _debounce;
  int page = 1;
  String searchQuery = "";
  DashboardTicketList? dashboardTicketListModel;
  List<Tickets> ticketListModel = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _loading = false;
    page = 1;
    bloc = context.read<DashboardBloc>();
    bloc?.add(DashboardEventInitial(page));
    _scrollController.addListener(() {
      paginationFunction();
    });
    searchQuery = "";
    super.initState();
  }

  @override
  void dispose() {
    bloc?.close();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: EasySearchBar(
      backgroundColor: const Color(0xFFD91818), // Set the app bar color to #D91818
      title: const Text("Service Requests", // Change the title text to "Service Requests"
                        textAlign: TextAlign.center,
                   style: TextStyle(
                   color: Colors.white, // Set the text color to white
                   fontFamily: 'Montserrat',
                   fontSize: 22, // You might need to adjust the font size as per your requirement
                    ),
                  ),
        onSearch: _onSearchChanged,
        searchBackIconTheme: IconThemeData(color: Colors.grey.shade900),
        showClearSearchIcon: true,
        searchCursorColor: Colors.grey.shade600,
        searchHintText: ApplicationLocalizations.instance!
            .translate(StringKeys.searchHintLabel),
        searchClearIconTheme: IconThemeData(color: Colors.grey.shade900),
      ),
      drawer: Drawer(
        elevation: 8,
        child: SafeArea(
          child: _drawerBloc(context),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshPage,
        child: _dashboardBloc(context),
      ),
    );
  }

  Future<void> refreshPage() async {
    setState(() {
      page = 1;
    });
    bloc?.add(DashboardEventInitial(page));
  }


  Widget _drawerBloc(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
      if (state is DashboardStateInitial) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: MobikulTheme.primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: MobikulTheme.accentColor),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  ApplicationLocalizations.instance
                          ?.translate(StringKeys.pleaseWaitLabel) ??
                      "",
                  style: MobikulTheme.mobikulTheme.textTheme.headlineSmall,
                ),
                Text(ApplicationLocalizations.instance?.translate(
                        StringKeys.dashboardPageFetchingTicketsMsg) ??
                    "")
              ],
            ),
          ),
        );
      } else if (state is DashboardStateSuccess) {
        appStoragePref.setAgentEmail(state.model.userDetails?.email);
        appStoragePref.setAgentName(state.model.userDetails?.name);
        appStoragePref.setAgentProfileImage(state.model.userDetails?.profileImagePath);
        return buildDrawer(context, state.model);
      } else if (state is DashboardStateError) {
        return Container();
      } else {
        return Container(
          color: Colors.white,
          child: Text(ApplicationLocalizations.instance!
              .translate(StringKeys.errorMsgWrongPageLabel)),
        );
      }
    });
  }

  Widget buildDrawer(BuildContext context, DashboardTicketList model) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color:Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                child: InkWell(
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFFD91818),
                    size: 24,
                  ),
                  onTap: () {
                    if (scaffoldKey.currentState!.hasDrawer &&
                        scaffoldKey.currentState!.isDrawerOpen) {
                      scaffoldKey.currentState!.closeDrawer();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ApplicationLocalizations.instance!
                      .translate(StringKeys.dashboardDrawerProfileLabel),
                  style: MobikulTheme.mobikulTheme.textTheme.headlineSmall
                      ?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade900),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                appStoragePref.getAgentProfileImage(),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
                appStoragePref.getAgentName(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Set text to bold
                  color: Color(0xFFD91818), // Set text color to #D91818
                  fontSize: 16, // You might need to adjust the font size as per your requirement
                ),
              ),

          Text(
            appStoragePref.getAgentEmail(),
            style: const TextStyle(
                  fontWeight: FontWeight.bold, // Set text to bold
                  color: Color.fromARGB(255, 2, 2, 3), // Set text color to #D91818
                  fontSize: 14, // You might need to adjust the font size as per your requirement
                ),
          ),
          const SizedBox(
            height: 8,
          ),
          const Divider(
            thickness: 1,
            color: Color.fromARGB(255, 5, 5, 5),
          ),
          Material(
            child: InkWell(
              onTap: () {
                _onPressedLogout();
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.logout,
                    color: Color.fromARGB(255, 190, 3, 3),
                  ),
                  Text(
                    ApplicationLocalizations.instance!
                        .translate(StringKeys.logOutButtonLabel),
                    style: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardBloc(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
      if (state is DashboardStateInitial) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: MobikulTheme.primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: MobikulTheme.accentColor),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  ApplicationLocalizations.instance
                          ?.translate(StringKeys.pleaseWaitLabel) ??
                      "",
                  style: MobikulTheme.mobikulTheme.textTheme.headlineSmall,
                ),
                Text(ApplicationLocalizations.instance?.translate(
                        StringKeys.dashboardPageFetchingTicketsMsg) ??
                    "")
              ],
            ),
          ),
        );
      } else if (state is DashboardStateSuccess) {
        dashboardTicketListModel = state.model;
        if (page == 1) {
          ticketListModel = dashboardTicketListModel!.tickets;
        } else {
          List<Tickets> tempList = dashboardTicketListModel!.tickets.toList();
          for (Tickets ticket in tempList) {
            if (!ticketListModel.contains(ticket)) {
              ticketListModel.add(ticket);
            }
          }
        }
        _loading = false;
        isFromSearch = state.isFromSearch;
        return buildUI(context);
      } else if (state is DashboardStateError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppDialogHelper.errorDialog(
              state.message, context, ApplicationLocalizations.instance,
              title: StringKeys.errorDialogTitleLabel,
              cancelable: true,
              barrierDismissible: true,
              showTryAgainButton: false,
              cancelButtonTitle: StringKeys.ok);
        });
        return Container();
      } else {
        return Container(
          color: Colors.white,
          child: Text(ApplicationLocalizations.instance!
              .translate(StringKeys.errorMsgWrongPageLabel)),
        );
      }
    });
  }

  Widget buildUI(BuildContext context) {
    var ticketList = ticketListModel;

    return SafeArea(
        child: Stack(
      children: [
        Visibility(
            visible: ticketList.isEmpty,
            child: Center(
              child: Text(
                ApplicationLocalizations.instance!
                    .translate(StringKeys.dashboardPageEmptyTickets),
                style: MobikulTheme.mobikulTheme.textTheme.headlineSmall,
              ),
            )),
        Visibility(
          visible: ticketList.isNotEmpty,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: ticketList.length,
            itemBuilder: (context, index) {
              Tickets currentTicket = ticketList[index];
              return Material(
                child: InkWell(
                  onTap: () {
                    _onPressTicket(currentTicket.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          currentTicket.subject,
                          style:
                              const TextStyle(
                              color: Color (0xFFA30B0B), // Set the text color to white
                              fontFamily: 'Montserrat',
                              fontSize: 16, // You might need to adjust the font size as per your requirement
                              fontWeight: FontWeight.bold, // Make the font bold
                            ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text((currentTicket.group != null)
                            ? currentTicket.group!.name
                            : ' '),
                        const SizedBox(
                          height: 4,
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currentTicket.formatedCreatedAt),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 16,
                                  color: Utils.fromHex(
                                      currentTicket.priority!.colorCode),
                                ),
                                Icon(
                                  currentTicket.isStarred
                                      ? Icons.star_outlined
                                      : Icons.star_border,
                                  size: 24,
                                  color: currentTicket.isStarred
                                      ? Colors.yellow
                                      : Colors.grey,
                                ),
                                Icon(
                                  Utils.getSourceIcon(currentTicket.source),
                                  size: 24,
                                  color: Colors.grey,
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                height: 1,
                color: Colors.grey,
              );
            },
          ),
        ),
        Visibility(
          visible: _loading,
          child: const Loader(),
        ),
      ],
    ));
  }

  _onPressedLogout() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            ApplicationLocalizations.instance!
                .translate(StringKeys.logOutWarningMsg),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                /*ButtonLabelNO*/
                ApplicationLocalizations.instance!.translate(StringKeys.cancel),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
                onPressed: () {
                  _onPressConfirmLogout();
                },
                child: Text(/*ButtonLabelYes*/
                    ApplicationLocalizations.instance!
                        .translate(StringKeys.yesIWantToLogoutKey))),
          ],
        );
      },
    );
  }

  _onPressConfirmLogout() {
    Navigator.of(context, rootNavigator: true).pop();
    bloc?.repository?.logout().then((response) async {
      Navigator.pop(context);
      appStoragePref.logoutAgent();
      Navigator.popAndPushNamed(context, AppRoutes.login);
    });
  }

  _onSearchChanged(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      setState(() {
        page = 1;
      });
      bloc?.add(DashboardEventInitial(page));
    } else {
      if (query.length > 2) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 700), () {
          setState(() {
            page = 1;
          });
          bloc?.add(DashboardSearchEvent(query, page));
        });
      }
    }
  }

  paginationFunction() {
    if (_scrollController.hasClients &&
        (_scrollController.offset ==
            _scrollController.position.maxScrollExtent)) {
      if (dashboardTicketListModel!.pagination!.totalCount !=
          ticketListModel.length) {
        setState(() {
          if (page < dashboardTicketListModel!.pagination!.last) {
            page++;
            _loading = true;
            if (isFromSearch) {
              bloc?.add(DashboardSearchEvent(searchQuery, page));
            } else {
              bloc?.add(DashboardEventInitial(page));
            }
          }
        });
      }
    }
  }

  _onPressTicket(int ticketId) {
    Navigator.pushNamed(context, AppRoutes.ticketDetails, arguments: ticketId);
  }
}
