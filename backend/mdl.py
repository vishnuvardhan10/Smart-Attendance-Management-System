# cv2 is used for face recognition in python
import cv2
import pickle

# mediapipe is google's face detection module
# face recognition is a python module which is used to return the face 
# encodings of the detected faces
import face_recognition
import numpy as np

import os

from datetime import datetime
# Load the input image

path = 'ImagesAttendance'
images = []
classNames = []
myList = os.listdir(path)
# print(myList)

# Removing extra information which is not needed for the 
# program to run

try:
    myList.remove(".DS_Store")
except:
    pass

for cl in myList:
    curImg = cv2.imread(f'{path}/{cl}')
    images.append(curImg)
    classNames.append(os.path.splitext(cl)[0])



# It is used to extract the names of the people that is given as input


import smtplib
# import ssl
# from email.message import EmailMessage

# Define email sender and receiver

def send_email(content):
    email_sender =  'boyapallib@gmail.com'
    email_password = 'keya amyk jblf tyez'
    email_receiver = 'boyapallib@gmail.com'

    # Set the subject and body of the email
    body = content
    subject = "Attendance Report"
    msg = f'Subject : {subject} \n\n {body}'

    # Add SSL (layer of security)

    # Log in and send the email
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
        smtp.ehlo()
        smtp.starttls()
        smtp.ehlo()
        smtp.login(email_sender, email_password)
        smtp.sendmail(email_sender, email_receiver, msg)
    
    print("Successfull email sent")

# get trained images

encodeListknown = []

with open("pickle_file.pkl","rb") as fl:
    encodeListknown = pickle.load(fl)


interval = 2 # interval of 2 secs

images = []
# for _ in range(5):
#     print('Iteration Number:' , _)

#     cap = cv2.VideoCapture(1)
#     cap.set(cv2.CAP_PROP_EXPOSURE, 0.1)
#     cap.set(cv2.CAP_PROP_ISO_SPEED, 800)
#     # Increase brightness by 50 units
#     cap.set(cv2.CAP_PROP_FRAME_WIDTH, cap.get(cv2.CAP_PROP_FRAME_WIDTH))
#     cap.set(cv2.CAP_PROP_FRAME_HEIGHT, cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

#     ret, image = cap.read()
#     # brightness = 40
#     # contrast = 4.0

#     # enhanced_image = cv2.convertScaleAbs(image, alpha = contrast , beta=brightness)

#     # cv2.imwrite('captured_image.jpg', image)

#     # Add a delay to give the camera time to adjust to the lighting conditions
#     cv2.waitKey(1000)

#         # Save the captured image
#     cv2.imwrite('captured_image.jpg', image)

#     path = "captured_image.jpg"
#     image = cv2.imread(path)
#     images.append(image)

    
#     time.sleep(interval)

# print("Length of Images :" ,len(images))

# # comment this
capture_path = "uploads"
test_list = os.listdir(capture_path)
try:
    test_list.remove(".DS_Store")
except:
    pass
# print(test_list)
for i in test_list:
    image = cv2.imread(f'{capture_path}/{i}')
    images.append(image)
s = set()

def markAttendance(name):

    with open('Attendance.csv', 'r+') as f:
        myDataList = f.readlines()
        nameList = []
        for line in myDataList:
            entry = line.split(',')
            nameList.append(entry[0])
        if name not in nameList:
            now = datetime.now()
            dtString = now.strftime('%H:%M:%S')
            f.writelines(f'\n{name},{dtString}')


# Detect faces in the input image
for image,photo_name in zip(images,test_list):
    face_locations = face_recognition.face_locations(image)

    # Extract face encodings for each detected face
    if face_locations:
        face_encodings = face_recognition.face_encodings(image, face_locations)

        # Do something with the face encodings
        print(("{0} contains {1} faces").format(photo_name,len(face_encodings)))
        person_names = []
        for encodeFace, faceLoc in zip(face_encodings, face_locations):
            matches = face_recognition.compare_faces(encodeListknown, encodeFace, tolerance=0.5)
            faceDis = face_recognition.face_distance(encodeListknown, encodeFace)
            matchIndex = np.argmin(faceDis)
            name = "Unknown"
            # print(matches)
            if matches[matchIndex]:
                name = classNames[matchIndex][:-1]
                # print(name)
                s.add(name)
            person_names.append(name)
        
        # Draw a rectangle around each detected face
        idx = 0
        for (y1,x2,y2,x1) in face_locations:
            cv2.rectangle(image, (x1, y1), (x2, y2), (0, 255, 0), 2)
            cv2.rectangle(image, (x1, y2 - 35), (x2, y2), (0, 255, 0), cv2.FILLED)
            cv2.putText(image, person_names[idx], (x1 + 6, y2 - 6), cv2.FONT_HERSHEY_COMPLEX, 1 , (255, 255, 255), 2)
            idx += 1
    print("\n")
print(s)
for name in s:
    markAttendance(name)

absentees = []
for name in classNames:
    name = name[:-1]
    if (name not in s) and (name not in absentees):
        absentees.append(name)

string = "Absentees list : \n\n"+"\n".join(absentees)

# send_email(string)


# Display the output image
# cv2.imshow('Output Image', image)
# cap.release()
cv2.waitKey(0)
cv2.destroyAllWindows()