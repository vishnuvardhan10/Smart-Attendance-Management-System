# from djongo import models
from pymongo import MongoClient
import certifi

class Authen:
    def __init__(self):
        try:
            self.conn = MongoClient("mongodb+srv://bhanuprakash107:bhanu107@cluster0.9822ypb.mongodb.net/?retryWrites=true&w=majority",tlsCAFile=certifi.where())
            print("Connected successfully!!!")
        except:  
            print("Could not connect to MongoDB")
        # database
        self.db = self.conn.mydatabase
        # Created or Switched to collection names: my_gfg_collection
        self.collection = self.db.model
    def insert(self,name,pas): 
        print("entered Insert")
        r1 = {"name":name,"password":pas}
        # Insert Data
        rec_id1 = self.collection.insert_one(r1)
        print("inserted")
            
    def isvalid(self,name,pas):
        cursor = self.collection.find()
        for record in cursor:
            if record['name']==name and record['password']==pas:
                return True
        return False
    def addreview(self,fname,review):
        r={"fname":fname,"review":review}
        self.collection2.insert_one(r)
    def fetchreview(self):
        reviews=self.collection2.find()
        return reviews
    
obj = Authen()
obj.insert("bhanu","nothing")