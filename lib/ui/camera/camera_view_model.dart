import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:io' as Io;

import 'package:Eletor/api/action/report_api.dart';
import 'package:Eletor/api/base_model/base_model.dart';
import 'package:Eletor/models/report/elephantCharacteristics.dart';
import 'package:Eletor/models/report/report.dart';
import 'package:Eletor/utils/string_values.dart';
import 'package:Eletor/utils/values.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class CameraViewModel extends BaseViewModel {
  ///camera_view
  File _imagesFile;
  ImagePicker _picker = ImagePicker();

  ///camera_send_mission
  Completer<GoogleMapController> _controllerCompleter = Completer();
  Set<Marker> markers = HashSet<Marker>();
  GoogleMapController mapController;
  double _lat;
  double _lng;
  double _userLat;
  double _userLng;
  LatLng _latLng;
  bool _loading = true;
  LocationResult _pickedLocation;
  List<Marker> _myMarker = [];
  int _check;
  String _apiKey = 'AIzaSyCyThvaSaUxmZGCpKv-T4jfz6SL__hdCtU';
  TextEditingController _textNote = TextEditingController();
  TextEditingController _textElephantAmount = TextEditingController();
  TextEditingController _textLocationName = TextEditingController();
  String _hour, _minute, _time;
  String _dateTime;
  DateTime _selectedDate;
  static TimeOfDay _selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _timeController = TextEditingController();
  List<bool> _isSelected = [false, false, false, false];
  int _maxLengthValue;
  String _showNameLocation;
  bool _valueCheck = false;
  int _timeStampValue;
  List<Placemark> _placemarks;
  int _favoriteLocationValue = 1;
  List<LatLng> _favoriteLocationLatLng = [
    LatLng(14.5444219, 101.3886546),
    LatLng(14.5356633, 101.3657372),
    LatLng(14.5304641, 101.3674171),
    LatLng(14.534946539691443, 101.38555398832288)
  ];

  //ElephantCharacteristics List
  List<String> elpCharacterList = ["eat", "onRoad", "angry", "destroy"];

  ///Global Valuable
  bool get loading => _loading;

  double get lat => _lat;

  double get lng => _lng;

  File get imagesFile => _imagesFile;

  int get check => _check;

  List<Marker> get myMarker => _myMarker;

  TextEditingController get textNote => _textNote;

  TextEditingController get textElephantAmount => _textElephantAmount;

  TextEditingController get textLocationName => _textLocationName;

  TimeOfDay get selectedTime => _selectedTime;

  TextEditingController get timeController => _timeController;

  String get showNameLocation => _showNameLocation;

  bool get valueCheck => _valueCheck;

  int get favoriteLocationValue => _favoriteLocationValue;

  String get dateTime => _dateTime;

  List<bool> get isSelected => _isSelected;

  Completer<GoogleMapController> get controllerCompleter =>
      _controllerCompleter;

  /*CameraViewModel() {
    initState();
    notifyListeners();
  }*/

  initState() async {
    //_selectedTime = null;
    await location();
    localDateTime();
    //timeStamp();
    notifyListeners();
  }

  openGallery(BuildContext context) async {
    try {
      var pickedFile = await _picker.getImage(source: ImageSource.gallery);
      _imagesFile = File(pickedFile.path);
      Navigator.of(context).pop();
      notifyListeners();
    } catch (error) {
      print("Error openGallery: $error");
    }
  }

  openCamera(BuildContext context) async {
    try {
      var pickedFile = await _picker.getImage(source: ImageSource.camera);
      _imagesFile = File(pickedFile.path);
      Navigator.of(context).pop();
      notifyListeners();
    } catch (error) {
      print("Error openCamera: $error");
    }
  }

  location() async {
    try {
      var position = await GeolocatorPlatform.instance
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      ///Global LatLng
      _lat = position.latitude;
      _lng = position.longitude;

      ///User LatLng
      _userLat = position.latitude;
      _userLng = position.longitude;
      _latLng = LatLng(position.latitude, position.longitude);
      loadingValue();
      locationName();
      goToMe();
      print("location() working");
      notifyListeners();
    } catch (error) {
      print("Error location $error");
    }
  }

  loadingValue() {
    _loading = false;
    notifyListeners();
  }

  locationName() async {
    try {
      _placemarks = await placemarkFromCoordinates(_lat, _lng);
      _textLocationName.text = _placemarks[0].street.toString();
      maxLength(_textLocationName);
      await textLocationNameValue(_placemarks[0].street.toString());
      print("locationName :" + _placemarks[0].street.toString());
      notifyListeners();
    } catch (error) {
      print("Error location name: $error");
    }
  }

  textLocationNameValue(String placemarks) {
    textLocationName.text = placemarks;
    notifyListeners();
  }

  favoriteLocation(value, context) {
    try {
      _favoriteLocationValue = value;
      switch (_favoriteLocationValue) {
        case 1:
          {
            location();
            maxLength(_textLocationName);
          }
          break;
        case 2:
          {
            _textLocationName.text = StringValue.favoriteLocationValue1;
            _lat = _favoriteLocationLatLng[0].latitude;
            _lng = _favoriteLocationLatLng[0].longitude;
            maxLength(_textLocationName);
          }
          break;
        case 3:
          {
            _textLocationName.text = StringValue.favoriteLocationValue2;
            _lat = _favoriteLocationLatLng[1].latitude;
            _lng = _favoriteLocationLatLng[1].longitude;
            maxLength(_textLocationName);
          }
          break;
        case 4:
          {
            _textLocationName.text = StringValue.favoriteLocationValue3;
            _lat = _favoriteLocationLatLng[2].latitude;
            _lng = _favoriteLocationLatLng[2].longitude;
            maxLength(_textLocationName);
          }
          break;
        case 5:
          {
            _textLocationName.text = StringValue.favoriteLocationValue4;
            _lat = _favoriteLocationLatLng[3].latitude;
            _lng = _favoriteLocationLatLng[3].longitude;
            maxLength(_textLocationName);
          }
          break;
        default:
          {
            print("favotiteLocation = 6");
          }
          break;
      }
      goToMe();
      notifyListeners();
    } catch (error) {
      print("Error favorite Location: $error");
    }
  }

  pickLocation(context, location) async {
    try{
      LocationResult result = await showLocationPicker(
        context,
        _apiKey,
        initialCenter: LatLng(location.latitude, location.longitude),
        myLocationButtonEnabled: true,
        layersButtonEnabled: true,
        countries: ['TH'],
        desiredAccuracy: LocationAccuracy.best,
      );

      _pickedLocation = result;
      _latLng = _pickedLocation.latLng;
      _lat = _latLng.latitude;
      _lng = _latLng.longitude;
      goToMe();
      int _flValue = 6;
      favoriteLocation(_flValue, context);
      notifyListeners();
    }catch(error){
      print("Error pick location: $error");
    }
  }

  localDateTime() {
    try{
      _selectedDate = DateTime.now();
      _dateTime = DateFormat('dd MMM yyyy').format(_selectedDate);

      _selectedTime = TimeOfDay.now();
      _hour = _selectedTime.hour.toString();
      _minute = _selectedTime.minute.toString();
      _time = _hour + ' : ' + _minute;
      _timeController.text = _time;
      _timeController.text = formatDate(
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
              _selectedTime.hour, _selectedTime.minute),
          [HH, ':', nn]).toString();
      notifyListeners();
    }catch(error){
      print("Error local date time: $error");
    }
  }

  timeStamp() {
    try{
      var sec = (new DateTime.now());
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} ${_selectedTime.hour}:${_selectedTime.minute}:${sec.second} UTC+7";
      final formatter = DateFormat(r'''yyyy-mm-dd hh:mm:ss Z''');

      final dateTimeFromStr = formatter.parse(dateStr);
      _timeStampValue = dateTimeFromStr.toUtc().millisecondsSinceEpoch;
    }catch(error){
      print("Error timestamp: $error");
    }
  }

  maxLength(_textLocationName) {
    try{
      if (textLocationName.text.toString().length > 20) {
        _maxLengthValue = 20;
        _showNameLocation = textLocationName.text.replaceRange(
            _maxLengthValue, textLocationName.text.toString().length, '...');
      } else {
        _maxLengthValue = textLocationName.text.toString().length;
        _showNameLocation = textLocationName.text;
      }
      notifyListeners();
    }catch(error){
      print("Error max length: $error");
    }
  }

  isSelectedValue(int index) {
    for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
      if (buttonIndex == index) {
        _isSelected[buttonIndex] = !_isSelected[buttonIndex];
      }
    }
    notifyListeners();
  }

  goToMe() async {
    try{
      _myMarker = [];
      _myMarker.add(Marker(
          markerId: MarkerId('0'),
          position: LatLng(_lat, _lng),
          draggable: true,
          onDragEnd: (dragEndPosition) {
            print(dragEndPosition);
          }));
      GoogleMapController controller = await _controllerCompleter.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_lat, _lng),
        zoom: 16,
      )));
      locationName();
      notifyListeners();
    }catch(error){
      print("Error go to me: $error");
    }
  }

  selectTime(dateTime) async {
   try{
     print("dateTime $dateTime");
     _selectedTime = dateTime;

     _hour = _selectedTime.hour.toString();
     _minute = _selectedTime.minute.toString();
     _time = _hour + ' : ' + _minute;
     _timeController.text = _time;
     _timeController.text = formatDate(
         DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
             _selectedTime.hour, _selectedTime.minute),
         [HH, ':', nn]).toString();
     print("selectedTime :$_selectedTime $_hour $_minute");
     var sec = (new DateTime.now());
     final dateStr =
         "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} ${_hour}:${_minute}:${sec.second}";
     final formatter = DateFormat(r'''yyyy-mm-dd hh:mm:ss''');
     print("dateStr :$dateStr");
     final dateTimeFromStr = formatter.parse(dateStr);
     _timeStampValue = dateTimeFromStr.toUtc().millisecondsSinceEpoch;

     notifyListeners();
   }catch(error){
     print("Error select time :$error");
   }
  }

  submitValue() async {
    try{
      Report report = new Report();
      if (_textElephantAmount.text == "" ||
          _textNote.text == "" ||
          imagesFile == null ||
          _textLocationName.text == "" ||
          _lat == null ||
          _lng == null) {
        _valueCheck = false;
      } else {
        print("UserLat: $_userLat");
        print("UserLng: $_userLng");
        print("GlobalLat: $_lat");
        print("GlobalLng: $_lng");

        //Initial elephantCharacteristics
        List<ElephantCharacteristics> elephantChaList =
        new List<ElephantCharacteristics>();
        for (int i = 0; i < elpCharacterList.length; i++) {
          elephantChaList.add(ElephantCharacteristics(
              elephantCharacterId: "E${i + 1}",
              elephantCharacterName: elpCharacterList[i],
              active: isSelected[i]));
        }
        //convert to BASE64
        final bytes = Io.File(imagesFile.path).readAsBytesSync();
        String img64 = base64Encode(bytes);

        //get UUID
        String accountId = await getAccountId();
        log(accountId, name: "accountId");

        report
          ..reportId = ""
          ..accountId = accountId
          ..missionId = ""
          ..locationGroupId = ""
          ..timeStamp = _timeStampValue
          ..elephantAmount = int.parse(textElephantAmount.text)
          ..reportDetails = textNote.text
          ..reportStatus = 0
          ..image = img64
          ..locationName = textLocationName.text
          ..pinLat = _lat
          ..pinLng = _lng

        ///TODO: create pinLatLng and userLatLng!
          ..userLat = _userLat
          ..userLng = _userLng
          ..elephantCharacteristicsList = elephantChaList;
        //send report
        ReportApi reportApi = new ReportApi();
        BaseModel<String> res = await reportApi.sendReport(report);
        log('response: ' + res.data.toString());
        //print(report.toJson());
        _valueCheck = true;
      }
      notifyListeners();
    }catch(error){
      print("Error submit value: $error");
    }
  }

  clearData() {
   try{
     _loading = true;
     _myMarker = [];
     _textLocationName = new TextEditingController(text: 'สถานที่เกิดเหตุ');
     _textElephantAmount = new TextEditingController(text: "");
     _textNote = new TextEditingController(text: "");
     _isSelected = [false, false, false, false];
     _imagesFile = null;
     _selectedTime = TimeOfDay.now();
     _favoriteLocationValue = 1;
     _controllerCompleter = Completer();
     notifyListeners();
   }catch(error){
     print("Error clear data: $error");
   }
  }

  getAccountId() async {
   try{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     return await prefs.get(Values.authenicized_key);
   }catch(error){
     print("Error get Account: $error");
   }
  }
}
