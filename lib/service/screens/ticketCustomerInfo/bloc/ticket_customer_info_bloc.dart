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


import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:meserve/service/models/ticket/ticket_details.dart';

part 'ticket_customer_info_event.dart';
part 'ticket_customer_info_state.dart';

class TicketCustomerInfoBloc
    extends Bloc<TicketCustomerInfoEvent, TicketCustomerInfoState> {
  final TicketDetails model;

  TicketCustomerInfoBloc({required this.model})
      : super(TicketCustomerInfoInitial(model)) {
    on<TicketCustomerInfoEvent>(mapEventToState);
  }

  void mapEventToState(
      TicketCustomerInfoEvent event, Emitter<TicketCustomerInfoState> emit) {
    if (event is TicketCustomerInfoEventInitial) {
      emit(TicketCustomerInfoInitial(model));
    }
  }
}
