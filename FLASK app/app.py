from flask import Flask, render_template, json, request, session,redirect
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
import os.path

mysql = MySQL()

app = Flask(__name__)
mysql.init_app(app)

@app.route('/')
def main():   
    if os.path.exists('config.py'):
        # MySQL configurations
        try:
            app.config.from_pyfile('config.py')
                    
        except Exception as e:            
            return render_template('error.html', message=str(e))
    
        return render_template('index.html')
    else:
       return render_template('config.html') 


@app.route('/signup')
def showSignUp():
    return render_template('signup.html')


@app.route('/signin')
def showSignin():
    return render_template('signin.html')


@app.route('/api/validateLogin', methods=['POST'])
def validateLogin():
    try:
        _username = request.form['inputEmail']
        _password = request.form['inputPassword']
        conn = mysql.connect
        cursor = conn.cursor()
        cursor.callproc('sp_validateLogin', (_username,))
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
    finally:
        cursor.close()
        conn.close()

@app.route('/api/signup', methods=['POST','GET'])
def signUp():
    try:
        _name = request.form['inputName']
        _email = request.form['inputEmail']
        _password = request.form['inputPassword']

        # validate the received values
        if _name and _email and _password:

            # All Good, let's call MySQL

            conn = mysql.connect
            cursor = conn.cursor()
            _hashed_password = generate_password_hash(_password)
            cursor.callproc('sp_createUser', (_name, _email, _hashed_password))
            data = cursor.fetchall()

            if len(data) == 0:
                conn.commit()                   
                return redirect('/')
            else:
               return  render_template('error.html', message= str(data[0])) 
        else:
            return render_template('error.html',message = 'Enter the required fields')

    except Exception as e:
        return render_template('error.html', message=str(e))
    finally:
        cursor.close()
        conn.close()

@app.route('/signupsuccess')
def success():
    return render_template('signupsuccess.html')

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

@app.route('/api/config', methods=['POST', 'GET'])
def config():
    try:
        _connString = request.form['connString']
        _username = request.form['username']
        _password = request.form['password']

        # validate the received values and test connection
        if _connString and _username and _password:
    
            # All Good, save to config.py
            db, host = _connString.split(".")
            f = open("config.py", "x")
            f.write("SECRET_KEY = 'Random secret key'" +"\n")
            f.write("MYSQL_DB = '" + db +"'\n")
            f.write("MYSQL_HOST = '" + host+"'\n")
            f.write("MYSQL_USER = '" + _username+"'\n")
            f.write("MYSQL_PASSWORD = '" + _password+"'\n")
            f.close()

            try:
                app.config.from_pyfile('config.py') 
                conn = mysql.connect 
                conn.close()   
                return render_template('index.html')            
            except Exception as e:
                os.remove('config.py')
                return render_template('configerror.html', message=str(e))
                
           
        else:
            return render_template('error.html',message = 'Enter the required fields')

    except Exception as e:
        return render_template('error.html', message=str(e))
    


if __name__ == "__main__":
    app.run()
