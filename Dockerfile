# Start with a base image containing Java runtime
FROM adoptopenjdk:11-jre-hotspot

# Add a volume pointing to /tmp
VOLUME /tmp

# Make port 8080 available to the world outside this container
EXPOSE 8080

# The application's jar file

ARG JAR_FILE=target/hello-world-0.0.1-SNAPSHOT.jar

# use the value to set the ENV var default

#WORKDIR /root/.jenkins/workspace/ptvn-contract-api_master
#COPY src/main ./
# Add the application's jar to the container
ADD ${JAR_FILE} hello-world.jar

# Run the jar file
ENTRYPOINT ["java","-jar","/hello-world.jar"]
