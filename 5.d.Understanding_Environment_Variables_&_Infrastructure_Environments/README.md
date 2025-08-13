# Understanding Environment Variables & Infrastructure Enviornments

As we delve deeper into the world of technology and its building blocks, two essential concepts often come to the forefront: "Infrastructure Environments" and "Environment Variable." Despite both terms featuring "Environment", they play distict roles in the realm of scripting and software development. This common terminology can lead to confusion, making it crucial to distinguish and understand each concept from the outset.

## Infrastructure Environments 

Infrastructure Envrionments refer to various settings where software applications are developed, tested, and deployed, each serving a unique purpose in the software lifecycle.

Leets say you are working with a development team to build a FinTech product. They have 2 different AWS accounts. The journey would be something like;

1. **VirtualBox + Ubuntu:** The development environment where all local development is done on your laptop.

2. **AWS Account 1:** The testing environment where, after local development is completed, the code is pushed to an EC2 instance here for further testing.

3. **AWS Account 2:** The production environment, where after tests are completed in `AWS Account 1`, the code is pusshed to an EC2 instance in `AWS Account 2`, where the customers consume the Fintech product through a website.

Each setup is considered as an **Infrastructure Environment**.

On the other hand, environment variable are key-value pairs used in scripts or computer code to manage configuration values and control software behaviour dynamically.

## Environment Variables
 
Imagine your FinTech product needs to connect to a database to fetch financial data. However, the details of this database connection, like the database **URL, username** and **password** differ between your **development, testing,** and **production** environments.

If you need to develop a shell script that will be reused accross all the 3 different environments, then it is important to dynamically fetch the correct value for your connectivity to those environment.

Here is how environment variables comes into play:

### **Development Environment (VirtualBox + Ubuntu):**

**Environment Variables:**

-   DB_URL=localhost

-   DB_USER=test_user

-   DB_PASS=test_pass

Here, the environment variables point to a local database on your laptop where you can safely environment without affecting real or test data.

### **Testing Environment (AWS Account 1):**

**Environment Variables:**

-   DB_URL=testing-db.example.com

-   DB_USER=testing_user

-   DB_PASS=testing_pass

In this environment, the variables are configured to connect to a remote database dedicated to testing. This ensures that tests are performed in a controlled environment that simulates production setting without risking actual customer data.

### **Production Environment (AWS Account2):**

**Environment Variables:**

-   DB_URL=production-db.example.com

-   DB_USER=prod_user

-   DB_PASS=prod_pass

Finally, when the applictaion is running in the production environment, the environment variables switch to ensure the application connect to the live database. This is where real customer interaction happens, and the data needs to be accurate and secure.

By clarifying these differences early on, we set a solid foundation for navigating the complexities of technology development with greater ease and precision.

Now lets begin developing our shell script to manage cloud infrastructure.

## aws_cloud_manager.sh

By the end of this mini project, we would have started working on the **aws_cloud_manager.sh** script where environment variables will be defined, and command line arguments are added to control if the script should run for local environment, testing or production environment.

Developing a shell script is usually done by starting with incremental changes.

Lets beging by creating environment variable to determine if the script is running for local, testing, or production environment.

- If you are on Mac, open up your Mac Terminal

- If you are on Windows, login to your Ubuntu desktop in virtual box and open up the terminal.

- If you do not use Virtual box, spin up an EC2 instance and name it local so it represents yout local environment, then login to it

- Create a shell script with the name **aws_cloud_manager.sh**

- Put the code below into the file

~~~
#!/bin/bash

# Checking and acting on the environment variable
if [ "$ENVIRONMENT" == "local" ]; then
echo "Running script for Local Environment..."
# Commands for local environment
elif [ "$ENVIRONMENT" == "testing" ]; then
echo "Running script for Testing Environment..."
# Commands for testing environment
elif [ "$ENVIRONMENT" == "production" ]; then
echo "Running script for Production Environment..."
# Commands for production environment
else
echo "No environment specified or recognized."
exit 2
fi
~~~

- Give it the relevent permission to execute on your local terminal

~~~
sudo chmod +x aws_cloud_manager.sh
~~~

> This gives the user the permission the ability to execute the aws_cloud_manager.sh file

When executing the file you will get this

![No Environment specified](img/1.a.No_Environment.png)

This is because there is no **$ENVRIONMENT** variable set 

We can set the envrionment by inputting.

~~~
export ENVIRONMENT=production
~~~

We will get the output of 

![Success](img/1.b.Success.png)

Now, we can see how environment variables can be used to dynamically apply logic in the script based on the requirement you are trying to satisfy.

The **export** command is used to set key and values for envrionment variables.

You can also set the variable directly within he script. Like this:

~~~
#!/bin/bash

# Initialize environment variable
ENVIRONMENT="testing"

# Checking and acting on the environment variable
if [ "$ENVIRONMENT" == "local" ]; then
  echo "Running script for Local Environment..."
  # Commands for local environment
elif [ "$ENVIRONMENT" == "testing" ]; then
  echo "Running script for Testing Environment..."
  # Commands for testing environment
elif [ "$ENVIRONMENT" == "production" ]; then
  echo "Running script for Production Environment..."
  # Commands for production environment
else
  echo "No environment specified or recognized."
  exit 2
fi
~~~

Running this version of the script would mean everytime you run it, it will cinsider the logic for testing environment. Because the value has been "hard coded" in the script, and that is non longer dynamic.

The best way to do this would be use the command line arguments.

## Positional parameters in Shell scripting

As we have learned, hard-coding values directly into scripts is considered poor practice. Instead, we aim for flexibility by allowing scripts to accept input dynamically. This is where positional parameters comes in - a capability in shell scripting that enables passing arguments to scripts at runtime, and then replaces the argument with the parameter inside the script.

- The arguement passed to the script is the value that is provided at runtime.
    As in the case of the below where the argument is "testing" and it is also the value to the variable within the script.

~~~
./aws_cloud_manager.sh testing
~~~

- Inside the script we will have this;
~~~
ENVIRONMENT=$1
~~~

`$1` is the positional parameter which will be replaced by the argument passed to the script.

Because it is possible to pass multiple parameters to a scritp, dollar sign '$' is used to prefix the position of the argument passed to the script. Imagine if another variable within the script is called **NUMBER_OF_INSTANCES** that determines how many EC2 instances get provisioned, then calling the script might look like;

~~~
./aws_cloud_manager.sh testing 5
~~~

The positional parameters inside the script would then look like

~~~
ENVIRONMENT=$1
NUMBER_OF_INSTANCES=$2
~~~

- Each positional parameter within the script corresponds to a specific argument passed to the script, and each parameter has a position represented by an index number.

In the case of 
~~~
./aws_cloud_manager.sh testing 5
~~~
We have two positional parameters.

![Diagram](img/1.c.diagram.png)

> Notice that the script itself is in position of 0

### Condition to check the number of arguments

Creating shell scripts to meet specific requirements is one aspect of development, but ensuring theri cleanliness and freedom from bugs is equally crucial. Integrating logical checks periodically to validate data is considered a best practice in script development.

A prime example of this is verifying the number of arguments passed to the script, ensuring that the script recieves the correct input required for its execution, and providing clear guidance to users in case of incorrect usage.

Below code ensures that when the script is executed, exactly 1 argument is passed to it, otherwise it fails with an exit code of 1 and an shows a message telling the user how to use the script.
~~~
# Checking the number of arguments
if [ "$#" -ne 0 ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi
~~~

-   "$#" is a special variable that holds the number of arguements passed to the script.

-   "-ne" means "Not equal"

-   "$0" represent the positional parameter of , which is the script itself.

Hence, if number of arguments is not equal to "1", then show the echo message.

An updated script looks like this;

~~~
#!/bin/bash

# Checking the number of arguments
if [ "$#" -ne 1 ]; then
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

![Three_Envrionment](img/1.d.three_envrionment.png)

## Common Troubleshooting Issues

- **Script Fails with "No environment specified or recognized."**
  - Ensure you have set the `ENVIRONMENT` variable or passed the correct argument when running the script (e.g., `./aws_cloud_manager.sh testing`).
  - Check for typos in the environment name; only `local`, `testing`, or `production` are valid.

- **"Permission denied" when running the script**
  - Make sure the script has execute permissions. Run `chmod +x aws_cloud_manager.sh` to add execute permission.

- **"Usage: ./aws_cloud_manager.sh <environment>" error**
  - This means you did not provide the required argument. Run the script with one of the valid environments as an argument (e.g., `./aws_cloud_manager.sh local`).

- **Environment variables not being recognized**
  - If you set environment variables in the terminal, ensure you use the `export` command (e.g., `export ENVIRONMENT=production`) before running the script in the same terminal session.

- **Unexpected script behavior**
  - Double-check for typos in variable names and ensure you are using the correct shell (e.g., bash).
  - Make sure there are no hidden characters or formatting issues if you copied the script from a web page.

- **Script runs but does not perform expected actions**
  - Verify that the logic inside each environment block is correct and that any commands specific to your environment are present and properly configured.

---

If you encounter other issues, review the script for syntax errors, check the terminal output for error messages, and consult the documentation for your shell environment.

## Conclusion

Understanding the distinction between infrastructure environments and environment variables is crucial for building flexible, maintainable, and secure automation scripts. By leveraging environment variables and positional parameters, you can create scripts that dynamically adapt to different deployment scenarios—whether local, testing, or production—without hardcoding sensitive or environment-specific information. This approach not only streamlines your workflow but also reduces the risk of errors and enhances collaboration across teams. Mastering these foundational concepts prepares you to manage more complex infrastructure and automation tasks in real-world DevOps and cloud environments.

