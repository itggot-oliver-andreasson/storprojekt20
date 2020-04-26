require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative 'model.rb'

include Model

enable :sessions

db = SQLite3::Database.new('db/database.db')
db.results_as_hash = true

# Displays register page
# 
get('/register') do
  	slim(:"users/register")
end

# Registers an account
#
# @param [String] :password, users password
# @param [String] :passwordconf, confirmation of users password
# @param [String] :username, users username
# 
# @see Model#userexist
# @see Model#createuser
post('/registeredaccount') do
  	password = params[:password]
  	confirm = params[:passwordconf]
	username = params[:username]
	admin = "0"  
  	if confirm != password
  	    redirect('/wrongmatch')
  	end
  	result = userexist(username)
  	if result.empty? == false
  	    redirect('/wrong')
  	end
  	createuser(password, username, admin)
  	redirect('/login')
end

# Displays login page
#
get('/login') do
	slim(:"users/login")
end

# Confirms the login of user
#
# @param [String] :username, users username
# @param [String] :password, users password
# 
# @see Model#userexist
# @see Model#login
post('/loginconfirm') do
	username = params[:username]
	password = params[:password]
	if userexist(username).empty?
		session[:error] = "That account does not exist."
		session[:route] = "/login"
		redirect('/error')
  	end
  	if login(username, password)
    	redirect('/recipes')
  	else
    	session[:error] = "That password is wrong."
    	session[:route] = "/login"
    	redirect('/error')
  	end 
end

# Displays error page
#
get("/error") do
	slim(:error)
end

# Shows landing page
#
get("/") do
  slim(:index)
end

# Displays recipe page
#
# @see Model#user_info
# @see Model#getrecipes
# @see Model#getingnames
get("/recipes") do
	if session[:user_id] == nil
		session[:error] = "You are not logged in. Log in to view all recipes!"
		session[:route] = "/login"
		redirect("/error")
	else
		user_info = user_info(session[:user_id])
		recipes = getrecipes()
		ingredients = getingnames()
		slim(:"main/recipes", locals: {user_info: user_info, recipes: recipes, ingredients: ingredients})
	end
end

# Logs out the user and clears sessions
# 
post("/logoutform") do
	session.clear
	redirect("/")
end

# Displays profile page of logged in user
#
# @see Model#user_info
get("/profile") do
	if session[:user_id] == nil
		session[:error] = "You are not logged in. Log in to view your profile!"
		session[:route] = "/login"
		redirect("/error")
	else
		user_data = user_info(session[:user_id])
		slim(:"users/profile", locals: {user_data: user_data})
	end
end

# Displays administrator settings
# 
# @see Model#user_info
# @see Model#users
get("/administrator") do
	if session[:user_id] == nil
		session[:error] = "You are not logged in. Log in to view your profile!"
		session[:route] = "/login"
		redirect("/error")
	elsif user_info(session[:user_id])[0]["administrator"] != "1"
		session[:error] = "You are not an administrator."
		session[:route] = "/profile"
		redirect("/error")		
	else
		users = users(session[:user_id])
		slim(:"users/administrator", locals: {allusers: users[0], admin: users[1]})
	end
end

# Deletes a user by administrator
#
# @param [String] :id, id of deleted user
# 
# @see Model#potdeluserinfo
# @see Model#user_delete
post("/administrator/:id/deleteuser") do
    user_delete_id = params[:id]
    user_info = potdeluserinfo(session[:user_id], user_delete_id)
    if user_info[1][0]["administrator"] == "1"
        session[:error] = "You can't delete an admin."
        session[:route] = "/administrator"
        redirect("/error")
    else
        if user_info[0][0]["administrator"] == "1"
            user_delete(user_delete_id)
            redirect("/administrator")
        else
            session[:error] = "You do not have admin priviligies."
            session[:route] = "/profile"
            redirect("/error")
        end
    end
end

# Displays the page for uploading avatars
#
get("/newavatar") do
	if session[:user_id] == nil
		session[:error] = "You are not logged in. Log in to change avatar!"
		session[:route] = "/login"
		redirect("/error")
	else
		slim(:"users/newavatar")
	end
end

# Uploads and changes to new avatar for user
#
# @param [String] :file, name of file
# 
# @see Model#fileupload
# @see Model#avatarchange
post("/avataruploaded") do
	file = fileupload(params[:file])
	if !file
		session[:error] = "Wrong file extension. Images only!"
		session[:route] = "/newavatar"
		File.delete(file[:target])
		redirect("/error")
	end
	target = file[:target]
    tempfile = file[:tempfile]
    name = file[:name]
	user_id = session[:user_id]
    File.open(target, 'wb') {|f| f.write tempfile.read }
    filesize = File.size(target)
    if File.size(target) > 5000000
        File.delete(target)
        session[:error] = "That file is to big. We only allow max 5MB images."
        session[:route] = "/newavatar"
        redirect('/error')
    end
    avatarchange(user_id, name)
    redirect('/profile')
end

# Displays creation of recipe page
# 
# @see Model#getings
get("/createrecipe") do
	if session[:user_id] == nil
		session[:error] = "You are not logged in. Log in create a recipe!"
		session[:route] = "/login"
		redirect("/error")
	else
		ingnum = params[:ingnum]
		if ingnum.to_i > 10 || ingnum.to_i < 1
			session[:error] = "You cannot have more than 10 ingredients."
			session[:route] = "/recipes"
			redirect("/error")
		end
		ingredients = getings()
		slim(:"main/create", locals: {ingredients: ingredients, ingnum: ingnum})
	end
end

# Creates a recipe
#
# @param [Integer] :ingnum, number of ingredients
# @param [String] :file, name of file
# @param [String] :title, title of recipe
# @param [String] :desc, description/instructions to ingredients
# 
# @see Model#getings
# @see Model#fileupload
# @see Model#createrecipe
post("/recipecreated") do
	ingnum = params[:ingnum].to_i
	ings = []
	measures = []
	units = []
	ingreds = getings()
	(1..ingnum).each do |i|
		ingreds.each do |ingred|
			if params[:"ingredient#{i}"] == ingred["ing_name"]
				ings << ingred["id"]
			end
		end
		measures << params[:"amount#{i}"]
		if params[:"measurement#{i}"] == "ml"
			units << "1"
		elsif params[:"measurement#{i}"] == "dash/es"
			units << "2"
		else
			session[:error] = "You used a wrong measurement!"
			session[:route] = "/createrecipe"
			redirect("/error")
		end
	end
	title = params[:title]
	desc = params[:desc]
	file = fileupload(params[:file])
	if !file
		session[:error] = "Wrong file extension. Images only!"
		session[:route] = "/createrecipe"
		File.delete(file[:target])
		redirect("/error")
	end
	target = file[:target]
    tempfile = file[:tempfile]
    name = file[:name]
	File.open(target, 'wb') {|f| f.write tempfile.read }
    filesize = File.size(target)
    if File.size(target) > 5000000
        File.delete(target)
        session[:error] = "That file is to big. We only allow max 5MB images."
        session[:route] = "/createrecipe"
        redirect('/error')
    end
	createrecipe(title, desc, file[:name], ings, measures, units, session[:user_id])
	redirect("/recipes")
end

# Deletes a users recipe either by owner or admin
#
# @param [Integer] :id, id of recipe
# 
# @see Model#userrecipe
# @see Model#deletepost
post("/recipes/:id/delete") do
	recipe_id = params[:id]
    userrecipeinfo = userrecipe(session[:user_id], recipe_id)
    if userrecipeinfo[1][0]["user_id"] == session[:user_id] || userrecipeinfo[0][0]["admin"] == "1"
        deletepost(recipe_id)
    else
        session[:error] = "That is not your post or you are not an admin."
        session[:route] = "/recipes"
        redirect("/error")
    end
    redirect("/recipes")
end

# Displays recipe-updation page
#
# @param [Integer] :id, id of recipe
# 
# @see Model#userrecipe
# @see Model#getings
# @see Model#recipe_ing_rel
get("/recipes/:id/update") do
    recipe_id = params[:id]
	userrecipeinfo = userrecipe(session[:user_id], recipe_id)
	ingredients = getings()
	recipe_ing_rel = recipe_ing_rel(recipe_id)
    if userrecipeinfo[1][0]["user_id"] == session[:user_id]
		slim(:"main/update", locals: {userrecipeinfo: userrecipeinfo[1][0], recipe_id: recipe_id, ingredients: ingredients, recipe_ing_rel: recipe_ing_rel})
    else
        session[:error] = "You are not the owner of this post."
        session[:route] = "/recipes"
        redirect("/error")
    end
end

# Updates the recipe by owner
#
# @param [Integer] :id, id of recipe
# @param [Integer] :ingnum, number of ingredients
# @param [String] :title, title of recipe
# @param [String] :desc, description/instructions to ingredients
# @param [String] :file, name of file uploaded
# 
# @see Model#getings
# @see Model#fileupload
# @see Model#updaterecipe
post("/recipes/:id/updatedrecipe") do
	recipe_id = params[:id]
	ingnum = params[:ingnum].to_i
	ings = []
	measures = []
	units = []
	ingreds = getings()
	(1..ingnum).each do |i|
		ingreds.each do |ingred|
			if params[:"ingredient#{i}"] == ingred["ing_name"]
				ings << ingred["id"]
			end
		end
		measures << params[:"amount#{i}"]
		if params[:"measurement#{i}"] == "ml"
			units << "1"
		elsif params[:"measurement#{i}"] == "dash/es"
			units << "2"
		else
			session[:error] = "You used a wrong measurement!"
			session[:route] = "/createrecipe"
			redirect("/error")
		end
	end
	title = params[:title]
	desc = params[:desc]
	file = fileupload(params[:file])
	if !file
		session[:error] = "Wrong file extension. Images only!"
		session[:route] = "/createrecipe"
		File.delete(file[:target])
		redirect("/error")
	end
	target = file[:target]
    tempfile = file[:tempfile]
    name = file[:name]
	File.open(target, 'wb') {|f| f.write tempfile.read }
    filesize = File.size(target)
    if File.size(target) > 5000000
        File.delete(target)
        session[:error] = "That file is to big. We only allow max 5MB images."
        session[:route] = "/createrecipe"
        redirect('/error')
    end
	updaterecipe(title, desc, file[:name], ings, measures, units, session[:user_id], recipe_id)
	redirect("/recipes")
end
