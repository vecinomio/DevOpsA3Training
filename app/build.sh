cd src
mkdir -p WEB-INF/classes
echo .
sudo javac -d WEB-INF/classes com/snakes/model/Media.java
echo .
sudo javac -classpath WEB-INF/lib/*:WEB-INF/classes -d WEB-INF/classes com/snakes/model/Movie.java
echo .
sudo javac -classpath WEB-INF/lib/*:WEB-INF/classes -d WEB-INF/classes com/snakes/web/ListMovies.java
echo .
sudo javac -classpath WEB-INF/lib/*:WEB-INF/classes -d WEB-INF/classes com/snakes/web/AddMovie.java
echo .
sudo javac -classpath WEB-INF/lib/*:WEB-INF/classes -d WEB-INF/classes com/snakes/web/SearchMovies.java
echo .
if [ -d ".ebextensions/httpd/conf.d" ]; then
  sudo jar -cf snakes.war *.jsp images css js WEB-INF .ebextensions/*.config .ebextensions/*.json .ebextensions/httpd/conf.d/*.conf
else
  sudo jar -cf snakes.war *.jsp images css js WEB-INF .ebextensions/*.config .ebextensions/*.json
fi
echo .
if [ -d "/Library/Tomcat/webapps" ]; then
  cp snakes.war /Library/Tomcat/webapps
  echo .
fi
mv snakes.war ../
echo .
echo "SUCCESS"
