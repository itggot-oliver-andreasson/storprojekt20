# Contains all code for database
# 
module Model

    # Makes the use of db.execute work
    # 
    # @return [Database] containing database
    def db()
        db = SQLite3::Database.new("db/database.db")    
        db.results_as_hash = true
        return db
    end
    
    # Creates a user
    # 
    # @param [String] password, contains password
    # @param [String] username, contains username
    # @param [String] admin, contains admin
    #  
    # @return [Nil]
    def createuser(password, username, admin)
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO users(password, username, administrator) VALUES (?,?,?)", [password_digest, username, admin])
    end
    
    # Checks if user exists
    # 
    # @param [String] username, contains username
    #  
    # @return [Integer] containing id of user
    def userexist(username)
        return db.execute("SELECT id FROM users WHERE username=?", username)
    end
    
    # Checks if password is correct
    # 
    # @param [String] username, contains username
    # @param [String] password, contains password
    #  
    # @return [Boolean] containing true if password correct
    def login(username, password)
        password_digest = db.execute("SELECT password FROM users WHERE username=?", username)
        if BCrypt::Password.new(password_digest[0][0]) == password
            session[:username] = username
            session[:user_id] = db.execute("SELECT id FROM users WHERE username=?", username)[0][0]
            return true
        end
    end
    
    # Gets all userinfo about a user
    # 
    # @param [Integer] user_id, contains id of user
    #  
    # @return [Hash] containing all info about user
    def user_info(user_id)
        return db.execute("SELECT * FROM users WHERE id=?", user_id)
    end
    
    # Returns info about all users
    # 
    # @param [Integer] user_id, contains id of user
    #  
    # @return [Array] containing info about users
    def users(user_id)
        return [db.execute("SELECT * FROM users"), db.execute("SELECT * FROM users WHERE id=?", user_id)]
    end
    
    # Returns info about potential deleted user and admin
    # 
    # @param [Integer] user_id, contains id of user
    # @param [Integer] user_delete_id, contains id of potential deleted user
    #  
    # @return [Array] containing the information of admin and potential deleted user
    def potdeluserinfo(user_id, user_delete_id)
        return [db.execute("SELECT * FROM users WHERE id=?", user_id), db.execute("SELECT * FROM users WHERE id=?", user_delete_id)]
    end
    
    # Deletes a user
    # 
    # @param [Integer] user_delete_id, contains id of deleted user
    #  
    # @return [Nil]
    def user_delete(user_delete_id)
        db.execute("DELETE FROM users WHERE id=?", user_delete_id)
    end
    
    # Uploads a file to the server
    # 
    # @param [String] filename, contains name of file
    #  
    # @return [Hash] containing file information
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
    
    # Changes avatar for user
    # 
    # @param [Integer] user_id, contains id of user
    # @param [String] name, contains name of image
    #  
    # @return [Nil]
    def avatarchange(user_id, name)
        db.execute("UPDATE users SET avatar=? WHERE id=?", name, user_id)
    end
    
    # Gets all ingredients from database
    # 
    # @return [Hash] containing ingredients
    def getings()
        return db.execute("SELECT * FROM ingredients")
    end
    
    # Creates a recipe
    # 
    # @param [String] title, contains title of recipe
    # @param [String] desc, contains description/instructions for recipe
    # @param [String] filename, contains name of file
    # @param [Array] ingredients, contains all ingredients 
    # @param [Array] measurements, contains all measurements
    # @param [Array] contains units of all ingredients
    # @param [Integer] contains id of users
    #  
    # @return [Nil]
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
    
    # Gets all recipes
    # 
    # @return [Array] containing all recipes and recipe-ingredient-relation
    def getrecipes()
        return [db.execute("SELECT * FROM recipes"), db.execute("SELECT * FROM recipe_to_ing_rel")]
    end
    
    # Gets all ingredient names
    # 
    # @return [Array] containing all ingredient names
    def getingnames()
        return db.execute("SELECT ing_name FROM ingredients")
    end
    
    # Gets info about user and recipes
    # 
    # @param [Integer] user_id, contains id of user
    # @param [Integer] recipe_id, contains id of recipe
    #  
    # @return [] containing
    def userrecipe(user_id, recipe_id)
        return [db.execute("SELECT * FROM users WHERE id=?", user_id), db.execute("SELECT * FROM recipes WHERE recipe_id=?", recipe_id)]
    end
    
    # Deletes a recipe
    # 
    # @param [Integer] recipe_id, contains id of recipe
    #  
    # @return [Nil]
    def deletepost(recipe_id)
        db.execute("DELETE FROM recipes WHERE recipe_id=?", recipe_id)
    end
    
    # Gets the recipe-ingredient-relation table
    # 
    # @param [Integer] recipe_id, contains id of recipe
    #  
    # @return [Hash] containing recipe-ingredient-relation table
    def recipe_ing_rel(recipe_id)
        return db.execute("SELECT * FROM recipe_to_ing_rel WHERE recipe_id=?", recipe_id)
    end
    
    # Updates the recipe by user
    # 
    # @param [String] title, contains the name of recipe
    # @param [String] desc, contains the description/instructions for recipe
    # @param [String] filename, contains name of image
    # @param [Array] ingredients, contains all ingredients
    # @param [Array] measurements, contains all measurements for ingredients
    # @param [Array] units, contains all units for measurements
    # @param [Integer] user_id, contains id of user
    # @param [Integer] recipe_id, contains id of recipe
    #  
    # @return [Nil]
    def updaterecipe(title, desc, filename, ingredients, measurements, units, user_id, recipe_id)
        ingstr = ""
        measurestr = ""
        unitstr = ""
        (0..(ingredients.length-1)).each do |i|
            ingstr += ingredients[i].to_s + ","
            measurestr += measurements[i].to_s + ","
            unitstr += units[i].to_s + ","
        end
        byebug
        ingstr = ingstr.chop
        measurestr = measurestr.chop
        unitstr = unitstr.chop
        db.execute("UPDATE recipes SET user_id=?, name=?, img=?, desc=? WHERE recipe_id=?", user_id, title, filename, desc, recipe_id)
        db.execute("UPDATE recipe_to_ing_rel SET ing_id=?, amount=?, unit=? WHERE recipe_id=?", ingstr, measurestr, unitstr, recipe_id)
    end
    
    end
        