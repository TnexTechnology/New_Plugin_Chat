
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:tnexchat/src/constants/colors.dart';

class ChatConfirmPopupContent extends StatefulWidget {
  double contentHeight;
  ChatConfirmPopupContent({this.contentHeight = 500});

  @override
  _ChatConfirmPopupContentState createState() =>
      _ChatConfirmPopupContentState();
}

class _ChatConfirmPopupContentState
    extends State<ChatConfirmPopupContent> with ScreenLoader {

  final TextStyle txtTitleStyle = TextStyle(
      color: ChatColor.title);
  final TextStyle txtMsgStyle = TextStyle(
      color: Colors.white);
  final TextStyle txtLinkStyle = TextStyle(
      color: ChatColor.titleUnderlineButton,
      decoration: TextDecoration.underline);

  int radioGroupValue = 0;

  @override
  void initState() {
    super.initState();
  }

  loader() {
    // here any widget would do
    return AlertDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Container(
          width: 1,
          height: 1,
        ),
        content: Container(
          width: 100,
          height: 100,
          child: SpinKitPulse(
            color: Colors.blue,
            size: 90,
          ),
        ));
  }

  @override
  Widget screen(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent () {
    return Stack(
        children: [
          Container(
              height: widget.contentHeight + 40,
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 30),
              margin: EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),),
                  color: ChatColor.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withAlpha(150),
                      blurRadius: 15.0,
                      spreadRadius: 1.0,
                    ),
                  ]
              ),
              child: Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildCardFaces(),
                        SizedBox(height: 15,),
                        _buildTitleText(),
                        //SizedBox(height: 15,),
                        //_buildMsgText(),
                        SizedBox(height: 10,),
                        ElevatedButton(
                          child: const Text('Không, cám ơn'),
                          onPressed: () {Navigator.of(context).pop(false);}),
                        SizedBox(height: 10,),
                        ElevatedButton(
                            child: const Text('Có, tôi muốn rời'),
                            onPressed: () {Navigator.of(context).pop(true);})
                      ])
              )
          ),
          Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.topRight,
              child: this.circleIconButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  width: 300,
                  iconAssetPath: 'assets/msb/icons/close_icon.png',
                  height: 30,
                  padding: EdgeInsets.all(8))
          )
        ]);
  }

  Widget _buildCardFaces() {
    return Container(
        height: 150,
        child: Image.asset('assets/msb/inbox/delete_chat_icon.png')
    );
  }

  Widget _buildTitleText () {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Text(
          'Bạn có chắc chắn muốn rời cuộc trò chuyện này không?',
          style: txtTitleStyle, //tomi txtMsgStyle,
          textAlign: TextAlign.center,
          maxLines: 2,)
    );
  }

  Widget _buildMsgText () {
    return Container(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Text('CARD_MANAGEMENT_REQUEST_LOCK_CARD_MSG',
          style: txtMsgStyle,
          textAlign: TextAlign.center,
          maxLines: 3,)
    );
  }

  Widget circleIconButton(
      {required String iconAssetPath,
        double height = 45,
        required double width,
        padding: const EdgeInsets.all(13),
        required Function onPressed,
        Color bgColor = const Color(0xff1A2F45),
        Color iconColor = const Color(0xff1A2F45)}) {
    return MSBBouncingAnim(
      onPressed: onPressed,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        padding: padding,
        child: iconAssetPath != null
            ? Image.asset(
          iconAssetPath,
          color: iconColor,
          width: width,
        )
            : Icon(Icons.check_circle_outline, size: 25),
      ),
    );
  }

  void onBackButtonPressed() {

  }
}

class SpinKitPulse extends StatefulWidget {
  const SpinKitPulse({
    Key? key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(seconds: 1),
    this.controller,
  })  : assert(!(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
  'You should specify either a itemBuilder or a color'),
        super(key: key);

  final Color? color;
  final double size;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;
  final AnimationController? controller;

  @override
  _SpinKitPulseState createState() => _SpinKitPulseState();
}

class _SpinKitPulseState extends State<SpinKitPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
      ..addListener(() => setState(() {}))
      ..repeat();
    _animation = CurveTween(curve: Curves.easeInOut).animate(_controller);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 1.0 - _animation.value,
        child: Transform.scale(
          scale: _animation.value,
          child: SizedBox.fromSize(
            size: Size.square(widget.size),
            child: _itemBuilder(0),
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color));
}

class MSBBouncingAnim extends StatefulWidget {
  MSBBouncingAnim(
      { required this.onPressed,
        required this.child,
        this.scaleBegin = 1,
        this.scaleEnd = 1.1,
        this.durationMS = 25,
        this.coolDownMS = 600});

  final double scaleBegin;
  final double scaleEnd;
  final int durationMS;
  final int coolDownMS;
  final Function onPressed;
  final Widget child;

  @override
  State createState() => MSBBouncingAnimState();
}

class MSBBouncingAnimState extends State<MSBBouncingAnim>
    with SingleTickerProviderStateMixin {
  double? _scale;
  AnimationController? _controller;
  Animation<double>? animation;
  bool isPressed = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 50,
      ),
    )..addListener(() {
      setState(() {});
    });
    Animation curve = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInBack,
      reverseCurve: const Cubic(.21, 1.53, .75, 1.78),
    );

    animation =
        Tween(begin: widget.scaleBegin, end: widget.scaleEnd).animate(_controller!);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller!.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!_controller!.isCompleted)
      _waitAnimDoneAndUp();
    else
      _controller!.reverse();
  }

  Future<void> _waitAnimDoneAndUp() async {
    while (!_controller!.isCompleted) {
      await new Future.delayed(new Duration(milliseconds: widget.durationMS));
    }
    _controller!.reverse();
  }

  void _onTapCancel() {
    _controller!.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = animation!.value;
    return GestureDetector(
        onTap: _onButtonPressed,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Transform.scale(
          scale: _scale!,
          child: widget.child,
        ));
  }

  Future<void> _onButtonPressed() async {
    if (!isPressed) {
      isPressed = true;
      if (widget.coolDownMS > 0)
        await Future.delayed(new Duration(milliseconds: (widget.coolDownMS/12).round()));
      widget.onPressed();
      if (widget.coolDownMS > 0)
        await Future.delayed(new Duration(milliseconds: widget.coolDownMS));
      isPressed = false;
    }
  }
}
