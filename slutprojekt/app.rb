require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'

enable :sessions

db = SQLite3::Database.new('db/database.db')
db.results_as_hash = true


get('/register') do
  slim(:register)
end

post('/registredaccount') do
  password = params[:password]
  confirm = params[:passwordconf]
  username = params[:username]
  if confirm != password
      redirect('/wrongmatch')
  end
  result = userexist(username)
  if result.empty? == false
      redirect('/wrong')
  end
  createuser(password, username)
  redirect('/login')
end

get('/login') do
  slim(:login)
end

post('/loginacc') do
  username = params[:username]
  password = params[:password]
  if userexist(username).empty?
      redirect('/wronguser')
  end
  val = login(username, password)
  if val
      redirect('/YOURTINGHERE')
  else
      redirect('/wronguser')
  end 
end

