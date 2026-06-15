# Bugfernalia

Generative Design Course — MDM @ FCTUC 2026

By Nuno Flórido & Salomé Monteiro

# How to initialize and start the system?

0. Download Python

1. On the same directory as the python files (dg_tp2_python), install the following dependencies (inside the terminal):

> pip install opencv-python mediapipe python-osc ultralytics numpy

2. Run the script

> python dg_tp2_human_tracker.py

A window called preview, that shows the camera feed, will open. To close it, press Q to quit.

Some notes:
- On the first run, the YOLOv8 model will be downloaded automatically, so the first launch may take a while
- The preview window shows the bounding boxes, for each detected person, and the person's midpoint between their shoulders
- Processing must be on port 8000 to match what the Python script sends to

Possible problems:
- could not open webcam! → your webcam index might not be 0, try changing cv2.VideoCapture(0) to 1 or 2
- pose_landmarker_full.task not found → the .task file must be in the exact same directory as the script
- MediaPipe version issues → the mp.tasks API requires mediapipe 0.10+, so make sure you're not on an older version

3. Open and Play the Processing sketch (dg_tp2_sketch/dg_tp2_skech.pde) while the Python script is running