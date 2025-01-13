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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meserve/service/configuration/meserve_theme.dart';
import 'package:meserve/service/configuration/server_configuration.dart';
import 'package:meserve/service/constants/app_constants.dart';
import 'package:meserve/service/constants/app_routes.dart';
import 'package:meserve/service/constants/string_keys.dart';
import 'package:meserve/service/helper/app_alert_message.dart';
import 'package:meserve/service/helper/app_storage_pref.dart';
import 'package:meserve/service/helper/application_localization.dart';
import 'package:meserve/service/helper/email_validator.dart';
import 'package:meserve/service/helper/utils.dart';
import 'package:meserve/service/helper_widgets/app_dialog_helper.dart';
import 'package:meserve/service/helper_widgets/app_text_field.dart';
import 'package:meserve/service/helper_widgets/loader.dart';
import 'package:meserve/service/models/login/login_model.dart';
import 'package:meserve/service/screens/login/bloc/login_bloc.dart';



class LoginScreen extends StatefulWidget {

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }


}

class LoginScreenState extends State<LoginScreen> with EmailValidator{
  LoginBloc? loginBloc;
  LoginModel? loginModel;
  final _signInFormKey = GlobalKey<FormState>();
  final bool _autoValidate = false;
  final passwordController = TextEditingController(text: demoPassword);
  final emailController = TextEditingController(text:demoUserName);
  String passwordValue = "";
  String emailValue = "";
  bool showPassword = false;
  bool _loading = false;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


  @override
  void initState() {
    loginBloc =  context.read<LoginBloc>();
    loginBloc?.add(LoginEventLoadUI());
    _loading = false;
    super.initState();
  }

  @override
  void dispose() {
    loginBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body:_logInBloc(context) ,
      ),
    );
  }


  Widget _logInBloc(BuildContext context) {
    return BlocBuilder<LoginBloc,LoginState>(builder: (BuildContext context, state){
      if(state is LoginStateInitial){
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (state is LoginStateSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AlertMessage.showSuccess(ApplicationLocalizations.instance!.translate(StringKeys.loginSuccessMsg), context);
          _onSuccessfulLogin(state.data, state.email);

        });
      }

      if (state is LoginStateError){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppDialogHelper.errorDialog(state.message,  context, ApplicationLocalizations.instance, title: StringKeys.errorDialogTitleLabel, cancelable: true, barrierDismissible: true, showTryAgainButton: false, cancelButtonTitle: StringKeys.ok);
        });

      }



      if(state is LoginStateLoading){
        _loading = true;
      }else{
        _loading = false;
      }

      return buildUI(context);
    });
  }

  Widget buildUI(BuildContext context){
    return SafeArea(
      child: Stack(
        children:[ SingleChildScrollView(
          child: Container(
            margin:  const EdgeInsets.symmetric(
                vertical: AppSizes.widgetSidePadding*3,
                horizontal: AppSizes.widgetSidePadding,
            ),
            padding: const EdgeInsets.symmetric(
                vertical: AppSizes.widgetSidePadding*2,
                horizontal: AppSizes.widgetSidePadding,
            ),
            child: Form(
              key: _signInFormKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      AppImages.loginHeader,
                      height: MediaQuery.of(context).size.width/6,
                    ),
                  ),
                  const SizedBox(height: 40,),
                  Center(
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Log in to ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA69F9F),
                                  fontSize: 24,
                                ),
                              ),
                              TextSpan(
                                text: 'MEServe ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA80A0A),
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Moopens Service App.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFA80A0A),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25,),
                  AppTextField().getTextField(
                      context,
                      emailController,
                      StringKeys.signInUsernameLabel.localized(),
                      StringKeys.signInUsernameHint.localized(),
                      StringKeys.pleaseFillLabel.localized() +
                          StringKeys.signInUsernameLabel.localized(), validator: (email) {
                    if (email!.isEmpty) {
                      return StringKeys.pleaseFillLabel.localized() +
                          StringKeys.signInUsernameLabel.localized();
                    } else if (!isValidEmail(email)) {
                      return StringKeys.validEmailLabel.localized();
                    }
                    return null;
                  },
                      validLabel: StringKeys.validEmailLabel.localized(),
                      emailValue: emailValue),
                  const SizedBox(height:AppSizes.widgetSidePadding),
                  AppTextField().getTextField(
                      context,
                      passwordController,
                      StringKeys.signInPasswordLabel.localized(),
                      StringKeys.signInPasswordHint.localized(),
                      StringKeys.pleaseFillLabel.localized() +
                          StringKeys.signInPasswordLabel.localized(),
                      validator: (password) {
                        if (password!.isEmpty) {
                          return StringKeys.pleaseFillLabel.localized() +
                              StringKeys.signInPasswordLabel.localized();
                        } else if (password.length < 6) {
                          return ApplicationLocalizations.of(context)!
                              .translate(StringKeys.validPasswordLabel);
                        }
                        return null;
                      },
                      validLabel: StringKeys.validPasswordLabel.localized(),
                      emailValue: passwordValue,
                      showPassword: showPassword,
                      iconButton: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      )),
                  const SizedBox(height: 10,),
                  MaterialButton(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    elevation: 0.0,
                    minWidth: MediaQuery
                        .of(context)
                        .size
                        .width,
                    color: MobikulTheme.accentColor,
                    textColor: MobikulTheme.primaryButtonTextColor,
                    onPressed: () {
                      _onPressSignInButton();
                    },
                    child: Text(
                      StringKeys.signInButtonLabel.localized().toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 20,)
                ],
              ),
            ),
          ),
        ),
          Visibility(
            visible: _loading,
            child: const Loader(),
          ),
      ],
      ),
    );
  }

  _onPressSignInButton(){
    if(_signInFormKey.currentState?.validate() == true){
      Utils.hideSoftKeyBoard();
      loginBloc?.add(LoginEventLoading());
      loginBloc?.add(LoginEventFinal(emailController.text.trim(), passwordController.text.trim()));
    }
  }

  _onSuccessfulLogin(LoginModel data, String email) {
    appStoragePref.setUserToken(data.accessToken);
    appStoragePref.setAgentEmail(email);
    appStoragePref.setIsLoggedIn(true);
    Future.delayed(const Duration(seconds: 1)).then((value) => {
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard)
    });

    debugPrint("Agent Email --> ${appStoragePref.getAgentEmail()}");


  }





}