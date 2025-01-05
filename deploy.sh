# sudo yum -y remove java-17-amazon-corretto*
# sudo yum install -y https://corretto.aws/downloads/latest/amazon-corretto-11-x64-linux-jdk.rpm
java -version
wget https://services.gradle.org/distributions/gradle-6.5-bin.zip -P /tmp

sudo unzip -d /opt/gradle /tmp/gradle-6.5-bin.zip

export GRADLE_HOME=/opt/gradle/gradle-6.5
export PATH=${GRADLE_HOME}/bin:${PATH}

cat >> ~/.bash_profile  <<TXT
export GRADLE_HOME=${GRADLE_HOME}
export PATH=${GRADLE_HOME}/bin:${PATH}
TXT

# gradle -v   (optional) 

git clone https://github.com/sdjustin1/fuseless.git
# -------------------- break point #1
cd fuseless

./test.sh
# -------------------- break point #2
cd ..

git clone https://github.com/sdjustin1/sdjustin.git
# -------------------- break point #3
cd sdjustin

./init.sh
# -------------------- break point #4
gradle build
# -------------------- break point #5
# sam deploy --guided
#   or
sam deploy