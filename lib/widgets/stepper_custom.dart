import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum StepStateCustom {
  indexed,
  editing,
  complete,
  disabled,
  error,
}

enum StepperTypeCustom {
  vertical,
  horizontal,
}

@immutable
class StepCustom {

  const StepCustom({
    @required this.content,
    this.state = StepStateCustom.indexed,
  }) : assert(content != null),
        assert(state != null);

  final Widget content;

  final StepStateCustom state;

}

class StepperCustom extends StatefulWidget {
  StepperCustom({
    Key key,
    @required this.steps,
    this.currentStep = 0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.backgroundColor,
    this.progressColor
  }) : assert(steps != null),
        assert(currentStep != null),
        assert(0 <= currentStep && currentStep < steps.length),
        super(key: key);

  final List<StepCustom> steps;

  final int currentStep;

  final ValueChanged<int> onStepTapped;

  final VoidCallback onStepContinue;

  final VoidCallback onStepCancel;

  final Color backgroundColor;

  final Color progressColor;

  @override
  _StepperCustomState createState() => _StepperCustomState();
}

class _StepperCustomState extends State<StepperCustom> with TickerProviderStateMixin {
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
    return Scaffold(
      key: _mScaffoldState,
      body: Column(
        children: <Widget>[
          Expanded(
            child: AnimatedSize(
              curve: Curves.fastOutSlowIn,
              duration: kThemeAnimationDuration,
              vsync: this,
              child: widget.steps[widget.currentStep].content,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).backgroundColor,
              spreadRadius: 3.0,
            )
          ],
        ),
        child: BottomAppBar(
          color: Theme.of(context).backgroundColor,
          child: Container(
            color: widget.backgroundColor ?? Theme.of(context).backgroundColor,
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
                      child: widget.currentStep == 0
                          ? SizedBox.shrink() : FlatButton(
                        onPressed: widget.onStepCancel,
                        textColor: Theme.of(context).textTheme.button.color,
                        textTheme: ButtonTextTheme.normal,
                        child: Text("VOLTAR", style: Theme.of(context).textTheme.bodyText2),
                      ),
                    ),
                  ),


                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                          onPressed: widget.onStepContinue,
                          color: widget.backgroundColor ?? Theme.of(context).backgroundColor,
                          textColor: widget.currentStep == widget.steps.length - 1 ? widget.progressColor ?? Theme.of(context).primaryColor : Theme.of(context).textTheme.button.color,
                          textTheme: ButtonTextTheme.normal,
                          child: widget.currentStep == widget.steps.length - 1
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.done, size: 20, color: Colors.black),
                              SizedBox(width: 4),
                              Text("CALCULAR", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: Colors.black))
                            ],
                          ) : Text("AVANÇAR", style: Theme.of(context).textTheme.bodyText2)
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

  _confirmExit() {
    return showDialog(
      context: context,
      child: Text('Deseja sair sem salvar?')
    );
  }
}