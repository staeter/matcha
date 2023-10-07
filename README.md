# Matcha
## Second project of 42's Web cursus

Matcha is a dating site using an Elm, pure PHP, MySql stack. staeter learned the functional logic proposed by Elm when building the client-side code. Reelbour focused on the server-side code. The challenges where to design a good client-server interface and communicate with the team to reach the end product in a limited time frame.

## Installation

1. Git clone the project at the root of your directory where is apache hosted (by example : htdocs)
2. Add to your httpd.conf the property contained in .apache_Configuration for set single page on(needed)
3. Be sure that your sendmail path is set on your php.ini
4. Go to config/database.php to set your pseudo/password to connect to db, you can also handle the port to mysql.
5. Make sur your apache port is set on 8080 (needed !)
7. On you browser, go to localhost:8080/config/setup.php to create the database
8. You can seed the db with fake profile, go to localhost:8080/config/hydrate.php each reload will add 15 users.
9. Go to localhost:8080, you will be redirect to home, then make an account confirm it with mail or delete the entry in db on table account_verification_key.
10. Enjoy !
