from flask import Flask, render_template, json, request, session,redirect
from pymysql import connections
from werkzeug.security import generate_password_hash, check_password_hash
import boto3


app = Flask(__name__)
app.secret_key = 'the random string'
conn = None

@app.route('/')
def main():  
    global conn
    if(conn is None):     
       conn = dbconn()    
    return render_template('index.html') 


@app.route('/signup')
def showSignUp():
    return render_template('signup.html')


@app.route('/signin')
def showSignin():
    return render_template('signin.html')


@app.route('/api/validateLogin', methods=['POST'])
def validateLogin():
    global conn
    try:
        _username = request.form['inputEmail']
        _password = request.form['inputPassword']
        cursor = conn.cursor()
        #cursor.callproc('sp_validateLogin', (_username,))  
        cursor.execute('SELECT * FROM tbl_user where user_username = %s',(_username,))        
       
        data = cursor.fetchall()
        if len(data) > 0:
            if check_password_hash(str(data[0][3]), _password):
                session['user'] = data[0][0]
                return redirect('/userhome')
            else:
                return render_template('error.html', message='Wrong Email address or Password')
        else:
            return render_template('error.html', message='Wrong Email address or Password')
    except Exception as e:
        return render_template('error.html', message=str(e))
 

@app.route('/api/signup', methods=['POST','GET'])
def signUp():
    global conn 
    _name = request.form['inputName']
    _email = request.form['inputEmail']
    _password = request.form['inputPassword']

    # validate the received values
    if _name and _email and _password:
        try:
        # All Good, let's call MySQL
            cursor = conn.cursor()
            _hashed_password = generate_password_hash(_password)
            cursor.callproc('sp_createUser', (_name, _email, _hashed_password))
            data = cursor.fetchall()

            if len(data) == 0:
                conn.commit()                                 
                return  render_template('signupsuccess.html', message= 'User sign up successful')
            else:
                return  render_template('error.html', message= str(data[0])) 
        except Exception as e:
            return render_template('error.html', message=str(e))
    
    else:
        return render_template('error.html',message = 'Enter the required fields')


@app.route('/userhome')
def userHome():
    if session.get('user'):
        return render_template('userhome.html')
    else:
        return render_template('error.html', message='Unauthorized Access')


@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect('/')

    
def dbconn():
  
    ssm = boto3.client('ssm',region_name='us-east-1')
    try:
        username = ssm.get_parameter(Name='username', WithDecryption=False)['Parameter']['Value']
        password = ssm.get_parameter(Name='password', WithDecryption=False)['Parameter']['Value']
        host = ssm.get_parameter(Name='host', WithDecryption=False)['Parameter']['Value']
        port = ssm.get_parameter(Name='port', WithDecryption=False)['Parameter']['Value']
        database_name = ssm.get_parameter(Name='database', WithDecryption=False)['Parameter']['Value']

        
    except Exception as e:
        return render_template('error.html', message=str(e)) 
    params = {
    'user':username, 
    'password':password,
    'host':host,
    'port':int(port),
    'database':database_name
    }
     
    cnx = connections.Connection(**params)
    return cnx

if __name__ == "__main__":
    app.run(host='0.0.0.0',debug=True)
