import pickle

# cv2 is used for face recognition in python
import cv2
import pymongo
import certifi
# mediapipe is google's face detection module
# face recognition is a python module which is used to return the face 
# encodings of the detected faces
import face_recognition

import os
import time

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
# print(classNames)

# This function is ised to retrieve the Face encodings of the detected faces

def findEncodings(images):
    encodeList = []
    for img in images:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        # print(face_recognition.face_encodings(img))
        encode = face_recognition.face_encodings(img)[0]
        # print(encode)
        encodeList.append(encode)
    return encodeList
encodeListknown = (findEncodings(images))

for i in range(len(encodeListknown)):
    encodeListknown[i] = encodeListknown[i].tolist()


# print(encodeListknown)

mongo_server = pymongo.MongoClient("mongodb+srv://bhanuprakash107:bhanu107@cluster0.9822ypb.mongodb.net/?retryWrites=true&w=majority",tlsCAFile=certifi.where())

mydatabase = mongo_server["mydatabase"]
mycols = mydatabase["model"]

mycols.delete_one({"_id":1})

d = {
    "_id":1,
    "model":encodeListknown
}

mycols.insert_one(d)
print("inserted")

mongo_server.close()

# with open("pickle_file.pkl","wb") as fl:

#     pickle.dump(encodeListknown, fl)

