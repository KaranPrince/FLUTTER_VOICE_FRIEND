import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_voice_friend/services/animation_controller_service.dart';

class BottomIconsWhenListening extends StatelessWidget {
  final bool isListening;
  final AnimationControllerService animationControllerService;
  final Function onCancelListening;
  final Function onStopListening;
  final Function onToggleListening;
  final Function onRestartListening;
  final bool firstMessage;

  const BottomIconsWhenListening({
    super.key,
    required this.isListening,
    required this.animationControllerService,
    required this.onCancelListening,
    required this.onStopListening,
    required this.onToggleListening,
    required this.onRestartListening,
    required this.firstMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isListening)
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            FadeTransition(
              opacity: animationControllerService.buttonAnimation,
              child: ScaleTransition(
                scale: animationControllerService.buttonAnimation,
                child: GestureDetector(
                  onTap: () {
                    onCancelListening();
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 10,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      )),
                ),
              ),
            ),
            FadeTransition(
              opacity: animationControllerService.buttonAnimation,
              child: ScaleTransition(
                scale: animationControllerService.buttonAnimation,
                child: GestureDetector(
                  onTap: () {
                    onStopListening();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          spreadRadius: 10,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 60.0),
          ]),
        if (!isListening)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 60.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: animationControllerService.pulseAnimation,
                    child: Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: animationControllerService.animation,
                    child: GestureDetector(
                      onTap: () {
                        onToggleListening(true);
                        animationControllerService.buttonAnimationController
                            .forward();
                        animationControllerService.listeningAnimationController
                            .forward();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.5),
                              spreadRadius: 10,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 50.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              firstMessage
                  ? const SizedBox(width: 60.0)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              right: 20.0, left: 20.0, bottom: 3.0),
                          child: const Text(
                            'End',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'End conversation',
                                    style: GoogleFonts.imFellDoublePica(
                                      textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to end current conversation and select a new activity?',
                                    style: GoogleFonts.imFellDoublePica(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                            false); // return false when cancel is pressed
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.imFellDoublePica(
                                          textStyle: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                            true); // return true when confirm is pressed
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: GoogleFonts.imFellDoublePica(
                                          textStyle: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              onRestartListening();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  spreadRadius: 10,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.replay,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
      ],
    );
  }
}
