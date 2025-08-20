
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _urlController = TextEditingController(text: 'https://c.pxhere.com/photos/10/ab/highway_travel_ride_reindeer_autos_traffic_vehicles_motor_vehicles_multi_track-1393510.jpg!d');
  File? _image;
  bool _loading = false;
  List<Detection> _detections = [];

  String get _baseUrl => Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://127.0.0.1:5000';


  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission denied")),
        );
        return;
      }
    } else {
      if (Platform.isIOS) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Photo library permission denied")),
          );
          return;
        }
      }
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _detections.clear();
      });
    }
  }


  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _loading = true;
      _detections.clear();
    });

    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$_baseUrl/predict"),
      );
      request.files.add(await http.MultipartFile.fromPath("file", _image!.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        _setDetectionsFromBody(respStr);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }

    setState(() {
      _loading = false;
    });
  }


  Future<void> _analyzeUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an image URL')),
      );
      return;
    }
    setState(() {
      _loading = true;
      _detections.clear();
    });
    try {
      // Try common payload keys different servers may expect
      final payloads = <Map<String, String>>[
        {"url": url},
        {"image_url": url},
        {"imageUrl": url},
        {"image": url},
      ];
      bool parsed = false;
      String? lastBody;
      int? lastStatus;
      for (final body in payloads) {
        final res = await http.post(
          Uri.parse('$_baseUrl/predict'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
        lastStatus = res.statusCode;
        lastBody = res.body;
        if (res.statusCode == 200) {
          _setDetectionsFromBody(res.body);
          if (_detections.isNotEmpty) {
            parsed = true;
            break;
          } else {
            // If parsed but empty, keep trying other payload keys
            continue;
          }
        }
      }
      if (!parsed) {
        debugPrint('Predict returned status=$lastStatus body=$lastBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No detections parsed. Status: ${lastStatus ?? '-'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  void _setDetectionsFromBody(String body) {
    try {
      final decoded = json.decode(body);
      final List list = (decoded is Map && decoded['detections'] is List)
          ? decoded['detections'] as List
          : (decoded is List ? decoded : const []);

      
      final Map<int, String> classNames = {};
      if (decoded is Map && decoded['names'] != null) {
        final names = decoded['names'];
        if (names is List) {
          for (var i = 0; i < names.length; i++) {
            final v = names[i];
            if (v != null) classNames[i] = v.toString();
          }
        } else if (names is Map) {
          names.forEach((k, v) {
            final idx = int.tryParse(k.toString());
            if (idx != null) classNames[idx] = v.toString();
          });
        }
      }

      const labelKeys = ['name', 'label', 'class', 'class_name', 'category', 'object', 'type', 'tag', 'detected_class', 'detected_object'];

      final parsed = list.map((e) {
        final map = e as Map;
        String? label;
        for (final k in labelKeys) {
          if (map.containsKey(k) && map[k] != null && map[k].toString().isNotEmpty) {
            label = map[k].toString();
            break;
          }
        }
        // If label is numeric or missing, map via class index when available
        if ((label == null || RegExp(r'^\d+$').hasMatch(label)) && map['class'] != null) {
          final dynamic cls = map['class'];
          final int? idx = (cls is num) ? cls.toInt() : int.tryParse(cls.toString());
          if (idx != null && classNames.containsKey(idx)) {
            label = classNames[idx];
          }
        }
        label ??= 'unknown';

        final dynamic confRaw = map['confidence'] ?? map['score'] ?? 0;
        double confidence;
        if (confRaw is num) {
          confidence = confRaw.toDouble();
        } else {
          confidence = double.tryParse(confRaw.toString()) ?? 0.0;
        }
        if (confidence > 1.0) confidence = confidence / 100.0; // Normalize 0..1
        return Detection(name: label, confidence: confidence);
      }).cast<Detection>().toList();
      setState(() => _detections = parsed);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected response from server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Object Detection"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            tooltip: 'Change server',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Using server: $_baseUrl')),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 16),

           
            _image != null
                ? Image.file(
                    _image!,
                    height: 200,
                  )
                : const Text("No image selected"),

            const SizedBox(height: 16),

            
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _loading ? null : _analyzeUrl,
                icon: const Icon(Icons.link),
                label: const Text('Analyze URL'),
              ),
            ]),

            const SizedBox(height: 16),

            
            ElevatedButton(
              onPressed: _image == null || _loading ? null : _analyzeImage,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Analyze"),
            ),

            const SizedBox(height: 16),

            
            Expanded(
              child: _detections.isEmpty
                  ? const Center(child: Text("No detections yet"))
                  : ListView.builder(
                      itemCount: _detections.length,
                      itemBuilder: (context, index) {
                        final d = _detections[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(d.name),
                            subtitle: Text('Confidence: ${(d.confidence * 100).toStringAsFixed(1)}%'),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class Detection {
  final String name;
  final double confidence;
  Detection({required this.name, required this.confidence});
}
