#!/bin/bash

# This script automates the execution of the MegaLinter Jenkins pipeline.
# It creates a test job and adds the Jenkinsfile content as the job's configuration.

# Configuration - change these values
JENKINS_URL="http://jenkins-server.i.psilva.org:8080"
JENKINS_USER="jenkinsAdmin"
JENKINS_API_TOKEN=$(op read "op://Dev/jenkins_cli/password")
JENKINSFILE_PATH="cicd/megalinter.jenkinsfile"
JOB_NAME="megalinter-pipeline-job"
TEMP_JENKINSFILE="/tmp/temp_jenkinsfile"

# Check if the Jenkinsfile exists
if [ ! -f "$JENKINSFILE_PATH" ]; then
    echo "Error: Jenkinsfile not found at $JENKINSFILE_PATH"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Check if java is installed
if ! command -v java &> /dev/null; then
    echo "Java is required but not installed. Please install Java first."
    exit 1
fi

# Check if jenkins-cli.jar exists
if [ ! -f "jenkins-cli.jar" ]; then
    echo "Downloading Jenkins CLI..."
    curl -O "$JENKINS_URL/jnlpJars/jenkins-cli.jar"
    
    if [ ! -f "jenkins-cli.jar" ]; then
        echo "Failed to download jenkins-cli.jar. Check your Jenkins URL."
        exit 1
    fi
    
    echo "Downloaded jenkins-cli.jar successfully."
fi

# Test connection to Jenkins
echo "Testing connection to Jenkins..."
CONNECTION_TEST=$(java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_API_TOKEN" who-am-i 2>&1)

if [[ "$CONNECTION_TEST" == *"Authenticated"* ]]; then
    echo "Connection to Jenkins successful!"
else
    echo "Failed to connect to Jenkins: $CONNECTION_TEST"
    echo "Please check your Jenkins URL, username, and API token."
    exit 1
fi

# Copy the Jenkinsfile to a temporary location
cp "$JENKINSFILE_PATH" "$TEMP_JENKINSFILE"

# Create job config XML with proper XML escaping
echo "Creating job configuration from Jenkinsfile..."
# Read Jenkinsfile content and escape XML special characters
JENKINSFILE_CONTENT=$(cat "$TEMP_JENKINSFILE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g')

# Create the job config XML with escaped content
cat > /tmp/job_config.xml << EOF
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps">
    <script>$JENKINSFILE_CONTENT</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
</flow-definition>
EOF

# Check if job exists
echo "Checking if job '$JOB_NAME' already exists..."
JOB_EXISTS=$(java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_API_TOKEN" list-jobs | grep -w "$JOB_NAME")

if [ -n "$JOB_EXISTS" ]; then
    echo "Job '$JOB_NAME' exists, updating configuration..."
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_API_TOKEN" update-job "$JOB_NAME" < /tmp/job_config.xml
else
    echo "Job '$JOB_NAME' doesn't exist, creating new job..."
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_API_TOKEN" create-job "$JOB_NAME" < /tmp/job_config.xml
fi

# Clean up
rm -f /tmp/job_config.xml

# Build the job
echo "Building job '$JOB_NAME'..."
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_API_TOKEN" build "$JOB_NAME" -f -v

# Clean up temp file
rm -f "$TEMP_JENKINSFILE"

echo
echo "MegaLinter job operations completed."
echo 
echo "Useful commands:"
echo "- View job in browser: $JENKINS_URL/job/$JOB_NAME/"
echo "- Build job: java -jar jenkins-cli.jar -s \"$JENKINS_URL\" -auth \"$JENKINS_USER:$JENKINS_API_TOKEN\" build \"$JOB_NAME\" -f -v"
echo "- Delete job: java -jar jenkins-cli.jar -s \"$JENKINS_URL\" -auth \"$JENKINS_USER:$JENKINS_API_TOKEN\" delete-job \"$JOB_NAME\"" 