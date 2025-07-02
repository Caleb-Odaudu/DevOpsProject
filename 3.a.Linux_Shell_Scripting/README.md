# Linux Shell Scripting

## Introduction
With the thousands of commands available to the command line user, how can we remember them all? The answer is, we don't. The real power of the computer is its ability to do the work for us. To do that, we use the power of the shell to automate things. We write shell scripts.

## What is Shell Scripting
Imagine you are tasked with setting up new workstations and user accounts regularly at your job. Instead of manually creating each folder and user account, a simple shell script serves as your efficient digital helper. By automating the creation of multiple directories and user accounts with just a few lines of code, it saves you considerable time and effort, allowing you to concentrate on more critical aspects of your work.

Shell scripting is the process of writing and executing a series of instructions in a shell to automate tasks. A shell script is essentially a script or program written in a shell language, such as `Bash`, `sh`, `zsh`, or `PowerShell`.

### Task 1

1. Create a folder on an Ubuntu server and name it shell-scripting

    - First, log in to the AWS console, where you can access the EC2 instance already created. Then click on Instance State and select "Start instance."
    ![Instance started](img/Launched_instance.png)
    - Connect to the instance using your preferred method, either SSH or EC2 Instance Connect.
    ![EC2_connect](img/EC2_instance_connect.png)

    - Once you are on the Ubuntu server, make the directory using:
    ~~~
    mkdir shell-scripting 
    ~~~

2. Using the `vim` editor, create a file called **my_first_shell_script.sh**
~~~
vim my_first_shell_script.sh
~~~

3. Put this shell script code into the file:
~~~
#!/bin/bash

# Create directories
mkdir Folder1
mkdir Folder2
mkdir Folder3

# Create users
sudo useradd user1
sudo useradd user2
sudo useradd user3

~~~

4. Use the `cd` command to change into the **shell-scripting** directory.

5. Use the `ls -latr` command to confirm that the file has been created.

![ls_-latr](img/ls_-latr.png)

Something to take notice of about the permissions of the newly created file is this **-rw-rw-r--** which means:
1. The owner of the file has read (r) and write (w) permissions.
2. Members of the file's group have the read (r) permission.
3. Others have the read (r) permission.

However, no one has the execute permission, so the script cannot be executed.

To execute the script, you would typically do something like this:
~~~
./my_first_shell_script.sh
~~~

The `./` prefix to the file indicates that the command should look for the file in the current directory.

However, when you hit enter, you will receive a response saying "Permission denied."

![Permission_denied](img/perm_denied.png)

This can be solved by giving the file the necessary permission it requires.

As you notice, there is a **bash** at the beginning of the error message. It indicates that the error message is coming from the **Bash shell** itself. **Bash** is the command interpreter or shell that you are using in the terminal to execute commands.

### Task 2

1. Add the execute permission for the **owner** to be able to execute the shell script.
~~~
chmod u+x my_first_shell_script.sh
~~~

After running this command, the owner of the file will be able to execute (run) the shell script directly from the terminal.

2. Run the shell script.
~~~
./my_first_shell_script.sh
~~~

3. Evaluate and ensure that 3 folders are created.
To verify that the folders have been created, simply use the `ls` command.

![folder created](img/Ls_folder.png)

4. Evaluate and ensure that 3 users are created on the Linux server.
To verify that the users have been created, simply use the `id` command.
Input these commands separately:
~~~
id user1

id user2

id user3
~~~

![id_verification](img/id_verif.png)

## What is a Shebang (#!/bin/bash)?

Notice at the beginning of the shell script, we have `#!/bin/bash` written there. This is what is called a **shebang**. It is a special notation used in Unix-like operating systems like Linux to specify the interpreter that should be used to execute the script. In this case, `#!/bin/bash` specifically indicates that the **Bash** shell should be used to interpret and execute the script.

You can explore the **/bin** folder and see the different programs in there. **Bash** is one of them, which is used as the interpreter in that script. If we wanted to use another shell like sh, the shebang would be updated to `#!/bin/sh`.

![bin/bash](img/bin/bash.png)

**/bin/bash**: This is the absolute path to the Bash shell executable. It tells the system to use the Bash interpreter located at /bin/bash to run the script.

Without a shebang line, the system may not know how to interpret and execute the script, and you may need to explicitly specify the interpreter when running the script.

## Variable Declaration and Initialization

In programming generally, not just shell scripting, **variables** are essential for creating dynamic and flexible programs.

Variables can store data of various types such as numbers, strings, and arrays. You can assign values to variables using the **=** operator, and access their values using the variable name preceded by a $ sign.

For example:
~~~
name="Jane"
~~~

From the example above, **Jane** was assigned to the variable **name**.

Now that the variable is assigned, we will display how to use it.

### Retrieving value from a variable

After assigning a value to a variable, as shown in the previous example where we assigned 'Jane' to the variable name, you can utilize this variable in various ways in your script or program. One of the most straightforward methods to use or retrieve the value stored in a variable is by echoing it back to the console. This is done using the **echo** command in shell scripting.
~~~
echo $name
~~~

This command instructs the shell to print the value of `name` to your screen, which in our case, would output **Jane**.

![Variable](img/variable.png)

## Troubleshooting Common Shell Script Errors

When working with shell scripts, you may encounter some common errors. Here are a few and how to resolve them:

- **Permission denied**  
  This error occurs when you try to execute a script that does not have execute permissions.  
  **Solution:** Use `chmod u+x scriptname.sh` to add execute permission for the owner.

- **command not found**  
  This error means the shell cannot find the command you typed, either because of a typo or because the command is not installed.  
  **Solution:** Double-check the spelling of your command. If it is a custom script, make sure to use `./scriptname.sh` to run it from the current directory. If it is a system command, ensure the relevant package is installed.

- **No such file or directory**  
  This usually means you are referencing a file or directory that does not exist.  
  **Solution:** Check the file or directory name and path for typos, and ensure it exists before referencing it in your script.

- **Syntax error**  
  This can happen if there are missing quotes, parentheses, or other syntax mistakes in your script.  
  **Solution:** Carefully review your script for typos or missing characters. Use an editor with syntax highlighting to help spot errors.

---

## Best Practices for Writing Shell Scripts

- **Use Comments:**  
  Add comments (lines starting with `#`) to explain what your script or specific commands do. This makes your script easier to understand and maintain.

- **Check for Existing Files/Users:**  
  Before creating files, directories, or users, check if they already exist to avoid errors. For example:
  ~~~bash
  if [ ! -d "Folder1" ]; then
    mkdir Folder1
  fi

  if id "user1" &>/dev/null; then
    echo "user1 already exists"
  else
    sudo useradd user1
  fi
  ~~~

- **Use Meaningful Variable Names:**  
  Choose variable names that clearly describe their purpose.

- **Set the Shebang Line:**  
  Always start your script with the appropriate shebang (e.g., `#!/bin/bash`) to specify the interpreter.

- **Handle Errors Gracefully:**  
  Use conditional statements to handle possible errors and provide informative messages to the user.

- **Test Your Script:**  
  Run your script in a safe environment before using it in production to ensure it works as expected.

By following these best practices and troubleshooting tips, you can write more reliable, maintainable, and user-friendly shell scripts.