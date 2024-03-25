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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/configuration/mobikul_theme.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/constants/app_routes.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/constants/string_keys.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/application_localization.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/utils.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper_widgets/app_dialog_helper.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/models/ticket/ticket_details.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/screens/ticketDetail/bloc/ticket_detail_bloc.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/download_helper.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:photo_view/photo_view.dart';


class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<StatefulWidget> createState() {
    return TicketDetailScreenState();
  }
}

class TicketDetailScreenState extends State<TicketDetailScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TicketDetailBloc? bloc;

  @override
  void initState() {
    bloc = context.read<TicketDetailBloc>();
    bloc?.add(TicketDetailEventInitial());
    super.initState();
  }

  @override
  void dispose() {
    bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ticketDetailBloc(context);
  }

  Widget _ticketDetailBloc(BuildContext context) {
    return BlocBuilder<TicketDetailBloc, TicketDetailState>(
        builder: (context, state) {
      if (state is TicketDetailStateInitial) {
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(),
          body: SafeArea(
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
          ),
        );
      } else if (state is TicketDetailStateSuccess) {
        return _buildTicketView(context, state.model);
      } else if (state is TicketDetailStateError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppDialogHelper.errorDialog(
              state.message, context, ApplicationLocalizations.instance,
              title: StringKeys.errorDialogTitleLabel,
              cancelable: true,
              barrierDismissible: true,
              showTryAgainButton: false,
              cancelButtonTitle: StringKeys.ok);
        });
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(),
          body: Container(),
        );
      } else {
        return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(),
            body: Container(
              color: Colors.white,
              child: Text(ApplicationLocalizations.instance!
                  .translate(StringKeys.errorMsgWrongPageLabel)),
            ));
      }
    });
  }

  Widget _buildTicketView(BuildContext context, TicketDetails dataModel) {
    String priorityColor = "#000000";
    var priority = dataModel.ticketPriorities
        .where((element) => element.id == dataModel.ticket!.priority)
        .toList();
    if (priority.isNotEmpty) {
      priorityColor = priority[0].colorCode;
    }
    return Scaffold(
      key: scaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar( backgroundColor: const Color.fromARGB(255, 16, 175, 162),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.ticketCustomerInfo,
                        arguments: dataModel);
                  },
                  icon: const Icon(Icons.info_outline)),
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.ticketUpdateInfo,
                        arguments: dataModel);
                  },
                  icon: const Icon(Icons.edit_note_rounded))
            ],
            snap: false,
            pinned: true,
            floating: false,
            centerTitle: true,
            toolbarTextStyle: MobikulTheme.mobikulTheme.textTheme.bodyMedium
                ?.copyWith(overflow: TextOverflow.ellipsis),
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.symmetric(vertical: 20),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.circle,
                    size: 14,
                    color: Utils.fromHex(priorityColor),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      dataModel.ticket!.subject,
                      style: const TextStyle(
                              color: Colors.white, // Set the text color to white
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                                )
                          .copyWith(
                              overflow: TextOverflow.ellipsis, fontSize: 14),
                      maxLines: 2,
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverList.separated(
            itemCount: dataModel.ticket?.threads.length,
            itemBuilder: (context, index) {
              return Container(
                color: dataModel.ticket?.threads[index].threadType == "note"
                    ? Colors.yellow.shade200
                    : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image.network(
                        dataModel.ticket!.threads[index].user!.thumbnail,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                dataModel.ticket!.threads[index].user!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF0b9941), fontWeight: FontWeight.bold, fontSize: 18,),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                dataModel.ticket!.threads[index].updatedAt,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFFAB0A0A), fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(
                                height: 10,
                          ),
                            Material(
                            color: dataModel.ticket?.threads[index].threadType == "note"
                                ? Colors.yellow.shade200
                                : Colors.white,
                            child: InkWell(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Message:',
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                  height: 2,
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      text: '',
                                      children: [
                                        WidgetSpan(
                                          child: Linkify(
                                            onOpen: (link) async {
                                              // Handle when a link is clicked
                                              // ignore: deprecated_member_use
                                              if (await canLaunch(link.url)) {
                                                // ignore: deprecated_member_use
                                                await launch(link.url);
                                              } else {
                                                throw 'Could not launch $link';
                                              }
                                            },
                                            text: dataModel.ticket!.threads[index].message,
                                            style: const TextStyle(
                                              color: Color(0xFFfC5A03),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            linkStyle: const TextStyle(
                                              color: Color.fromARGB(255, 40, 138, 218), // Customize link color as needed
                                              decoration: TextDecoration.underline,
                                              fontSize: 15, // Underline links
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                  height: 18,
                                  ),
                                if (dataModel.ticket!.threads[index].attachments.isNotEmpty)
                                  const Text(
                                    'Attached images:',
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                  height: 7,
                                  ),
                                  if (dataModel.ticket!.threads[index].attachments.isNotEmpty)
                                   ...dataModel.ticket!.threads[index].attachments.map<Widget>((attachment) {
                                        return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust vertical spacing as needed
                                              child: GestureDetector(
                                                onTap: () {
                                        DownloadHelper().downloadPersonalData(attachment.iconURL, attachment.name, "", context);
                                        // Open the image using PhotoView
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PhotoView(
                                              imageProvider: NetworkImage(attachment.iconURL),
                                            ),
                                          ),
                                        );
                                          },
                                              child: Image.network(attachment.iconURL),
                                            ),
                                          );
                                        }).toList(),
                                        const SizedBox(
                                        height: 5,
                                        ),
                                  ExpansionTile(
                                      title: const Text(
                                        'Tap here!! to contact customer:',
                                        style: TextStyle(
                                          color: Color.fromARGB(179, 62, 23, 238),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      children: [
                                        const SizedBox(height: 5),
                                        const Text(
                                          'Contact number of customer:',
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            String phoneNumber = dataModel.ticket!.mobileNumber;
                                            // Ensure it's a valid phone number, then launch the dialer
                                            if (await canLaunchUrl(Uri.parse('tel:$phoneNumber'))) {
                                              await launchUrl(Uri.parse('tel:$phoneNumber'));
                                            } else {
                                              // Handle the error or show a message to the user
                                              debugPrint('Could not launch the dialer');
                                            }
                                          },
                                          child: Text(
                                            dataModel.ticket!.mobileNumber,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF3437eb),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'District of customer:',
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          dataModel.ticket!.district,
                                          style: const TextStyle(
                                            color: Color(0xFFeb7734),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'Alternate number of customer:',
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            String phoneNumber = dataModel.ticket!.alternateMobileNumber;
                                            // Ensure it's a valid phone number, then launch the dialer
                                            if (await canLaunchUrl(Uri.parse('tel:$phoneNumber'))) {
                                              await launchUrl(Uri.parse('tel:$phoneNumber'));
                                            } else {
                                              // Handle the error or show a message to the user
                                              debugPrint('Could not launch the dialer');
                                            }
                                          },
                                          child: Text(
                                            dataModel.ticket!.alternateMobileNumber,
                                            style: const TextStyle(
                                              color: Color(0xFFeb3434),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                height: 1,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12.0),
        child: OutlinedButton(
          style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF22bb33)),),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.ticketReply,
                    arguments: dataModel)
                .then((_) => bloc?.add(TicketDetailEventInitial()));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.reply_rounded,
                color: Colors.white,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                ApplicationLocalizations.instance!
                    .translate(StringKeys.replyButtonLabel),
                style: const TextStyle(color: Colors.white, fontSize: 18,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
