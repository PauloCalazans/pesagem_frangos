import 'package:flutter/material.dart';

enum StepStateCustom { indexed, editing, complete, disabled, error }

enum StepperTypeCustom { vertical, horizontal }

@immutable
class StepCustom {
  const StepCustom({
    required this.content,
    this.state = StepStateCustom.indexed,
  });

  final Widget content;

  final StepStateCustom state;
}

class StepperCustom extends StatefulWidget {
  const StepperCustom({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.backgroundColor,
    this.progressColor,
  }) : assert(0 <= currentStep && currentStep < steps.length);

  final List<StepCustom> steps;

  final int currentStep;

  final ValueChanged<int>? onStepTapped;

  final VoidCallback? onStepContinue;

  final VoidCallback? onStepCancel;

  final Color? backgroundColor;

  final Color? progressColor;

  @override
  _StepperCustomState createState() => _StepperCustomState();
}

class _StepperCustomState extends State<StepperCustom> {
  final Map<int, StepStateCustom> _oldStates = <int, StepStateCustom>{};
  final GlobalKey<ScaffoldState> _mScaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.steps.length; i += 1)
      _oldStates[i] = widget.steps[i].state;
  }

  @override
  void didUpdateWidget(StepperCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.steps.length == oldWidget.steps.length);

    for (int i = 0; i < oldWidget.steps.length; i += 1)
      _oldStates[i] = oldWidget.steps[i].state;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final buttonTextColor = theme.textTheme.labelLarge?.color;
    final bodyTextStyle = theme.textTheme.bodyMedium;

    return Scaffold(
      key: _mScaffoldState,
      body: Column(
        children: <Widget>[
          Expanded(
            child: AnimatedSize(
              curve: Curves.fastOutSlowIn,
              duration: kThemeAnimationDuration,
              child: widget.steps[widget.currentStep].content,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: surfaceColor, spreadRadius: 3.0)],
        ),
        child: BottomAppBar(
          color: surfaceColor,
          child: Container(
            color: widget.backgroundColor ?? surfaceColor,
            margin: const EdgeInsets.all(0),
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(height: 48.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Visibility(
                        child: TextButton(
                          onPressed: widget.onStepCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: buttonTextColor,
                          ),
                          child: Text("VOLTAR", style: bodyTextStyle),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.onStepContinue,
                        style: TextButton.styleFrom(
                          backgroundColor:
                              widget.backgroundColor ?? surfaceColor,
                          foregroundColor:
                              widget.currentStep == widget.steps.length - 1
                              ? widget.progressColor ?? theme.primaryColor
                              : buttonTextColor,
                        ),
                        child: Visibility(
                          visible:
                              widget.currentStep == widget.steps.length - 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.done, size: 20, color: Colors.black),
                              SizedBox(width: 4),
                              Text(
                                "CALCULAR",
                                style: bodyTextStyle?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          replacement: Text("AVANÇAR", style: bodyTextStyle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
