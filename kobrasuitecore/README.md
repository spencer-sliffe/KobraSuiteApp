# KobraSuite Django Backend

## Install and Run

1. **Clone the Repo**: Download and install Repository from [here](https://github.com/spencer-sliffe/KobraSuiteApp).
   - **macOS/Linux**: 
     ```bash
     git clone https://github.com/spencer-sliffe/KobraSuite.git
     cd KobraSuiteApp/kobrasuitecore
     ```
   - **Windows**:
     ```bash
     git clone https://github.com/spencer-sliffe/KobraSuite.git
     cd KobraSuiteApp\kobrasuitecore
     ```

2. **Start Venv**:
   - **macOS/Linux**: 
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```
   - **Windows**:
     ```bash
     python -m venv venv
     venv\Scripts\activate
     ```

3. **Install Dependencies**:
   - **macOS/Linux**: 
     ```bash
     pip install -r requirements.txt
     ```
   - **Windows**:
     ```bash
     pip install -r requirements.txt
     ```

4. **Setup .env**:
   - **macOS/Linux**: 
     - Create a `.env` file in the base `kobrasuitecore` directory (The one w/ manage.py and requirements.txt).
     - Use the following template and replace placeholders as needed:
       ```plaintext
       SECRET_KEY=SET_IN_LOCAL
       DEBUG=1
       CSRF_TRUSTED_ORIGINS=https://127.0.0.1
       SECURE_SSL_REDIRECT=0
       DBNAME=kobrasuite
       DBHOST=localhost
       DBUSER=SET_IN_LOCAL
       DBPASS=SET_IN_LOCAL
       CORS_ALLOWED_ORIGINS=SET_ME_IN_LOCAL
    
       DJANGO_SETTINGS_MODULE=kobrasuitecore.settings
    
       DBOPTIONS=disable
       
       TESTING=SET_ME_IN_LOCAL_
    
       DJANGO_ALLOW_ASYNC_UNSAFE=True

       REDIS_HOST='127.0.0.1'
       REDIS_PORT=6379
       OPENAI_API_KEY=SET_ME_IN_LOCAL
       ```
   - **Windows**: 
     - Same steps as macOS/Linux.

5. **Migrate**:
   - **macOS/Linux**: 
     ```bash
     python manage.py makemigrations
     python manage.py migrate
     ```
   - **Windows**:
     ```bash
     python manage.py makemigrations
     python manage.py migrate
     ```

6. **Run Django Project**:
   - **macOS/Linux**: 
     ```bash
     python -m daphne -b 0.0.0.0 -p 8000 kobrasuitecore.asgi:application
     ```
   - **Windows**:
     ```bash
     python -m daphne -b 0.0.0.0 -p 8000 kobrasuitecore.asgi:application
     ```

7. **Swagger UI/Admin**:
   ```plaintext
     http://0.0.0.0:8000/swagger
     http://0.0.0.0:8000/admin
   ```



**To build and run with Docker**
   - **macOS/Linux**: 
     ```bash
	 test -z "$(docker ps -q 2>/dev/null)" && osascript -e 'quit app "Docker"'
	 open --background -a Docker
     docker buildx build --platform linux/arm64 -t my-kobrasuite:latest . --no-cache
     docker run -it --platform linux/arm64 my-kobrasuite:latest /bin/sh
     ```
