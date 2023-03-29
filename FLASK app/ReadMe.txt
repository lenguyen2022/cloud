Description:
Python FLASK app to be deployed in AWS for the Skills Ontario Cloud competition

When the app is run, it shows config.html for the user to enter Database configuration information( MYSQL database connection string, username and password). It then checks if connection can be made and stores it config.py. This is a one time setup. If the file config.py exists, the index page is shown directly.


The user can signup or signin to the app in index page. Appropriate error messages are shown when there is error in signup or sign in.

Database Schema:
Use the script SkillsDB.sql to load the schema needed for the MySQL DB.

Pip packages:
The bash script has the pip packages needed for the app

