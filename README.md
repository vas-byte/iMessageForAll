
# iMessageForAll

Run iMessageForAll on Non-Apple products.




## Features

- Send/Recieve Messages
- Send/Recieve Pictures (only applies to existing conversations)
- Start/Receive new conversations
- E2E Encrypted
- Dark Mode





## Platform Support

### MacOS Utility 
- Developed and tested on MacOS Sierra
- Should work for MacOS Sequoia

### Flutter Application
Platform  | Support
------------- | -------------
Android  | ✅
Windows  | Untested
Linux  | Untested
Web  | Untested

## Run Locally

### Clone repository
```
git clone https://github.com/vas-byte/iMessageForAll.git
```

### Setup Firebase
Create new Project in Firebase
![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/New%20Project.png)

Enable Firebase Authentication

Enable email/password Authentication
![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/email%3Apassword.png)

Add User
![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/create%20user.png)

Enable Firestore
![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/firestore.png)

Enable Firebase Storage
![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/storage.png)

[Add Firebase project to Flutter](https://firebase.google.com/docs/flutter/setup?hl=en&authuser=0&_gl=1*1055xio*_ga*MTMzNjA2MTE4OC4xNzM0MjQ5Mjg1*_ga_CW55HF8NVT*MTczNjgzNjM5OC42LjEuMTczNjgzNjY2OS41NC4wLjA.&platform=ios)

Retrieve Credentials Service Account for MacOS Utility
![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/service%20account.png)

Place Credentials in MacOS Utility folder

Update Path to service account JSON file
![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/credentials.png)

### Setup E2E Encryption
[Generate two sets of RSA Keys](https://cryptotools.net/rsagen)

Key 1
```
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCdh9Ml9NN31mHVaHo99xJDj4QxUOfihJm4L/k7htCLs7J5Agt5
cMpzb2PbDFq6sb4uG9dvTj5Ld94Sun/XLQwZCo8809yuvoEmJCClSCh3pfH3AHYf
4Z3ytMRD7h/VC+UOIl8q6qb/sjjKZMdkOLnGZyg4sckIge+1Q2TFnVM6hwIDAQAB
AoGAd6/XxFHkTXuLr3oGzoemz7/9vv5qgBchN+jzIsAGOO5Z3kiocSc6GkR6iNY1
JP2gsiWjJEU9XVeAWZhrQxBNzJCHoTgnAUcfGVE/UgkHg/u3atYW+EXirhLXL54C
u4U9MuYaVZycbq79/amuYF2LmGM5QWvaSoXn0twHuYeEY8kCQQDnv5iO3HVlbTea
s5vSs2xMTe8YQKqFp3XW4pV6G1DCBjHQMg1lONRIqAGABX5561oKsFS5QAlT9xVG
mJu5pjfVAkEArgP54iIAAv7RxQFHgIYH9KnyFwlhXZKCswxWGrYztEaplyPmAYKI
XqhNgSJwtFLOe8p2HH6pL3h9axHm/A0S6wJAKuv3a241aAWkaMifMZT9l9xPTiSb
8IklcBkjKixo9qaDD1ZV2Mt/tb04GefqltYaJSSnbHAJyj1W+W5GWUoJyQJAG4eF
gMDgP5kQlpodNbf+ijZYlkxlmugSxUCuXot0opCLQ93qBVMhP9hgao2IRv7Sq8Lb
7KYdHeVx8f5jDH0FAQJBAJv6LwdJmglB4NdJIYm/6HTAACoHRbTu/QfXxZXP+7Wd
7b7Q88DmoBe0tNfrMjG3uFIU5AdjyI6xuM/fcJIMRhQ=
-----END RSA PRIVATE KEY-----

-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCdh9Ml9NN31mHVaHo99xJDj4Qx
UOfihJm4L/k7htCLs7J5Agt5cMpzb2PbDFq6sb4uG9dvTj5Ld94Sun/XLQwZCo88
09yuvoEmJCClSCh3pfH3AHYf4Z3ytMRD7h/VC+UOIl8q6qb/sjjKZMdkOLnGZyg4
sckIge+1Q2TFnVM6hwIDAQAB
-----END PUBLIC KEY-----
```

Key 2
```
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQCzmRCq0Fo23EU4EIJxSZPIxlJOzC4SnWSu0PqYFsRUPEEcWlzU
SSOvtlMC0B5sqAeKf/ziWr/vuN+RWe7S7uACGwD6tEXAjjh0f9hJSBbADkgiCDgv
y54xm+3pmAGLaZeMDBI7xFV+TNlGb91HRkFLyQFMnE+h1bWc3Wfim0pCeQIDAQAB
AoGAa0Xs76o9iHEvIxqxX0tsa0sSFKDekB3U6ppGZBuNLydCWNYchmwdVbHYiWCY
G5yNzItAGE/OPzi0yRPnk7Q8teTyr6SVlKKxS5IAkaiyCKSEG4FTLl1kQ6SPWhH+
tee1isEPTzvlPIF5MFc5NZs1abyv1S0Nb2dpT8ZGAYvGixECQQDdn8mPJoUXsYur
7Zl8kiIJ26eAOVunpZFyLrn6KVYPmkRkayhSlB5isV43+HXtQyywDQHcdcGYw8e4
WPUMQmX1AkEAz3SBs0n7Pz11m51jfK0mDeoj+WxuVqMp2KxQiR1oE/IAlUTVVaui
P+hXccEXjlnFOiB7c7RO833a0vI4L4eT9QJBAL6GwMvNDLw6yV1r7Pi31IVvDYfh
R5dPckOcQgv6/154e/VsXgToC1tDKkGp2w+3ITLUa9Ywcde37/nemAQLDQUCQDPJ
ebcv+LBIv1shZvxwnNdMY76X+tNV19Rm75PK63hPKSYaEMdaGR6q+WlEMoUuk7V2
9lpj4HGYMVAHd08mISECQQCfcyoEUbt68Klvv+mDktPlJpPC4RpeSDi7uMZNpbAE
GF0LwO8RFDZW3oFSCjwvE0ahu8xX11HR5JXfM+JtID+3
-----END RSA PRIVATE KEY-----

-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCzmRCq0Fo23EU4EIJxSZPIxlJO
zC4SnWSu0PqYFsRUPEEcWlzUSSOvtlMC0B5sqAeKf/ziWr/vuN+RWe7S7uACGwD6
tEXAjjh0f9hJSBbADkgiCDgvy54xm+3pmAGLaZeMDBI7xFV+TNlGb91HRkFLyQFM
nE+h1bWc3Wfim0pCeQIDAQAB
-----END PUBLIC KEY-----
```
Remove from the key data

```
-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----
-----BEGIN PUBLIC KEY-----
-----END PUBLIC KEY-----
```


Select a public and private key from each key pair above and update the variables ```pubkey``` and ```privkey``` in ```main.py``` of MacOS Utilities      

![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/RSA%20Python.png)

Using the other pair, update the variables ```pubkey``` and ```privkey``` in ```main.dart``` within the Android Application folder

![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/RSA%20Flutter.png)

Generate AES Key

```
python3 keygen.py
```

![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/Screenshot%202025-01-14%20at%207.02.45%E2%80%AFpm.png)

Update ```symmkey``` in ```messages.dart``` within the Android Application folder using the base-16 string

![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/Screenshot%202025-01-14%20at%207.05.40%E2%80%AFpm.png)

Update ```Key``` in ```main.py``` of MacOS Utilities using the byte-array

![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/Screenshot%202025-01-14%20at%207.06.33%E2%80%AFpm.png)

Do the same for the initialization vector.

Update ```iv2``` in ```messages.dart``` within the Android Application folder 

and ```iv``` (byte array) in ```main.py``` of MacOS Utilities

### Setting Envrionment Variables of MacOS Utility

- ```fd``` is a timestamp of the first date to import messages from when starting the application

- ```connection``` is the path to the iMessageForAll SQLLite DB. This is typically ```~/Library/Messages/chat.db```

- ```connection2``` is the path to the contacts database. This is typically ```~/Library/Application Support/AddressBook/AddressBook-v22.abcddb```

### MacOS Permissions
To access the iMessageForAll Database and Contacts Database, some further measures may be required before simply running the script.

Granting terminal Full Disk Access

![](https://github.com/vas-byte/iMessageForAll/blob/main/Images/Instructions/Full%20Disk%20Access.png)

### Installing Libraries
For MacOS utility, install the required python libraries using the command below:
```pip3 install -r requirements.txt```

### Run

For MacOS Utility (note you may need sudo privillages)

```python3 main.py```


For Flutter application, set the target device (most likely Android), type

```flutter run```

In order for this program to run correctly, the MacOS Utility must be running whilst interacting with the frontend application.




## Screenshots

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; justify-items: center;">

  <div>
    <p>Login Page</p>
    <img src="https://github.com/vas-byte/iMessageForAll/blob/main/Images/Screenshots/login.png" alt="Login Page" width="200"/>
  </div>
  <br>
  <div>
     <p>Forgot Password Page</p>
    <img src="https://github.com/vas-byte/iMessageForAll/blob/main/Images/Screenshots/forgot%20password.png" alt="Forgot Password Page" width="200"/>
  <br>
  </div>
  <br>
  <div>
    <p>Conversations Page</p>
    <img src="https://github.com/vas-byte/iMessageForAll/blob/main/Images/Screenshots/conversations.png" alt="Conversations Page" width="200"/>
  </div>
  <br>
  <div>
    <p>New Conversation Page</p>
    <img src="https://github.com/vas-byte/iMessageForAll/blob/main/Images/Screenshots/new%20conversation.png" alt="New Conversation Page" width="200"/>
  </div>
  <br>
  <div>
    <p>Individual Chat Page</p>
    <img src="https://github.com/vas-byte/iMessageForAll/blob/main/Images/Screenshots/chat.png" alt="Individual Chat Page" width="200"/>
  </div>

</div>
