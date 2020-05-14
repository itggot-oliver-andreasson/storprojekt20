# Projektplan

## 1. Projektbeskrivning (Beskriv vad sidan ska kunna göra)

Tanken är att sidan jag gör ska vara en hemsida likt en receptsamling fast för cocktails/drinkar. Man ska kunna skapa konton att logga in med, lägga upp recept på drinkar och spara sina favoriter i en lista. Dessutom ska det gå att söka på olika cocktails utifrån kategorier och dessa är indelade efter spritsort den är baserad på. Exempelvis skulle en kategori kunna vara "Rom-drinkar" eller "Gin-drinkar".
Tanken är att ha många-till-många-relation mellan mina recept och ingredienser.

## 2. Vyer (visa bildskisser på dina sidor)

![Sketch](IMG_20200123_151501.jpg)

## 3. Databas med ER-diagram (Bild)

![ER-diagram](IMG_20200123_151450.jpg)

## 4. Arkitektur (Beskriv filer och mappar - vad gör/inehåller de?)

Projektet innehåller många olika filer och mappar som är som följande:

App.rb (fil) -  -innehåller alla projektets routes
 
Model.rb (fil) - Model.rb innehåller all kod kopplad till databasen
 
Views (Mapp) - innehåller alla slimfiler och mapparna "main" och "users" med ytterligare slim-filer

  main (mapp) - innehåller alla slim-filer som har med receptsidorna att göra
    create.slim (fil) - sidan där man skapar nya recept
    recipes.slim (fil) - huvud-sidan där man kan överblicka upplagda recept, navigera till sidan för att skapa nya recept, logga ut från                          sitt konto, se sin profilbild och navigera till sidan för sitt konto.
    update.slim (fil) - sidan för att uppdatera sina recept-listings
    
   users (mapp) - innehåller alla slim-filer som har med användarna att göra
    administrator.slim (fil) - sidan för administratörs-inställningar. Bland annat där admin kan ta bort andra användare
    login.slim (fil) - sidan där man loggar in på sitt konto med olika användare
    newavatar.slim (fil) - sidan där man kan välja en bildfil från datorn och sedan lägga upp denna som avatar
    profile.slim (fil) - sidan där man kan överblicka sin profil, återgå till startsidan, navigera till profilbyte och/eller till                                administratörsinställningar
    register.slim (fil) - sidan där man skapar ett nytt konto för att kunna komma åt hemsidan
    
   error.slim (fil) - ger felmeddelandet som fås när ett fel sker på någon annan sida. Ex att password och password-confirmation inte är                       samma
   index.slim (fil) - Den absolut första sidan man kommer till när man startar sidan. Där man kan välja mellan att navigera till login-                       eller registreringssidan
   layout.slim (fil) 
   
Public (mapp)

  css (mapp)
    style.css (fil) - innehåller all css-kod
    
  img (mapp) - innehåller alla hemsidans bilder
  
  js (mapp)
    script.js (fil) - innehåller javascript-kod
    
Doc (mapp) - innehåller all yardoc-dokumentering

db (mapp)
  database.db (fil) - den länkade databasen som hemsidan bygger på

.Yardoc (mapp) - ingen relevant kod eller liknande. gem-filer för yardoc 

Utöver dessa finns ett antal filer som inte heller innehåller någon kod. Dessa är:

.byebug_history (fil)
gemfile (fil)
gemfile.lock (fil
