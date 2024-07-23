// ignore_for_file: prefer_const_constructors, duplicate_ignore
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:ea_frontend/screens/navbar_mobile.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> getNewInsignia(String? idChallenge) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? idUser = prefs.getString("idUser");
  final String token = prefs.getString('token') ?? "";
  String path =
      'http://${dotenv.env['API_URL']}/user/challenges/addinsignia/$idUser/$idChallenge';
  // ignore: unused_local_variable
  var response = await Dio().get(path,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }));
}

class MyQR extends StatefulWidget {
  final String idChallenge;
  final List<String> questions;
  final String expChallenge;
  const MyQR({
    Key? key,
    required this.idChallenge,
    required this.questions,
    required this.expChallenge,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyQRState();
}

class _MyQRState extends State<MyQR> {
  String? _idUser;
  // ignore: unused_field
  int? _exp;
  // ignore: unused_field
  int? _level;
  Barcode? result;
  String? answer;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int challengeSolved = 0;
  int _selectedQuestionIndex = -1;
  String selectedAnswer = "";

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(flex: 4, child: _buildQrView(context)),
          ],
        ),
      ),
    );
  }

  Widget challengeSolvedFunction() {
    if (challengeSolved == 1)
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Builder(
          builder: (context) => Center(
            child: AlertDialog(
              content: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.challenge_OK,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).dividerColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment
                                  .center, // Alinea el icono en el centro verticalmente
                              child: Container(
                                width: 32.5,
                                height: 32.5,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 22.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  // ignore: prefer_const_constructors
                  Text(
                    AppLocalizations.of(context)!.add_exp,
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).dividerColor),
                    textAlign: TextAlign.center,
                  ),
                  //const SizedBox(width: 7),
                  Text(
                    '${widget.expChallenge} 🎉',
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).dividerColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5), // Espacio entre el texto y la fila
                ],
              ),
              actions: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => const NavBar()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.go_back,
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Ajusta el valor para controlar el nivel de redondez
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
              ],
              backgroundColor: Theme.of(context).backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    30.0), // Ajusta el valor para controlar el nivel de redondez
              ),
            ),
          ),
        ),
      );
    else if (challengeSolved == 2)
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Builder(
          builder: (context) => Center(
            child: AlertDialog(
              content: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.almost,
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).dividerColor),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.answer,
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).dividerColor),
                        ),
                        SizedBox(width: 7),
                        Text(
                          AppLocalizations.of(context)!.wrong,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 209, 55, 55)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
              actions: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('Volver',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Ajusta el valor para controlar el nivel de redondez
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
              ],
              backgroundColor: Theme.of(context).backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    30.0), // Ajusta el valor para controlar el nivel de redondez
              ),
            ),
          ),
        ),
      );
    else if (result != null && result!.code != widget.idChallenge) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Builder(
          builder: (context) => Center(
            child: AlertDialog(
              content: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.error,
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).dividerColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 15),
                            Container(
                              width: 32.5,
                              height: 32.5,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 222, 66, 66),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 22.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  Text(
                    AppLocalizations.of(context)!.wrong_QR,
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).dividerColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5), // Espacio entre el texto y la fila
                ],
              ),
              actions: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('Volver',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Ajusta el valor para controlar el nivel de redondez
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
              ],
              backgroundColor: Theme.of(context).backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    30.0), // Ajusta el valor para controlar el nivel de redondez
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
    // if (result != null && result!.code != widget.idChallenge)
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    void sendAnswer(String answer, String idChallenge) async {
      try {
        print('PROVANDO-------------------------');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        _idUser = prefs.getString('idUser');
        _exp = prefs.getInt("experience");
        _level = prefs.getInt("level");
        var response = await Dio().post(
          'http://${dotenv.env['API_URL']}/challenge/post/solve',
          data: {
            "idChallenge": idChallenge,
            "answer": answer,
            "idUser": _idUser
          },
        );

        List<String> dataList = response.data.split("/");
        String answerStatus = dataList[0]; // "ANSWER_OK"
        print('VANDO-----------------------$answerStatus--');

        if (answerStatus == 'ANSWER_OK') {
          challengeSolved = 1;
          try {
            int level = int.parse(dataList[1]); // "3"
            int exp = int.parse(dataList[2]);

            if (exp >= 100) {
              level = level + 1;
              exp = exp - 100;
            }

            prefs.setInt("level", level);
            prefs.setInt("experience", exp);
            challengeSolvedFunction();
            // getNewInsignia(idChallenge);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.amber,
                showCloseIcon: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                content: Text(
                  AppLocalizations.of(context)!.problem_lvlUp,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                closeIconColor: Colors.black,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else if (response.data == 'ANSWER_NOK') {
          challengeSolved = 2;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 222, 66, 66),
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: Text(
                AppLocalizations.of(context)!.problem_answer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              closeIconColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 222, 66, 66),
            showCloseIcon: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
            content: Text(
              AppLocalizations.of(context)!.problem_answer,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            closeIconColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    return SafeArea(
      child: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: const Color.fromARGB(255, 222, 66, 66),
              borderRadius: 20,
              borderLength: 35,
              borderWidth: 13,
              cutOutSize: scanArea + 20,
            ),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
          Positioned(
            top: 25,
            left: 25,
            child: FloatingActionButton(
              onPressed: () async {
                await controller?.pauseCamera();
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, '/navbar');
              },
              backgroundColor: const Color.fromARGB(255, 222, 66, 66),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 8, 30, 8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 222, 66, 66),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller?.toggleFlash();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                      foregroundColor: Colors.white,
                    ),
                    child: FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Icon(
                            snapshot.data == true
                                ? Icons.flash_on
                                : Icons.flash_off,
                            size: 24,
                          );
                        } else {
                          return const Icon(
                            Icons.access_time_filled,
                            size: 24,
                          );
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 222, 66, 66),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller?.flipCamera();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                      foregroundColor: Colors.white,
                    ),
                    child: FutureBuilder(
                      future: controller?.getCameraInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return const Icon(
                            Icons.sync_rounded,
                            size: 24,
                          );
                        } else {
                          return const Icon(
                            Icons.access_time_filled,
                            size: 24,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (result != null && result!.code == widget.idChallenge)
                if (challengeSolved == 0)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 27.5),
                      child: Container(
                        height: 475,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.scan_OK,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          8), // Espacio entre el texto y el contenedor
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 50),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.questions.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final question = widget.questions[index];
                                    if (index == 0) {
                                      // First item: bold text
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 17.5,
                                            right: 17.5,
                                            bottom: 25),
                                        child: Text(
                                          question,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).dividerColor,
                                            fontSize: 18,
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                      );
                                    } else {
                                      return ListTile(
                                        minVerticalPadding: 1,
                                        title: Text(
                                          question,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).dividerColor,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        leading: Theme(
                                          data: Theme.of(context).copyWith(
                                            unselectedWidgetColor:
                                                Theme.of(context).dividerColor,
                                            // Set the unselected (background) color of the radial button
                                          ),
                                          child: Radio(
                                            value: index,
                                            groupValue: _selectedQuestionIndex,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedQuestionIndex =
                                                    value as int;
                                                selectedAnswer = question;
                                              });
                                            },
                                            activeColor: const Color.fromARGB(
                                                255,
                                                222,
                                                66,
                                                66), // Set the selected (dot) color of the radial button
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap, // Adjust the size of the radial button
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 32.5),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          sendAnswer(selectedAnswer,
                                              widget.idChallenge);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        backgroundColor: const Color.fromARGB(
                                            255, 222, 66, 66),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              challengeSolvedFunction(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              challengeSolvedFunction(),
              // if (challengeSolved == 1)
              //   BackdropFilter(
              //     filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              //     child: Builder(
              //       builder: (context) => Center(
              //         child: AlertDialog(
              //           content: Column(
              //             children: [
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   Padding(
              //                     padding: const EdgeInsets.only(top: 15),
              //                     child: Row(
              //                       children: [
              //                         Text(
              //                           AppLocalizations.of(context)!
              //                               .challenge_OK,
              //                           style: TextStyle(
              //                             fontSize: 25,
              //                             fontWeight: FontWeight.bold,
              //                             color: Theme.of(context).dividerColor,
              //                           ),
              //                           textAlign: TextAlign.center,
              //                         ),
              //                         const SizedBox(height: 5),
              //                         Align(
              //                           alignment: Alignment
              //                               .center, // Alinea el icono en el centro verticalmente
              //                           child: Container(
              //                             width: 32.5,
              //                             height: 32.5,
              //                             decoration: const BoxDecoration(
              //                               color: Colors.green,
              //                               shape: BoxShape.circle,
              //                             ),
              //                             child: const Icon(Icons.check,
              //                                 color: Colors.white, size: 22.5),
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ],
              //               ),

              //               const SizedBox(height: 35),
              //               // ignore: prefer_const_constructors
              //               Text(
              //                 AppLocalizations.of(context)!.add_exp,
              //                 style: TextStyle(
              //                     fontSize: 18,
              //                     color: Theme.of(context).dividerColor),
              //                 textAlign: TextAlign.center,
              //               ),
              //               //const SizedBox(width: 7),
              //               Text(
              //                 '${widget.expChallenge} 🎉',
              //                 style: TextStyle(
              //                     fontSize: 18,
              //                     color: Theme.of(context).dividerColor),
              //                 textAlign: TextAlign.center,
              //               ),
              //               const SizedBox(
              //                   height: 5), // Espacio entre el texto y la fila
              //             ],
              //           ),
              //           actions: <Widget>[
              //             Align(
              //               alignment: Alignment.center,
              //               child: ElevatedButton.icon(
              //                 onPressed: () {
              //                   Navigator.pushAndRemoveUntil(
              //                     context,
              //                     MaterialPageRoute(
              //                         builder: (BuildContext context) =>
              //                             const NavBar()),
              //                     (Route<dynamic> route) => false,
              //                   );
              //                 },
              //                 icon: const Icon(Icons.arrow_back,
              //                     color: Colors.white),
              //                 label: Text(AppLocalizations.of(context)!.go_back,
              //                     style: TextStyle(color: Colors.white)),
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor: Colors.green,
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(
              //                         20.0), // Ajusta el valor para controlar el nivel de redondez
              //                   ),
              //                 ),
              //               ),
              //             ),
              //             const SizedBox(height: 35),
              //           ],
              //           backgroundColor: Theme.of(context).backgroundColor,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(
              //                 30.0), // Ajusta el valor para controlar el nivel de redondez
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // if (challengeSolved == 2)
              //   BackdropFilter(
              //     filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              //     child: Builder(
              //       builder: (context) => Center(
              //         child: AlertDialog(
              //           content: Column(
              //             children: [
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   Padding(
              //                     padding: EdgeInsets.only(top: 15),
              //                     child: Row(
              //                       children: [
              //                         Text(
              //                           AppLocalizations.of(context)!.almost,
              //                           style: TextStyle(
              //                               fontSize: 35,
              //                               fontWeight: FontWeight.bold,
              //                               color:
              //                                   Theme.of(context).dividerColor),
              //                           textAlign: TextAlign.center,
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //               SizedBox(height: 35),
              //               Center(
              //                 child: Row(
              //                   mainAxisAlignment: MainAxisAlignment.center,
              //                   children: [
              //                     Text(
              //                       AppLocalizations.of(context)!.answer,
              //                       style: TextStyle(
              //                           fontSize: 18,
              //                           color: Theme.of(context).dividerColor),
              //                     ),
              //                     SizedBox(width: 7),
              //                     Text(
              //                       AppLocalizations.of(context)!.wrong,
              //                       style: TextStyle(
              //                           fontSize: 18,
              //                           fontWeight: FontWeight.bold,
              //                           color:
              //                               Color.fromARGB(255, 209, 55, 55)),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //               SizedBox(height: 5),
              //             ],
              //           ),
              //           actions: <Widget>[
              //             Align(
              //               alignment: Alignment.center,
              //               child: ElevatedButton.icon(
              //                 onPressed: () {
              //                   Navigator.of(context, rootNavigator: true)
              //                       .pop();
              //                 },
              //                 icon: const Icon(Icons.arrow_back,
              //                     color: Colors.white),
              //                 label: const Text('Volver',
              //                     style: TextStyle(color: Colors.white)),
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor:
              //                       const Color.fromARGB(255, 222, 66, 66),
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(
              //                         20.0), // Ajusta el valor para controlar el nivel de redondez
              //                   ),
              //                 ),
              //               ),
              //             ),
              //             const SizedBox(height: 35),
              //           ],
              //           backgroundColor: Theme.of(context).backgroundColor,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(
              //                 30.0), // Ajusta el valor para controlar el nivel de redondez
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // if (result != null && result!.code != widget.idChallenge)
              //   BackdropFilter(
              //     filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              //     child: Builder(
              //       builder: (context) => Center(
              //         child: AlertDialog(
              //           content: Column(
              //             children: [
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   Padding(
              //                     padding: const EdgeInsets.only(top: 15),
              //                     child: Row(
              //                       children: [
              //                         Text(
              //                           AppLocalizations.of(context)!.error,
              //                           style: TextStyle(
              //                             fontSize: 35,
              //                             fontWeight: FontWeight.bold,
              //                             color: Theme.of(context).dividerColor,
              //                           ),
              //                           textAlign: TextAlign.center,
              //                         ),
              //                         const SizedBox(width: 15),
              //                         Container(
              //                           width: 32.5,
              //                           height: 32.5,
              //                           decoration: const BoxDecoration(
              //                             color:
              //                                 Color.fromARGB(255, 222, 66, 66),
              //                             shape: BoxShape.circle,
              //                           ),
              //                           child: const Icon(Icons.close,
              //                               color: Colors.white, size: 22.5),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //               const SizedBox(height: 35),
              //               Text(
              //                 AppLocalizations.of(context)!.wrong_QR,
              //                 style: TextStyle(
              //                     fontSize: 18,
              //                     color: Theme.of(context).dividerColor),
              //                 textAlign: TextAlign.center,
              //               ),
              //               const SizedBox(
              //                   height: 5), // Espacio entre el texto y la fila
              //             ],
              //           ),
              //           actions: <Widget>[
              //             Align(
              //               alignment: Alignment.center,
              //               child: ElevatedButton.icon(
              //                 onPressed: () {
              //                   Navigator.of(context, rootNavigator: true)
              //                       .pop();
              //                 },
              //                 icon: const Icon(Icons.arrow_back,
              //                     color: Colors.white),
              //                 label: const Text('Volver',
              //                     style: TextStyle(color: Colors.white)),
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor:
              //                       const Color.fromARGB(255, 222, 66, 66),
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(
              //                         20.0), // Ajusta el valor para controlar el nivel de redondez
              //                   ),
              //                 ),
              //               ),
              //             ),
              //             const SizedBox(height: 35),
              //           ],
              //           backgroundColor: Theme.of(context).backgroundColor,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(
              //                 30.0), // Ajusta el valor para controlar el nivel de redondez
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          AppLocalizations.of(context)!.problem_permission,
        )),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
