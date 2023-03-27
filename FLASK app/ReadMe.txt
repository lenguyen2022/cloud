The database config info is stored in config.py
If this file is empty, the config.html page will be shown and user can enter the DB connection string, username and password. This will be stored in config.py and used for later use.
If the config.py exists, the app proceeds to index.html where user can signup or signin.
If there is error in config data then the error info is shown and the config.js is deleted, so the user can input this data again
If there is error in sign in then, appropriate error is shown

Known issues:
The success or error messages is not rendered in the signup.html. I spent few hours to debug but couldnt understand why this happens. Any help in this regard is appreciated.
