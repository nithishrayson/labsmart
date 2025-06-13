import 'dart:async';
import 'package:app/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

class EnterOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const EnterOtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendSeconds = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }

  void _verifyOtp() {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate OTP verification delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      // You can navigate to home/dashboard on successful verification
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OTP Verified! Welcome!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    });
  }

  void _resendOtp() {
    if (!_canResend) return;

    // Call your resend OTP API here

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("OTP resent to ${widget.phoneNumber}")),
    );
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter OTP"),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text("We have sent an OTP to", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              widget.phoneNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: "Enter 6-digit OTP",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                counterText: '',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          "Verify OTP",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _canResend ? _resendOtp : null,
              child: Text(
                _canResend ? "Resend OTP" : "Resend OTP in $_resendSeconds s",
                style: TextStyle(
                  color: _canResend ? Colors.blue[700] : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
