import 'dart:developer';
import 'package:flutter/material.dart';

class LoadingButton1 extends StatefulWidget {
  final Future Function()? onPressed;
//  final String? text;
  final double? height;
  final Color? buttoncolor;
  final Color? buttontextcolor;

  const LoadingButton1(
      {Key? key,
      this.onPressed,
      this.height,
      required this.buttoncolor,
      this.buttontextcolor,
      required String text})
      : super(key: key);

  @override
  _LoadingButton1State createState() => _LoadingButton1State();
}

class _LoadingButton1State extends State<LoadingButton1> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Color(0xFF009DC8)),
            onPressed:
                (_isLoading || widget.onPressed == null) ? null : _loadFuture,
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Color(0xFF009DC8),
                      // backgroundColor:  Color(0xFF02ac88),
                      strokeWidth: 2,
                    ))
                : Text('SIGN IN'),
          ),
        ),
      ],
    );
  }

  Future<void> _loadFuture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed!();
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error $e')));
      rethrow;
    } finally {
      try {
        setState(() {
          _isLoading = false;
        });
      } catch (e) {}
    }
  }
}
