import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tnexchat/src/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import './popup.dart';

enum ActionType {
  //Button with background
  highlight,
  //Button only text
  normal
}

class ActionModel {
  final String? title;
  final ActionType? type;
  final Function? action;
  ActionModel({
    this.title,
    this.type,
    this.action
  });

  Widget toWidget() {
    if (this.type == ActionType.normal) {
      return Padding(
        padding: EdgeInsets.only(
            left: 130.w, right: 120.w, top: 50.h),
        child: InkWell(
          // onTap: this.action ?? () => Get.back(),
          child: Text(
            this.title ?? "",
            style: TextStyle(
                color: ChatColor.titleUnderlineButton,
                fontSize: 42.sp,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 70.w),
        child: textButton(this.title ?? "", this.action!)
    );
  }

  Widget textButton(String text, Function? onTap) {
    EdgeInsetsGeometry finalMargin = EdgeInsets.only(left: 60.w, right: 60.w, top: 30.w, bottom: 45.w);
    var finalRadius = BorderRadius.circular(20.w);
    var finalTextStyle = TextStyle(
        color: Color(0xFFF7F8F9),
        decoration: TextDecoration.none);
    return new MSBBouncingAnim(
      onPressed: onTap!,
      child: Container(
        height: 110.h,
        margin: finalMargin,
        padding: EdgeInsets.only(bottom: 6.h),
        decoration: BoxDecoration(
          color: ChatColor.backgroundButton,
          borderRadius: finalRadius,
        ),
        child: Center(
          child: Text(text, style: finalTextStyle),
        ),
      ),
    );
  }
}

class Popup {
  Popup._();
  static final instance = Popup._();

  Future showConfirmPopup(BuildContext context, {
    String? title,
    String? message,
    Image? iconImage,
    List<ActionModel>? actions
  }
      ) {
    return showDialog(
        context: context,
        builder: (c) {
          return PopupBottom(
            title: title!,
            message: message!,
            iconImage: iconImage!,
            actions: actions!,
          );
        });
  }

}

class PopupBottom extends StatefulWidget {
  String? title;
  String? message;
  Image? iconImage;
  List<ActionModel>? actions;
  PopupBottom(
      {
        this.title,
        this.message,
        this.iconImage,
        this.actions,
      });

  @override
  _PopupBottomState createState() =>
      _PopupBottomState();
}

class _PopupBottomState extends State<PopupBottom> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.bottomCenter,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(),
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: EdgeInsets.only(right: 45.w),
                    child: Image.asset(
                      "assets/msb/icons/ic_close.png",
                      width: 80.w,
                      height: 80.w,
                    ),
                  ),
                )
              ],
            ),
            BodyPopupBottom(
              title: widget.title,
              message: widget.message,
              iconImage: widget.iconImage,
              actions: widget.actions,
            ),
          ],
        ),
      ),
    );
  }
}

class BodyPopupBottom extends StatefulWidget {
  String? title;
  String? message;
  Image? iconImage;
  List<ActionModel>? actions;
  BodyPopupBottom(
      {
        this.title,
        this.message,
        this.iconImage,
        this.actions,
      });

  @override
  _BodyPopupBottomState createState() =>
      _BodyPopupBottomState();
}

class _BodyPopupBottomState extends State<BodyPopupBottom> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(80.w),
            topRight: Radius.circular(80.w),
          ),
          color: Colors.red
        // color: TnexColor.backgroundPopup,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.iconImage == null ?
          Container(padding: EdgeInsets.all(5)) : widget.iconImage!,
          widget.title == null ?
          Container(padding: EdgeInsets.all(10)) : Padding(
            padding: EdgeInsets.only(
                left: 100.w, right: 100.w, top: 70.h),
            child: Text(
              widget.title!,
              style: TextStyle(
                  color: ChatColor.title,
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          widget.message == null ?
          Container(padding: EdgeInsets.all(20))
              : Padding(
            padding: EdgeInsets.only(left: 120.w, right: 120.w, bottom: 80.h, top: 10.h),
            child: Text(
              widget.message!,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 42.sp,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ),
          actionWidget()
        ],
      ),
    );
  }

  Widget actionWidget() {
    if (widget.actions == null) {
      return SizedBox();
    }
    final listActionWidget = widget.actions!.map((action) => action.toWidget()).toList();
    return Column(
      children: listActionWidget,
    );
  }
}