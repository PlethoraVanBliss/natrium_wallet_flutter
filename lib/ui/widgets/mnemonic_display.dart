import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';

import 'package:natrium_wallet_flutter/util/clipboardutil.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/styles.dart';

/// A widget for displaying a mnemonic phrase
class MnemonicDisplay extends StatefulWidget {
  final List<String> wordList;

  MnemonicDisplay(this.wordList);

  _MnemonicDisplayState createState() => _MnemonicDisplayState();
}

class _MnemonicDisplayState extends State<MnemonicDisplay> {
  bool _seedCopied;
  Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
    _seedCopied = false;
  }

  List<Widget> _buildMnemonicRows() {
    int nRows = 8;
    int itemsPerRow = 24 ~/ nRows;
    int curWord = 0;
    List<Widget> ret = [];
    for (int i = 0; i < nRows; i++) {
      ret.add(Container(
        width: (MediaQuery.of(context).size.width -
            (smallScreen(context) ? 0 : 60)),
        height: 1,
        color: StateContainer.of(context).curTheme.text05,
      ));
      // Build individual items
      List<Widget> items = [];
      for (int j = 0; j < itemsPerRow; j++) {
        items.add(
          Container(
            width: (MediaQuery.of(context).size.width -
                    (smallScreen(context) ? 15 : 60)) /
                itemsPerRow,
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(children: [
                TextSpan(
                  text: curWord < 9 ? " " : "",
                  style: AppStyles.textStyleNumbersOfMnemonic(context),
                ),
                TextSpan(
                  text: " ${curWord + 1}) ",
                  style: AppStyles.textStyleNumbersOfMnemonic(context),
                ),
                TextSpan(
                  text: widget.wordList[curWord],
                  style: _seedCopied?AppStyles.textStyleMnemonicSuccess(context):AppStyles.textStyleMnemonic(context),
                )
              ]),
            ),
          ),
        );
        curWord++;
      }
      ret.add(
        Padding(
            padding: EdgeInsets.symmetric(
                vertical: smallScreen(context) ? 6.0 : 10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center, children: items)),
      );
      if (curWord == itemsPerRow * nRows) {
        ret.add(Container(
          width: (MediaQuery.of(context).size.width -
              (smallScreen(context) ? 0 : 60)),
          height: 1,
          color: StateContainer.of(context).curTheme.text05,
        ));
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 15),
        child: Column(
          children: _buildMnemonicRows(),
        ),
      ),
      Container(
        margin: EdgeInsetsDirectional.only(top: 10),
        padding: EdgeInsets.all(0.0),
        child: OutlineButton(
          onPressed: () {
            Clipboard.setData(
                new ClipboardData(text: widget.wordList.join(' ')));
            ClipboardUtil.setClipboardClearEvent();
            setState(() {
              _seedCopied = true;
            });
            if (_seedCopiedTimer != null) {
              _seedCopiedTimer.cancel();
            }
            _seedCopiedTimer =
                new Timer(const Duration(milliseconds: 1500), () {
              setState(() {
                _seedCopied = false;
              });
            });
          },
          splashColor: _seedCopied
              ? Colors.transparent
              : StateContainer.of(context).curTheme.primary30,
          highlightColor: _seedCopied
              ? Colors.transparent
              : StateContainer.of(context).curTheme.primary15,
          highlightedBorderColor: _seedCopied
              ? StateContainer.of(context).curTheme.success
              : StateContainer.of(context).curTheme.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
          borderSide: BorderSide(
              color: _seedCopied
                  ? StateContainer.of(context).curTheme.success
                  : StateContainer.of(context).curTheme.primary,
              width: 1.0),
          child: AutoSizeText(
            _seedCopied ? "Copied to Clipboard" : "Copy to Clipboard",
            textAlign: TextAlign.center,
            style: _seedCopied
                ? AppStyles.textStyleButtonSuccessSmallOutline(context)
                : AppStyles.textStyleButtonPrimarySmallOutline(context),
            maxLines: 1,
            stepGranularity: 0.5,
          ),
        ),
      ),
    ]);
  }
}
