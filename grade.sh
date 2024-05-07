#!/bin/bash

# Define classpath including JUnit and Hamcrest jars
CPATH='.:../lib/hamcrest-core-1.3.jar:../lib/junit-4.13.2.jar'
EXPECTED_FILENAME="ListExamples.java"

# Function to clean up before exit
cleanup() {
    echo "Cleaning up..."
    rm -rf student-submission
    rm -rf grading-area
}

# Check if the repository URL is provided
if [ $# -eq 0 ]; then
    echo "Error: No repository URL provided."
    exit 1
fi

# Setup grading area
cleanup
mkdir grading-area

# Clone the student's repository
git clone "$1" student-submission
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone repository."
    exit 1
fi
echo 'Finished cloning'

# Check if the expected file is present in the submission
if [ ! -f "student-submission/$EXPECTED_FILENAME" ]; then
    echo "Error: Expected file $EXPECTED_FILENAME not found in the submission."
    cleanup
    exit 1
fi

# Copy the student's submission and the test files to the grading area
cp student-submission/$EXPECTED_FILENAME grading-area/
cp TestListExamples.java grading-area/ # Replace with your actual test file

# Navigate to the grading area
cd grading-area

# Compile the student code and the test files
javac -cp .:../lib/hamcrest-core-1.3.jar:../lib/junit-4.13.2.jar *.java
if [ $? -ne 0 ]; then
    echo "Error: Compilation failed."
    cleanup
    exit 1
else
    echo "Compilation successful."
fi

# Define the test class name
TEST_CLASS_NAME="TestListExamples" # Replace with your actual test class name


# ...

# Run the tests
TEST_OUTPUT=$(java -cp "$CPATH" org.junit.runner.JUnitCore "$TEST_CLASS_NAME" 2>&1)
TEST_EXIT_CODE=$?

# Check if JUnitCore class was not found
if echo "$TEST_OUTPUT" | grep -q "ClassNotFoundException: org.junit.runner.JUnitCore"; then
    echo "Error: JUnit is not on the classpath or not installed."
    
    exit 1
fi

# Output the test results
echo "$TEST_OUTPUT"

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "All tests passed."
else
    # Parse the output for failed test details
    echo "Some tests failed. Here are the details:"
    echo "$TEST_OUTPUT" | grep "FAILURES!!!"
    echo "$TEST_OUTPUT" | grep "Tests run:"
    # Extract and print details of each failed test
    echo "$TEST_OUTPUT" | awk '/[1-9]\) /,/Caused by:/ {if ($0 !~ /Caused by:/) print}'
fi

# Clean up and return to the original directory
cd ..