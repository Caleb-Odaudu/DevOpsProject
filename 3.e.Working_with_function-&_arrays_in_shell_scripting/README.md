# Working wiht functions

In this mini project, my goal is to develop a shell script for a client of DataWise Solutions that automates the setup of EC2 instances and S3 buckets using AWS. The main technical focus is mastering **Functions** in shell scripting — a crucial practice for writing organized, reusable, and maintainable code.

## Functions
Functions help structure code logically and improve readability. They encapsulate specific logic, such as checking arguments or verifying environment setup. Refactoring scripts with functions mirrors real-world development patterns, where clarity and modular design are key.

Lets consider the following logic and encapsulate them in functions

- Checking for script arguments and environment variables
- Validating AWS CLI installation and AWS profile configuration
- Executing conditional logic based on deployment environments

To create a function in a shell script, you simply have to define it using the following syntax:

~~~
function_name() {"\n    # Function body\n    # You can place any commands or logic here\n"}
~~~
**Breakdown of syntax**:
- **function_name:** This is the name of your function.
- **():** Parenthesses are used to define the function. Although they can be omitted in simpler cases, it is good practice to include them for clarity.
- **{}:** Curly brackets enclose the body of the function, where you are able to define the command or logic that the function will execute.
### Function: Check if script has an argument
Here is a code without a function:
~~~
#!/bin/bash

# Checking the number of arguments
if [ "$#" -ne 0 ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

# Accessing the first argument
ENVIRONMENT=$1

# Acting based on the argument value
if [ "$ENVIRONMENT" == "local" ]; then
  echo "Running script for Local Environment..."
elif [ "$ENVIRONMENT" == "testing" ]; then
  echo "Running script for Testing Environment..."
elif [ "$ENVIRONMENT" == "production" ]; then
  echo "Running script for Production Environment..."
else
  echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
  exit 2
fi
~~~
Below is a code with a function called **check_num_of_args**:
~~~
#!/bin/bash

check_num_of_args() {"\n# Checking the number of arguments\nif [ \"$#\" -ne 0 ]; then\n    echo \"Usage: $0 <environment>\"\n    exit 1\nfi\n"}

# Accessing the first argument
ENVIRONMENT=$1

# Acting based on the argument value
if [ "$ENVIRONMENT" == "local" ]; then
  echo "Running script for Local Environment..."
elif [ "$ENVIRONMENT" == "testing" ]; then
  echo "Running script for Testing Environment..."
elif [ "$ENVIRONMENT" == "production" ]; then
  echo "Running script for Production Environment..."
else
  echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
  exit 2
fi
~~~

When a function is defined in a shell script, it remains inactive until it is invoked or called within the script. To execute the code within the function, you must place a call to the function in a relevent part of your script.

It's crucial to consider the order in which the interpreter evaluate each line of code. Placing the function where it locally fits within the flow of your script ensures that it is available and ready to be executed when needed. This organisation helps maintain the readability and coherence of your script, making it easier to understand and debug.

This is what it looks like:
~~~
#!/bin/bash

# Environment variables
ENVIRONMENT=$1

check_num_of_args() {"\n# Checking the number of arguments\nif [ \"$#\" -ne 0 ]; then\n    echo \"Usage: $0 <environment>\"\n    exit 1\nfi\n"}

check_num_of_args()

# Acting based on the argument value
if [ "$ENVIRONMENT" == "local" ]; then
  echo "Running script for Local Environment..."
elif [ "$ENVIRONMENT" == "testing" ]; then
  echo "Running script for Testing Environment..."
elif [ "$ENVIRONMENT" == "production" ]; then
  echo "Running script for Production Environment..."
else
  echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
  exit 2
fi
~~~
With a refactored version of the code, we now have the flow like this;
1. Environment variable moved to the top
2. Function defined
3. Function call
4. Activate based on infrastructure environment section

Another way to display the code is to encapsulare the number 4 -activate infrastructure environment- in a function and call all the function at the end of the script. This is what you would see most times in the real world.

This is what it looks like:
~~~
#!/bin/bash

# Environment variables
ENVIRONMENT=$1

check_num_of_args() {"\n# Checking the number of arguments\nif [ \"$#\" -ne 0 ]; then\n    echo \"Usage: $0 <environment>\"\n    exit 1\nfi\n"}

activate_infra_environment() {"\n# Acting based on the argument value\nif [ \"$ENVIRONMENT\" == \"local\" ]; then\n  echo \"Running script for Local Environment...\"\nelif [ \"$ENVIRONMENT\" == \"testing\" ]; then\n  echo \"Running script for Testing Environment...\"\nelif [ \"$ENVIRONMENT\" == \"production\" ]; then\n  echo \"Running script for Production Environment...\"\nelse\n  echo \"Invalid environment specified. Please use 'local', 'testing', or 'production'.\"\n  exit 2\nfi\n"}

check_num_of_args
activate_infra_environment
~~~

## Check if AWS CLI is installed:
~~~
#!/bin/bash

# Function to check if AWS CLI is installed
check_aws_cli() {"\n    if ! command -v aws &> /dev/null; then\n        echo \"AWS CLI is not installed. Please install it before proceeding.\"\n        return 1\n    fi\n"}
~~~
### Breakdown of the Command

**if ! command -v aws &> /dev/null; then**

- **if ...; then**: This starts an if statement in Bash. The commands inside the if block will run if the condition is true.

- **!**: The exclamation mark negates the exit status of the command that follows. In Bash, a command returns 0 (success) if it runs without errors. By adding `!`, the if statement will be true if the command fails (returns a non-zero exit status).

- **command -v aws**: This checks if the `aws` command (the AWS CLI) is available in your system's PATH. If `aws` is installed, this command returns the path to the executable; otherwise, it returns nothing and exits with a non-zero status.

- **&> /dev/null**: This redirects both standard output and standard error to `/dev/null`, effectively silencing any output from the command. This keeps the script output clean.

This line checks if the AWS CLI is installed. If it is **not** installed, the commands inside the if block will execute (such as printing an error message or exiting the script).

## Check if environment variable exists to authenticate to AWS

To programmatically create resources in AWS, oyu need to configure authentication using various means such as environment variable, configuration files, or IAM riles.

The **~/.aws/credential** and **~/.aws/config** files are commonly used to store AWS credentials and configuration settings, respectively.

Running the **aws configure** command create these files. Using the cat command to open them and see the content

### Credential File (~/.aws/credentials)

~~~
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY

[profile testing]
aws_access_key_id = YOUR_TESTING_ENVIRONMENT_ACCESS_KEY_ID
aws_secret_access_key = YOUR_TESTING_ENVIRONMENT_SECRET_ACCESS_KEY

[profile production]
aws_access_key_id = YOUR_PRODUCTION_ENVIRONMENT_ACCESS_KEY_ID
aws_secret_access_key = YOUR_PRODUCTION_ENVIRONMENT_SECRET_ACCESS_KEY
~~~

The credential file typically contains AWS access key ID and secret access key pairs. At first it will only have the default section. But it is possible to add other envionments as required, like the testing and production environment shown above.

### Config File (~/.aws/config): 
The config file stores configuration setting for AWS services and clients. It can include settings such as default region, output format, and profiles. An example config file might look like this:
~~~
[default]
region = us-east-1
output = json

[profile testing]
region = us-west-2
output = json

[profile production]
region = us-west-2
output = json
~~~

A profile will enable you to easily switch between different AWS configurations. If you set an environment variable by runnig the command **export AWS_PROFILE=testing** - this will pick up the configuration from both file and authenticate you to the testing environments.

**AWS Profile** The AWS_PROFILE environment variable allows users to specify which profile to use from their AWS config and credential files. If AWS_PROFILE is not set, the default profile is used.

Here is what the fuction looks like:
~~~
#!/bin/bash

# Function to check if AWS profile is set
check_aws_profile() {"\n    if [ -z \"$AWS_PROFILE\" ]; then\n        echo \"AWS profile environment variable is not set.\"\n        return 1\n    fi\n"}
~~~
- The **-z** flag is used to test if the value of the string variable has zero length, meaning it is empty or null.

This is the updated shell script:
~~~
#!/bin/bash

# Environment variables
ENVIRONMENT=$1

check_num_of_args() {"\n# Checking the number of arguments\nif [ \"$#\" -ne 0 ]; then\n    echo \"Usage: $0 <environment>\"\n    exit 1\nfi\n"}

activate_infra_environment() {"\n# Acting based on the argument value\nif [ \"$ENVIRONMENT\" == \"local\" ]; then\n  echo \"Running script for Local Environment...\"\nelif [ \"$ENVIRONMENT\" == \"testing\" ]; then\n  echo \"Running script for Testing Environment...\"\nelif [ \"$ENVIRONMENT\" == \"production\" ]; then\n  echo \"Running script for Production Environment...\"\nelse\n  echo \"Invalid environment specified. Please use 'local', 'testing', or 'production'.\"\n  exit 2\nfi\n"}

# Function to check if AWS CLI is installed
check_aws_cli() {"\n    if ! command -v aws &> /dev/null; then\n        echo \"AWS CLI is not installed. Please install it before proceeding.\"\n        return 1\n    fi\n"}

# Function to check if AWS profile is set
check_aws_profile() {"\n    if [ -z \"$AWS_PROFILE\" ]; then\n        echo \"AWS profile environment variable is not set.\"\n        return 1\n    fi\n"}

check_num_of_args
activate_infra_environment
check_aws_cli
check_aws_profile
~~~

## Summary

In this mini project, I learned how to use functions and arrays in shell scripting to create modular, reusable, and maintainable automation scripts for DevOps tasks. I practiced encapsulating logic into functions for argument validation, environment setup, AWS CLI checks, and AWS profile verification, which improved the clarity and structure of my scripts. I also explored how to manage AWS authentication using environment variables and configuration files, making it easier to switch between different environments. These skills are essential for building robust automation scripts that are easy to debug, extend, and collaborate on in real-world DevOps environments.

