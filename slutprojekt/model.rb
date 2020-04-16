def db()
    db = SQLite3::Database.new("db/database.db")    
    db.results_as_hash = true
    return db
end

def createuser(password, username, admin)
    password_digest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users(password, username, administrator) VALUES (?,?,?)", [password_digest, username, admin])
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

def user_info(user_id)
    return db.execute("SELECT * FROM users WHERE id=?", user_id)
end

def users(user_id)
    return [db.execute("SELECT * FROM users"), db.execute("SELECT * FROM users WHERE id=?", user_id)]
end

def potdeluserinfo(user_id, user_delete_id)
    return [db.execute("SELECT * FROM users WHERE id=?", user_id), db.execute("SELECT * FROM users WHERE id=?", user_delete_id)]
end

def user_delete(user_delete_id)
    db.execute("DELETE FROM users WHERE id=?", user_delete_id)
end

def fileupload(filename)
    unless filename &&
        (tempfile = filename[:tempfile]) &&
        (name = filename[:filename])
    @error = "No file selected"
    return false
    end
    print "File #{filename[:filename]} uploaded"
    fileextension = filename["filename"]
    if File.extname(fileextension) == ".png" || File.extname(fileextension) == ".jpg" || File.extname(fileextension) == ".jpeg"
        target = "public/img/#{name}"
        file = {target: target, name: name, tempfile: tempfile}
        return file
    else
        return false
    end
end

def avatarchange(user_id, name)
    db.execute("UPDATE users SET avatar=? WHERE id=?", name, user_id)
end

def getings()
    return db.execute("SELECT * FROM ingredients")
end

def createrecipe(title, desc, filename, ingredients, measurements, units, user_id)
    ingstr = ""
    measurestr = ""
    unitstr = ""
    (0..(ingredients.length-1)).each do |i|
        ingstr += ingredients[i].to_s + ","
        measurestr += measurements[i].to_s + ","
        unitstr += units[i].to_s + ","
    end
    ingstr = ingstr.chop
    measurestr = measurestr.chop
    unitstr = unitstr.chop
    db.execute("INSERT INTO recipes(user_id, name, img, desc) VALUES (?,?,?,?)", [user_id, title, filename, desc])
    db.execute("INSERT INTO recipe_to_ing_rel(recipe_id, ing_id, amount, unit) VALUES (?,?,?,?)", [db.execute("SELECT recipe_id FROM recipes ORDER BY recipe_id DESC LIMIT 1")[0]["recipe_id"], ingstr, measurestr, unitstr])
end

def getrecipes()
    return [db.execute("SELECT * FROM recipes"), db.execute("SELECT * FROM recipe_to_ing_rel")]
end

def getingnames()
    return db.execute("SELECT ing_name FROM ingredients")
end