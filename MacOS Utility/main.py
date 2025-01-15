import sqlite3
import os
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_v1_5 as Cipher_PKCS1_v1_5
from base64 import b64decode,b64encode
import firebase_admin
import certifi
import ssl
import base64
from PIL import Image
from binascii import hexlify as hexa
from Crypto.Util.Padding import pad, unpad
from Crypto.Cipher import AES
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage
from firebase_admin import messaging
from datetime import datetime
import urllib.request
from google.cloud.firestore import ArrayUnion
import time
import threading

# Init firebase
cred = credentials.Certificate("PATH TO CREDENTIALS FILE FOR FIREBASE ADMIN SDK")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Connect to SQLLite DB for iMessage and Contacts
connection = sqlite3.connect("PATH TO IMESSAGE DB")
connection2 = sqlite3.connect("PATH TO CONTACTS DB FILE NAME SIMMILAR TO AddressBook-v22.abcddb")

# Init RSA Keys
pubkey = '''RSA PUBLIC KEY GOES HERE'''
privkey = '''RSA PRIVATE KEY GOES HERE'''

pKeyDER = b64decode(privkey)
rsapriv = RSA.importKey(pKeyDER)
cipher2 = Cipher_PKCS1_v1_5.new(rsapriv)

keyDER = b64decode(pubkey)
keyPub = RSA.importKey(keyDER)
cipher = Cipher_PKCS1_v1_5.new(keyPub)

# AES Key
aes_bytes = bytearray([])
iv = bytearray([])

# Global variable to track previous message
prevmsgid = ""

# Global variable to track cut off date for importing old messages
FD = 664184493430000128


# Callback everytime user application sends new message
def on_snapshot(col_snapshot, changes, read_time):
    if changes[0].type.name == 'MODIFIED':
        firemsg = col_snapshot[0].to_dict()

        if firemsg["NMsg"] == True:

            # Are we creating a new chat
            if firemsg["newR"] == False:

                ### NO ###

                if firemsg["guid"] != "":

                    # Check if new message has image
                    if firemsg["hasImg"] == False:
                        
                        ### NO ### 

                        # Decrypt message
                        msg = cipher2.decrypt(b64decode(firemsg["Msg"]), sentinel="")

                        # Reset database state (document) polling for message
                        db.collection('User').document('sentChats').update({
                            "NMsg": False,
                            "Msg": "",
                            "guid": "",
                            "newC": "",
                            "newR": False,
                            "hasImg": False,
                            "imgURL": ""
                        })

                        print(msg.decode("utf-8"))

                        # Send message
                        os.system(f'./mesgid "{firemsg["guid"]}" "{msg.decode("utf-8")}"')

                    else:
                        ### YES ### 

                        # Remove placeholder image file
                        os.remove("photo.jpg")

                        # Decrypt image data and save bytes to file
                        Cipher4 = AES.new(aes_bytes, AES.MODE_CBC,iv)
                        with urllib.request.urlopen(firemsg["imgURL"],
                                                    context=ssl.create_default_context(cafile=certifi.where())) as f:
                            html = f.read().decode('utf-8')

                        Decrypting = Cipher4.decrypt(base64.b64decode(html))

                        with open('photo.jpg', 'wb') as imagefile:
                            imagefile.write(base64.b64decode(Decrypting))

                        # Reset database state (document) polling for message
                        db.collection('User').document('sentChats').update({
                            "NMsg": False,
                            "Msg": "",
                            "guid": "",
                            "newC": "",
                            "newR": False,
                            "hasImg": False,
                            "imgURL": ""
                        })
                        
                        # Send message
                        os.system(f'./sf "{firemsg["guid"]}" "/Users/YOUR USERNAME HERE/PATH TO PROJECT"')



            else:
                ### YES ###

                # Decrypt message
                msg = cipher2.decrypt(b64decode(firemsg["Msg"]), sentinel="")

                # Send message to new recipient (using phone number not chat id)
                os.system(f'./mesg "{firemsg["newC"]}" "{msg.decode("utf-8")}"')

                # Reset database
                db.collection('User').document('sentChats').update({
                    "NMsg": False,
                    "Msg": "",
                    "guid": "",
                    "newC": "",
                    "newR": False,
                    "hasImg": False,
                    "imgURL": ""
                })


# Function finds contact name for phone number
def getPhone(phone):
    cur2 = connection2.cursor()
    cur2.execute('SELECT ZOWNER FROM ZABCDPHONENUMBER WHERE ZLASTFOURDIGITS = {}'.format(f'"{phone}"'))

    row = cur2.fetchall()[0][0]

    cur2.execute('SELECT Z_PK FROM ZABCDCONTACTINDEX WHERE ZCONTACT = {}'.format(row))

    Z_PK = cur2.fetchall()[0][0]

    cur2.execute('SELECT ZFIRSTNAME, ZLASTNAME FROM ZABCDRECORD WHERE ZCONTACTINDEX = {}'.format(Z_PK))

    FullName = cur2.fetchall()[0]

    FullName = list(FullName)

    if FullName[1] == None:
        FullName[1] = ""

    return FullName

# Creates callback function
db.collection('User').document('sentChats').on_snapshot(on_snapshot)

# Infinite loop
while True:
    try:

        # Create SQLite DB for new messages
        cur = connection.cursor()
        cur.execute('''SELECT
                        text, date, is_from_me, ROWID, handle_id, cache_has_attachments

                        FROM
                        message WHERE date > {}

        '''.format(FD))

        rows = cur.fetchall()

        # Check if new messages exist
        if len(rows) > 0:
            group = []

            # Iterate over each row (new message)
            for row in rows:

               if FD < row[1]:
                   
                   # Update timestamp of last processed message
                   FD = row[1]

                   # query who sent message using handle_id and the handle table
                   cur.execute('''SELECT chat_id FROM chat_message_join WHERE message_id={}'''.format(row[3]))
                   chat = cur.fetchall()

                   cur.execute('''SELECT guid, chat_identifier FROM chat WHERE ROWID={}'''.format(chat[0][0]))
                   details = cur.fetchall()
                   cur.execute('''SELECT id FROM handle WHERE ROWID={}'''.format(row[4]))
                   sentby = cur.fetchall()[0][0]

                   cur.execute('''SELECT handle_id FROM chat_handle_join WHERE chat_id={}'''.format(chat[0][0]))
                   mem = cur.fetchall()

                   for im in mem:
                       cur.execute('''SELECT id FROM handle WHERE ROWID={}'''.format(im[0]))
                       group.append(cur.fetchall()[0][0])

                   text = row[0]
                   date = datetime.fromtimestamp(row[1] / 1000000000.0 + 978307200).strftime("%Y-%m-%d %I:%M %p")
                   sentByMe = row[2]
                   msgid = row[3]
                   guid = details[0][0]
                   cid = chat[0][0]
                   chatsent = details[0][1]
                   urlA = ''
                   himg = row[5]
                   FirstName = []
                   LastName = []
                   FullName = []

                   # If there is an image, we encrypt it and upload it to firebase storage
                   if(row[5] == 1):
                       Cipher3 = AES.new(aes_bytes, AES.MODE_CBC,iv)
                       cur.execute('''SELECT attachment_id FROM message_attachment_join WHERE message_id={}'''.format(msgid))

                       att = cur.fetchall()[0]

                       cur.execute(f'SELECT filename FROM attachment WHERE ROWID={att[0]}')

                       imgDir = cur.fetchall()[0][0]
                       myDir = imgDir.replace('~', '/Users/YOUR USERNAME HERE')
                       imgPIL = Image.open(myDir)
                       try:
                           imgPIL.verify()
                           with open(myDir, "rb") as imageFile:
                               imgstr = base64.b64encode(imageFile.read())

                           imgenc = Cipher3.encrypt(pad(imgstr, 16))
                           hexver = hexa(imgenc).decode()
                           f = open(f"{msgid}.text", "a")
                           f.write(hexver)
                           f.close()
                           
                           bucket = storage.bucket('chat-5655a.appspot.com')
                           blob = bucket.blob(f'/{guid}/assets/{msgid}.text')

                           blob.upload_from_filename(f'{msgid}.text')
                           blob.make_public()
                           os.remove(f'{msgid}.text')
                           urlA = blob.public_url
                       except:
                           himg = 0


                   cm = db.collection('User').document('ChatData').collection(guid).get()

                   
                   # Check if chat exists in FireStore
                   if len(cm) == 0:

                       ### NO ###


                       for element in group:
                           element = element.replace('+', '')
                           if element.isdecimal():
                               NametoAdd = getPhone(element[-4:])
                               if (len(NametoAdd) == 0):
                                   FirstName.append("")
                                   LastName.append("")
                                   FullName.append("")
                               else:
                                   FirstName.append(NametoAdd[0])
                                   LastName.append(NametoAdd[1])
                                   FullName.append(NametoAdd[0] + ' ' + NametoAdd[1])
                           else:
                               FirstName.append("")
                               LastName.append("")
                               FullName.append("")

                       chatsentM = chatsent
                       chatsentM = chatsentM.replace('+', '')
                       if chatsentM.isdecimal():
                           sentByName = getPhone(chatsent[-4:])
                       else:
                           sentByName = ['','']

                       # Encrypt the message
                       cipher_text = cipher.encrypt(text.encode())
                       emsg = b64encode(cipher_text)

                       # Create new collection with chat details (last message, is it read, names of participants)
                       db.collection('User').document('Chats').collection('prevdata').document(guid).set({
                           "guid": guid,
                           "users": ArrayUnion(group),
                           "chatID": cid,
                           "LastMSG": emsg.decode('utf-8'),
                           "Date": date,
                           "Date24": datetime.fromtimestamp(row[1]/1000000000.0 + 978307200).strftime("%Y-%m-%d %H:%M %p"),
                           "isRead": False,
                           "firstName": ArrayUnion(FirstName),
                           "lastName": ArrayUnion(LastName),
                           "FullName": ArrayUnion(FullName)
                       })

                       # Add to collection document with individual messages 
                       db.collection('User').document('ChatData').collection(guid).document().set({
                           "text": emsg.decode('utf-8'),
                           "date": date,
                           "sentByMe": sentByMe,
                           "sentBy": chatsent,
                           "messageID": msgid,
                           "hasImg": himg,
                           "assetURL": urlA,
                           "sentByName": sentByName[0] + ' ' + sentByName[1]
                       })
                       prevmsgid = msgid

                       topic = 'msg'

                       # send push notification
                       message = messaging.Message(
                           notification = messaging.Notification(
                               title = chatsent,
                               body =  text,
                           ),
                           android=messaging.AndroidConfig(priority='high'),
                           topic=topic,
                           data={"guid": guid, "contact":''.join([str(elem) for elem in group])},

                       )
                       response = messaging.send(message)
                       print("sent")
                       print(response)

                   else:
                       
                       ### YES ###

                       if(prevmsgid != msgid):
                           chatsentM = chatsent
                           chatsentM= chatsentM.replace('+','')
                           if chatsentM.isdecimal():
                               sentByName = getPhone(chatsent[-4:])
                           else:
                               sentByName = ['', '']

                           # Encrypt message
                           cipher_text = cipher.encrypt(text.encode())
                           emsg = b64encode(cipher_text)

                           # Update last message status (time and read)
                           db.collection('User').document('Chats').collection('prevdata').document(guid).update({
                               "LastMSG": emsg.decode('utf-8'),
                               "Date": date,
                               "Date24": datetime.fromtimestamp(row[1] / 1000000000.0 + 978307200).strftime(
                                   "%Y-%m-%d %H:%M %p"),
                               "isRead": False
                           })

                           # Add message to chat collection
                           db.collection('User').document('ChatData').collection(guid).document().set({
                               "text": emsg.decode('utf-8'),
                               "date": date,
                               "sentByMe": sentByMe,
                               "sentBy": chatsent,
                               "messageID": msgid,
                               "hasImg": himg,
                               "assetURL": urlA,
                               "sentByName": sentByName[0] + ' ' + sentByName[1]
                           })

                           prevmsgid = msgid

                           topic = 'msg'

                           # Send push notification
                           message = messaging.Message(
                               notification= messaging.Notification(
                                   title = chatsent,
                                   body = text,
                           ),
                               android=messaging.AndroidConfig(priority='high'),
                               topic=topic,
                               data={"guid": guid, "contact": ''.join([str(elem) for elem in group])},
                           )
                           response = messaging.send(message)
                           print("sent")
                           print(response)

                   group = []


        print("done")
        time.sleep(0.2)

    except Exception as e:
        print("error")
        print(e)





