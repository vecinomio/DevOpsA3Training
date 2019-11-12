ARG app_name=snakes

FROM tomcat:8
ARG app_name
LABEL maintainer = "imaki" \
      description = "tomcat-8 image with application about snakes"

WORKDIR /home/project
COPY . .
RUN cd app && cp ${app_name}.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]
