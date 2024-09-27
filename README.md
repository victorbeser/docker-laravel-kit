# The better way to use Docker & Laravel together

| Docker | Laravel |
|--------|---------|
| <img src="https://www.docker.com/wp-content/uploads/2023/05/symbol_blue-docker-logo.png" width="200px" height="120px" /> | <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Laravel.svg/1200px-Laravel.svg.png" width="200px" height="180px" /> |

Imagine a modern development environment widely adopted by large companies around the world. 
With Docker and Laravel, I offer you an experience that goes beyond the conventional, with all installations pre-configured for you. 
This means more agility, efficiency, and a focus on what truly matters: creating innovative solutions.

## Techs

- **Laravel**: A PHP Framework for web development.
- **Docker**: Containerization platform.

## Requirements

Before we start you will need this:

- [PHP 7.3+](https://www.php.net/downloads)
- [Composer](https://getcomposer.org/download/)
- [Docker](https://www.docker.com/get-started)
- [Git](https://git-scm.com/downloads)

## How-to

1. Let's start our Laravel project (i suggest you to use Laravel 8.*):

   ```bash
   composer create-project --prefer-dist laravel/laravel your-project-name "8.*"

2. Get this repo as a clone into your system:

   ```bash
   git clone https://github.com/victorbeser/docker-laravel-kit.git

3. Copy and paste all the files of 'docker-laravel-kit' folder to 'your-project-name' project Laravel folder;
   
   ```bash
   It should be like this:
   /your-project-name/
     - (dot)docker
     - .dockerignore
     - docker-compose.yml
     - Dockerfile

4. Rename the (dot)docker folder to .docker and the (dot)dockerignore to .dockerignore;
5. Now we need to change some files to work correctly:
   
   ```bash
   Dockerfile
   ENV PROJECT_NAME mywebsite-test # Change the 'mywebsite-test' variable with the name of your application

   docker-compose.yml
   image: yourname/PROJECT_NAME:latest # Change the 'yourname' for your desired name and the 'PROJECT_NAME' for the name of your application
   container_name: PROJECT_NAME_CONTAINER # Change the PROJECT_NAME_CONTAINER for the name of your application, like MYAPP_CONTAINER or something like this
   volumes:
      - .:/var/www/html/PROJECT_NAME # Change the 'PROJECT_NAME' for the name of your application

   .docker/vhost.conf
   DocumentRoot /var/www/html/PROJECT_NAME/public # Change the 'PROJECT_NAME' for the name of your application
   <Directory /var/www/html/PROJECT_NAME/public> # Change the 'PROJECT_NAME' for the name of your application

6. Open some terminal/cmd in your project's folder and type the following command to initiate the building of your container:
   
   ```bash
   docker-compose build

7. Now use the following command to start your container:
   
   ```bash
   docker-compose up -d

8. Okay then, we need to install our packages into the container, use the following command to access the bash of your container:
   
   ```bash
   docker-compose exec laravel bash # Note: You can check the name of the "service" using the command 'docker-compose ps'


9. This isn't necessary exactly, we have this in Dockerfile but use this command just to be sure!
   
   ```bash
   composer install 
 
Now you should be able to access your project and see the Laravel's home page without any problems in http://localhost:8084/

![image](https://github.com/user-attachments/assets/94d5a9bc-fa16-42b2-a64e-6798fbf059c5)


Note: You can change the port in 'docker-compose.yml':

   ```bash
   docker-compose.yml
   ports:
      - "8084:80" # Change here the 8084 port
   ```

Now that you got your Back-End web application working very well try creating your Front-End web application with React JS & Docker <a href="https://github.com/victorbeser/docker-reactjs-kit">clicking here</a>!
