# city_picker
flutter 省市区 选择器 
https://github.com/SiriDx/address_picker 基础上的 UI优化

![demo](http://bosch-tool.touch-spring.com/WechatIMG109.jpeg)

## Usage
```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          child: Text('show'),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                backgroundColor: Colors.white,
                builder: (context) => Theme(
                    data: ThemeData(
                      canvasColor: Colors.transparent,
                    ),
                    child: BottomSheet(
                        onClosing: () {},
                        builder: (context) => Container(
                              height: 400.0,
                              child: AddressPicker(
                                mode: AddressPickerMode.provinceCityAndDistrict,
                                title: Text('添加常用地址',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700)),
                                onSelectedAddressChanged: (address) {
                                  print('${address.currentProvince.province}');
                                  print('${address.currentCity.city}');
                                  print('${address.currentDistrict.area}');
                                },
                                onCommitAddress: (address) {
                                  print('onCommitAddress');
                                  print('${address.currentProvince.province}');
                                  print('${address.currentCity.city}');
                                  print('${address.currentDistrict.area}');
                                },
                              ),
                            ))));
          },
        ),
      ),
    );
  }
}
```
