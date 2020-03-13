def db()
    fat = SQLite3::Database.new("db/database.db")    
    fat.results_as_hash = true
    return fat
end

def createuser(password, username)
    password_digest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users(password, username) VALUES (?,?)", [password_digest, username])
end

def userexist(username)
    return db.execute("SELECT id FROM users WHERE username=?", username)
end

def login(username, password)
    password_digest = db.execute("SELECT password FROM users WHERE username=?", username)
    if BCrypt::Password.new(password_digest[0][0]) == password
        session[:username] = username
        session[:user_id] = db.execute("SELECT id FROM users WHERE username=?", username)[0][0]
        return true
    end
end