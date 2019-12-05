import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'address_manager.dart';
import 'address_model.dart';

class Address {
  AddressProvince currentProvince;
  AddressCity currentCity;
  AddressDistrict currentDistrict;

  Address({this.currentProvince, this.currentCity, this.currentDistrict});
}

typedef AddressCallback = void Function(Address);

enum AddressPickerMode {
  province,
  provinceAndCity,
  provinceCityAndDistrict,
}

class AddressPicker extends StatefulWidget {
  /// 选中的地址发生改变回调
  final AddressCallback onSelectedAddressChanged;
  final AddressCallback onCommitAddress;

  /// 选择模式
  /// province 一级: 省
  /// provinceAndCity 二级: 省市
  /// provinceCityAndDistrict 三级: 省市区
  final AddressPickerMode mode;
  final Widget title;

  /// 省市区文字显示样式
  final TextStyle selectedTitleStyle;
  final TextStyle unselectedTitleStyle;

  static const Color selectedTitleColor = Color(0xFFF0601C);
  static const Color unselectedTitleColor = Color(0xFF6D6D6D);
  static const double titleFontSize = 14;
  static const TextStyle style1 = TextStyle(
      color: selectedTitleColor,
      fontSize: titleFontSize,
      fontWeight: FontWeight.w500);
  static const TextStyle style2 = TextStyle(
      color: unselectedTitleColor,
      fontSize: titleFontSize,
      fontWeight: FontWeight.w500);

  AddressPicker(
      {Key key,
      this.mode = AddressPickerMode.provinceCityAndDistrict,
      this.onSelectedAddressChanged,
      this.unselectedTitleStyle = style2,
      this.selectedTitleStyle = style1,
      this.title,
      this.onCommitAddress})
      : super(key: key);

  _AddressPickerState createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  List<AddressProvince> _provinces;

  AddressProvince _selectedProvince;
  AddressCity _selectedCity;
  AddressDistrict _selectedDistrict;

  ScrollController _cityScrollController =
      ScrollController(initialScrollOffset: 0);
  ScrollController _districtScrollController =
      ScrollController(initialScrollOffset: 0);

  @override
  void dispose() {
    _cityScrollController.dispose();
    _districtScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getAddressData();
  }

  void _getAddressData() async {
    final addressData = await AddressManager.loadAddressData(context);
    setState(() {
      _provinces = addressData;
      _selectedProvince = _provinces.first;
      _selectedCity = _selectedProvince.cities.first;
      _selectedDistrict = _selectedCity.district.first;
    });
  }

  void _updateCurrent() {
    if (widget.onSelectedAddressChanged != null) {
      var address = Address(
          currentProvince: _selectedProvince,
          currentCity: _selectedCity,
          currentDistrict: _selectedDistrict);
      widget.onSelectedAddressChanged(address);
    }
  }

  void _onCommit() {
    if (widget.onCommitAddress != null) {
      var address = Address(
          currentProvince: _selectedProvince,
          currentCity: _selectedCity,
          currentDistrict: _selectedDistrict);
      widget.onCommitAddress(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_provinces == null || _provinces.isEmpty) {
      return Container();
    }

    return SafeArea(
      child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
          child: Column(
            children: <Widget>[_buildHeader(), Expanded(child: _buildPicker())],
          )),
    );
  }

  _buildPicker() {
    return Container(
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(top: 12),
              color: Color(0xFFF6F6F6),
              child: ListView.builder(
                itemCount: _provinces?.length ?? 0,
                itemBuilder: (context, index) {
                  var item = _provinces[index];
                  return InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        item.province,
                        style: _selectedProvince == item
                            ? widget.selectedTitleStyle
                            : widget.unselectedTitleStyle,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedProvince = _provinces[index];
                        _selectedCity = _selectedProvince.cities.first;
                        _selectedDistrict = _selectedCity.district.first;
                        _cityScrollController.animateTo(0,
                            curve: Curves.easeInOut,
                            duration: Duration(milliseconds: 250));
                        _districtScrollController.animateTo(0,
                            curve: Curves.easeInOut,
                            duration: Duration(milliseconds: 250));
                      });
                      _updateCurrent();
                    },
                  );
                },
                itemExtent: 49,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: widget.mode == AddressPickerMode.province
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: 12),
                    color: Colors.white,
                    child: ListView.builder(
                      controller: _cityScrollController,
                      itemCount: _selectedProvince?.cities?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = _selectedProvince.cities[index];
                        return InkWell(
                            child: CustomPaint(
                              painter: _SelectedPainter(
                                  item == _selectedCity, false),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  item.city,
                                  style: _selectedCity == item
                                      ? widget.selectedTitleStyle
                                      : widget.unselectedTitleStyle,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedCity = _selectedProvince.cities[index];
                                _selectedDistrict =
                                    _selectedCity.district.first;
                                _districtScrollController.animateTo(0,
                                    curve: Curves.easeInOut,
                                    duration: Duration(milliseconds: 250));
                              });
                              _updateCurrent();
                            });
                      },
                      itemExtent: 49,
                    )),
          ),
          Expanded(
            flex: 1,
            child: widget.mode != AddressPickerMode.provinceCityAndDistrict
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: 12),
                    color: Colors.white,
                    child: ListView.builder(
                      controller: _districtScrollController,
                      itemCount: _selectedCity?.district?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = _selectedCity.district[index];
                        return InkWell(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                item.area,
                                style: _selectedDistrict == item
                                    ? widget.selectedTitleStyle
                                    : widget.unselectedTitleStyle,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedDistrict =
                                    _selectedCity.district[index];
                              });
                              _updateCurrent();
                            });
                      },
                      itemExtent: 49,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  _buildHeader() {
    return Container(
        height: 55,
        padding: EdgeInsets.only(top: 8, bottom: 8, right: 8),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                  child: Text('取消',
                      style: TextStyle(color: Color(0xFF969696), fontSize: 17)),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              widget.title ?? Spacer(),
              FlatButton(
                  // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    '确定',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  color: widget.selectedTitleStyle.color,
                  onPressed: () {
                    _onCommit();
                    Navigator.pop(context);
                  }),
            ]));
  }
}

class _SelectedPainter extends CustomPainter {
  final bool isSelected;
  final bool isBottom;

  static const Color lineColor = Color(0xFFE4E4E4);

  _SelectedPainter(this.isSelected, this.isBottom);
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    if (isSelected) {
      Path path = Path();
      path.moveTo(width, 0);
      path.lineTo(width, 12);
      path.lineTo(width - 10, height / 2);
      path.lineTo(width, height - 12);
      path.lineTo(width, height + 10000);
      canvas.drawPath(path, paint);
    } else {
      canvas.drawLine(Offset(width, 0), Offset(width, height), paint);
    }

    if (isBottom && isSelected) {
      canvas.drawLine(Offset(0, height), Offset(width, height), paint);
    }
  }

  @override
  bool shouldRepaint(_SelectedPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.isBottom != isBottom;
  }
}
