# 1. Import Libraries (MediaPipe for object detection & OpenCV for camera)
try:
    import numpy as np
    import cv2
    import mediapipe as mp
    from mediapipe.tasks import python
    from mediapipe.tasks.python import vision
    from pythonosc import udp_client

    print("all modules imported!")
    print(f"opencv Version: {cv2.__version__}")
    print(f"mediapipe Version: {mp.__version__}")

except ImportError as e:
    print("import failed!")
    print(f"error details: {e}")

# 1.2. OSC Configuration
OSC_IP = "127.0.0.1"
OSC_PORT = 8000
osc_client = udp_client.SimpleUDPClient(OSC_IP, OSC_PORT) # Connect to Client
print(f"OSC configuration: {OSC_IP}:{OSC_PORT}")

# 2. Import Model from the same directory and create task
model_path = 'efficientdet_lite0.tflite'

BaseOptions = mp.tasks.BaseOptions # Use Base Options
ObjectDetector = mp.tasks.vision.ObjectDetector # Use Object Detector
ObjectDetectorOptions = mp.tasks.vision.ObjectDetectorOptions # Get Object Detector Options
VisionRunningMode = mp.tasks.vision.RunningMode # Get Running Mode

# 3. Define Options of the Object Detector Model
options = ObjectDetectorOptions(
    base_options=BaseOptions(model_asset_path=model_path),
    max_results=10, # MAX NUMBER OF TOP SCORED DETECTION RESULTS TO RETURN!
    running_mode=VisionRunningMode.VIDEO)


# 4. Open the built-in webcam and get its FPS
cap = cv2.VideoCapture(0)

# 4.2 Store the tracked people
tracked_people = {}
max_distance = 150 # Max distance between people
next_id = 0

if not cap.isOpened():
    print("could not open webcam!")
    exit()

video_file_fps = cap.get(cv2.CAP_PROP_FPS)

if video_file_fps == 0 or video_file_fps is None:
    video_file_fps = 30.0 # If it fails to report a correct FPS, fallback to 30
try:
    print("initializing object detector")

# 5. Create the Object Detector
    with ObjectDetector.create_from_options(options) as detector:
        print("object Detector initialized")
        print(f"model file: {model_path}")
        print(f"running mode: {options.running_mode.name}")
        print(f"max results configuration: {options.max_results}")

        frame_index = 0 # Initialize the frame index counter

        # 6. Read the camera continuosly
        while cap.isOpened():
            success, frame = cap.read() # READ THE CAMERA
            if not success:
                print("ignoring camera")
                continue

            frame_index += 1 # Increase frame index on each frame

            # 7. Convert OpenCV's BGR to MediaPipe's RGB
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            # 7.2 Invert camera
            frame_rev = cv2.flip(frame, 1)

            # 8. Convert the frame received from the OpenCV to a MediaPipe's Image Object
            frame_mp = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame_rev)

            frame_timestamp_ms = int(1000 * frame_index / video_file_fps)

            # 9. Perform object detection on the video frame
            detection_result = detector.detect_for_video(frame_mp, frame_timestamp_ms)

            person_count = 0 # Count how much people there are

            current_detections = [] # Array to store the current detection

            # 10. Loop through all the detections
            for detection in detection_result.detections:
                category = detection.categories[0]

            # 11. Detect if the detection is a person
                if category.category_name == "person" and category.score >= 0.5:
                        person_count += 1
                    # 12. Get bounding box of a person, get its center and draw a circle in it
                        bbox = detection.bounding_box
                        center_x = int(bbox.origin_x + bbox.width / 2)
                        center_y = int(bbox.origin_y + bbox.height / 2)
                        current_detections.append((center_x, center_y))

                        cv2.rectangle(frame, (bbox.origin_x, bbox.origin_y), (bbox.origin_x + bbox.width, bbox.origin_y + bbox.height), (255, 0, 0), 2)
                        cv2.circle(frame, (center_x, center_y), 5, (0, 0, 255), -1)


                
            # 13. Match detections to tracked people by nearest distance
            new_tracked = {}
            used_detections = set()

            # 14. Loop through each person we were already tracking from the previous frame
            for pid, (px, py) in tracked_people.items():
                best_dist = max_distance
                best_idx = -1

                 # Compare this tracked person against all current detections
                for i, (cx, cy) in enumerate(current_detections):
                    if i in used_detections:
                        continue

                    # Calculate euclidean distance between tracked position and current detection
                    dist = ((cx - px) ** 2 + (cy - py) ** 2) ** 0.5

                    # If this detection is closer than our current best, update it
                    if dist < best_dist:
                        best_dist = dist
                        best_idx = i

                # If we found a close enough match, keep this person's ID with the new position
                if best_idx >= 0:
                    new_tracked[pid] = current_detections[best_idx]
                    used_detections.add(best_idx)

            # Any detection not matched to an existing person is a new person entering the frame
            for i, (cx, cy) in enumerate(current_detections):
                if i not in used_detections:
                    new_tracked[next_id] = (cx, cy)
                    next_id += 1
            
            tracked_people = new_tracked

            # Send total person count via OSC   
            person_count = len(tracked_people)
            osc_client.send_message("/person_count", person_count) # Send number of people

            # Send each person's position via OSC with a sequential index
            for i, (pid, (cx, cy)) in enumerate(tracked_people.items()):
                osc_client.send_message(f"/person/{i+1}/pos", [cx, cy])

            # 13. Show the camera feed window
            cv2.imshow('preview', frame)

            # 14. Press q to break the loop
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

except RuntimeError as e:
    print("initialization Failed!")
    print(f"error details: {e}")

cap.release()
cv2.AllWindows()