FROM tomcat:8.0-alpine
LABEL owner="deekshithy" email="deekshit.yamjala01@gmail.com"
#RUN yum update && yum install -y git jq curl
#WORKDIR /deegit
ADD target/*.war /usr/local/tomcat/webapps/
CMD [ "catalina.sh", "run" ]