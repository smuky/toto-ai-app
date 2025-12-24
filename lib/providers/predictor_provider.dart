import 'package:flutter/material.dart';
import '../models/predictor.dart';

class PredictorProvider extends ChangeNotifier {
  Predictor _selectedPredictor = Predictor.gptPredictor;

  Predictor get selectedPredictor => _selectedPredictor;

  void selectPredictor(Predictor predictor) {
    if (_selectedPredictor.id != predictor.id) {
      _selectedPredictor = predictor;
      notifyListeners();
    }
  }
}
