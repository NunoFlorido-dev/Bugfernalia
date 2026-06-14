# 1. Import Libraries (MediaPipe for object detection & OpenCV for camera)
try:
    import numpy as np
    import cv2
    import mediapipe as mp
    from mediapipe.tasks import python
    from mediapipe.tasks.python import vision
    from pythonosc import udp_client
    from ultralytics import YOLO

    print("all modules imported!")
    print(f"opencv Version: {cv2.__version__}")
    print(f"mediapipe Version: {mp.__version__}")

except ImportError as e:
    print("import failed!")
    print(f"error details: {e}")

# Function to merge two people too close into one
def merge_detections(detections, merge_dist):
    merged = []
    used = set()

    # Loop through the detections
    for i, (cx, cy) in enumerate(detections):
        if i in used:
            continue

        group = [(cx, cy)]
        used.add(i)

        # Find the detections close to it
        for j, (cx2, cy2) in enumerate(detections):
            if j in used:
                continue
            dist = ((cx2 - cx) ** 2 + (cy2 - cy) ** 2) ** 0.5
            if dist < merge_dist:
                group.append((cx2, cy2)) # Append to the group
                used.add(j)

        avg_x = int(sum(x for x, y in group) / len(group))
        avg_y = int(sum(y for x, y in group) / len(group))
        merged.append((avg_x, avg_y))

    return merged

# 1.2. OSC Configuration
OSC_IP = "127.0.0.1"
OSC_PORT = 8000
osc_client = udp_client.SimpleUDPClient(OSC_IP, OSC_PORT) # Connect to Client
print(f"OSC configuration: {OSC_IP}:{OSC_PORT}")

# 2. Import models from the same directory and create task
# YOLO — handles multi-person detection
# MEDIAPIPE — detects landmarks
yolo = YOLO("yolov8s.pt") # YOLOv8
print("YOLOv8 model loaded")
model_path = "pose_landmarker_full.task"

BaseOptions = mp.tasks.BaseOptions
PoseLandmarker = mp.tasks.vision.PoseLandmarker
PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
VisionRunningMode = mp.tasks.vision.RunningMode

# 3. Define Options of the Pose Landmarker Model
options = PoseLandmarkerOptions(
    base_options=BaseOptions(model_asset_path=model_path),
    running_mode=VisionRunningMode.IMAGE, # Running move for each frame
    output_segmentation_masks=False,
    min_pose_detection_confidence=0.6,
    min_pose_presence_confidence=0.6,
    min_tracking_confidence=0.6,
    num_poses=1 # 1 per crop
)

# 4. Open the built-in webcam and get its FPS
cap = cv2.VideoCapture(0)

# 4.1 Store the tracked people
tracked_people = {}
max_distance = 150 # Max distance between people
next_id = 0
bbox_pad = 20 # Padding around each bounding box 

if not cap.isOpened():
    print("could not open webcam!")
    exit()

video_file_fps = cap.get(cv2.CAP_PROP_FPS)

if video_file_fps == 0 or video_file_fps is None:
    video_file_fps = 30.0 # If it fails to report a correct FPS, fallback to 30
try:
    print("initializing pose landmarker")


# 5. Create the Pose Landmarker
    with PoseLandmarker.create_from_options(options) as detector:
        print("pose landmarker initialized")
        print(f"model file: {model_path}")
        print(f"running mode: {options.running_mode.name}")

        frame_index = 0 # Initialize the frame index counter

        # 6. Read the camera continuosly
        while cap.isOpened():
            success, frame = cap.read() # READ THE CAMERA
            if not success:
                print("ignoring camera")
                continue

            frame_index += 1 # Increase frame index on each frame

            # 7. Invert camera
            frame = cv2.flip(frame, 1)
            h, w = frame.shape[:2] # tuple

            # 8. Run yolo and detect persons (use bytetrack.yaml to handle ID assignment)
            yolo_results = yolo.track(frame, classes=[0], conf=0.5, tracker="bytetrack.yaml", persist=True, verbose=False)[0]

            current_detections = []  # list of (shoulder_mid_x, shoulder_mid_y) in full-frame px

            for box in yolo_results.boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0])

                x1p = max(0, x1 - bbox_pad)
                y1p = max(0, y1 - bbox_pad)

                x2p = min(w, x2 + bbox_pad)
                y2p = min(h, y2 + bbox_pad)

                crop = frame[y1p:y2p, x1p:x2p] # start_row:end_row, start_col:end_col

                if crop.size == 0:
                    continue

                # 9. Run MediaPipe on each person crop
                crop_rgb = cv2.cvtColor(crop, cv2.COLOR_BGR2RGB)
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=crop_rgb)
                result = detector.detect(mp_image)
                
                # Fallback if mediapipe couldnt pose the people (bbox center)
                if not result.pose_landmarks:
                    cx = (x1 + x2) // 2
                    cy = (y1 + y2) // 2
                    current_detections.append((cx, cy))
                    cv2.rectangle(frame, (x1, y1), (x2, y2), (100, 100, 100), 1)
                    continue


                pose = result.pose_landmarks[0] # 1 pose per crop

                # left and right shoulder
                l_shoulder = pose[11]
                r_shoulder = pose[12]

                # width and height of the crop
                crop_w = x2p - x1p
                crop_h = y2p - y1p
                
                # Get the center and remap to full frame coordinates
                mid_x_crop = (l_shoulder.x + r_shoulder.x) / 2
                mid_y_crop = (l_shoulder.y + r_shoulder.y) / 2

                center_x = int(mid_x_crop * crop_w) + x1p
                center_y = int(mid_y_crop * crop_h) + y1p

                # Clamp to frame bounds
                center_x = max(0, min(w - 1, center_x))
                center_y = max(0, min(h - 1, center_y))

                # Append center of the persons' to the array
                current_detections.append((center_x, center_y))

                # Visual Feedback
                cv2.rectangle(frame, (x1, y1), (x2, y2), (255, 180, 0), 2)
                cv2.circle(frame, (center_x, center_y), 8, (0, 255, 0), -1)


            current_detections = merge_detections(current_detections, max_distance)
            
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
            osc_idx = 1
            for pid, (cx, cy) in tracked_people.items():
                # Send pid so that the OSC addresses start with 1, 2, etc...
                osc_client.send_message(f"/person/{osc_idx}/pos", [cx, cy])
                osc_idx += 1

            # 13. Show the camera feed window
            cv2.imshow('preview', frame)

            # 14. Press q to break the loop
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

except RuntimeError as e:
    print("initialization Failed!")
    print(f"error details: {e}")

cap.release()
cv2.destroyAllWindows()
