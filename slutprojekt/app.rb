require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

$db = SQLite3::Database.new('db/database.db')
$db.results_as_hash = true

get('/users/login') do
    slim(:"users/login")
  end

post('/users/login') do
    email = params[:email]
    password = params[:password]
  
    password_digests = $db.execute("SELECT Password FROM Users WHERE Email = ?", email)
    if password_digests.empty?
      return slim(:"users/login_error", locals: {errormessage:"The username or password you've entered is incorrect"})
    end
    password_digest = password_digests[0]["Password"]
  
    if BCrypt::Password.new(password_digest) == password
      session[:email] = email
      session[:password] = password
    else
      return slim(:"users/login_error", locals: {errormessage:"The username or password you've entered is incorrect"})
    end
    redirect('/lists')
end

get('/users/register') do
    slim(:"users/register")
end
  
post('/users/register') do
    email = params[:email]
    password = params[:password]
    password2 = params[:password2]
  
    if !$db.execute('SELECT * FROM Users WHERE Email = ?', email).empty?
      return slim(:"users/register_error", locals: {errormessage:"Användarnamnet är upptaget."})
    elsif password != password2
      return slim(:"users/register_error", locals: {errormessage:"Lösenorden stämmer inte överens."})
    elsif password.length < 4
      return slim(:"users/register_error", locals: {errormessage:"Lösenordet måste åtminstone vara fyra tecken långt."})
    end
  
    password_digest = BCrypt::Password.create(password)
  
    $db.execute('INSERT INTO Users (Email, Password) VALUES (?, ?)', email, password_digest)
  
    redirect('/lists')
end