import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingCircleButton extends StatefulWidget{
  @override
  State createState() => FloatingCircleButtonState();

  FloatingCircleButton({@required this.onPressed,
    @required this.childImage,
    @required this.backgroundImage,
    @required this.title,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.all(0),
    this.width = 60.0,
    this.height = 60.0,
    this.child = null
  });

  final Function()? onPressed;
  final Widget? childImage;
  final Widget? child;
  final DecorationImage? backgroundImage;
  final String? title;

  Alignment alignment;
  EdgeInsets padding;
  double width;
  double height;
}

class FloatingCircleButtonState extends State <FloatingCircleButton> with SingleTickerProviderStateMixin {
  @override
  Widget build (BuildContext context) {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.end;
    if (widget.alignment == Alignment.topRight ||
        widget.alignment == Alignment.topLeft ||
        widget.alignment == Alignment.topCenter)
      mainAxisAlignment = MainAxisAlignment.start;
    else if (widget.alignment == Alignment.centerRight ||
        widget.alignment == Alignment.centerLeft ||
        widget.alignment == Alignment.center)
      mainAxisAlignment = MainAxisAlignment.center;
    return SafeArea(
        child: Align(
            alignment: widget.alignment,
            child: Column(
                mainAxisAlignment: mainAxisAlignment,
                children: <Widget>[
                  Container(
                      padding: widget.padding,
                      child: widget.child?? CircleButton(
                        onPressed: widget.onPressed,
                        backgroundImage: widget.backgroundImage,
                        childImage: widget.childImage,
                        title: widget.title,
                        width: widget.width,
                        height: widget.height,
                      )
                  ),
                ])
        )
    );
  }
}

class CircleButton extends StatefulWidget{
  @override
  State createState() => CircleButtonState();

  CircleButton({@required this.onPressed,
    @required this.childImage,
    @required this.title,
    this.backgroundImage,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.width = 60.0,
    this.height = 60.0,
  });

  final Function()? onPressed;

  final Widget? childImage;
  final String? title;
  DecorationImage? backgroundImage;
  MainAxisAlignment mainAxisAlignment;
  double width;
  double height;
}

class CircleButtonState extends State <CircleButton> with SingleTickerProviderStateMixin {
  @override
  Widget build (BuildContext context) {
    return Container(
      height: widget.height + 20,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: widget.width,
                height: widget.height,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: widget.backgroundImage
                ),
                child: _buildButtonImage()
            ),
            _buildButtonTitle(),
          ]
      ),
    );
  }

  Widget _buildButtonImage () {
    return widget.childImage ?? SizedBox(height: 0,);
  }

  Widget _buildButtonTitle () {
    if (widget.title == null || widget.title == '')
      return SizedBox(height: 0,);
    return Container(
      alignment: Alignment.bottomCenter,
      width: widget.width - 10,
      height: 20,
      padding: EdgeInsets.only(top: 2),
      child: Text(
        widget.title ?? "",
        maxLines: 1,
      ),
    );
  }
}