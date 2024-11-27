FROM unit:1.33.0-minimal

# https://unit.nginx.org/howto/docker/#multilanguage-images
# First, we install the required tooling and add Unit's repo.
# RUN apt update && apt install -y curl apt-transport-https gnupg2 lsb-release \
#     && curl -o /usr/share/keyrings/nginx-keyring.gpg https://unit.nginx.org/keys/nginx-keyring.gpg \
#     && echo "deb [signed-by=/usr/share/keyrings/nginx-keyring.gpg] https://packages.nginx.org/unit/debian/ `lsb_release -cs` unit" > /etc/apt/sources.list.d/unit.list
# https://unit.nginx.org/installation/#official-packages > Repo installation script 
RUN apt update && apt install -y curl apt-transport-https gnupg2 lsb-release \
    && curl --output setup-unit https://raw.githubusercontent.com/nginx/unit/master/tools/setup-unit \
    && chmod +x setup-unit \
    && ./setup-unit repo-config

# Next, we install the necessary language module packages and perform cleanup.
RUN apt update && apt install -y unit-python3.11 unit-dev \
    python3.11 python3.11-venv python3-pip \
    wget build-essential libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev \
    && apt autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/*.list

# Create Self-Signed Certificate for HTTPS
COPY ./openssl.conf /openssl.conf
RUN openssl req -config /openssl.conf -newkey rsa -x509 -days 365 -out id.pem \
    && cat id.pem > /docker-entrypoint.d/fullchain_rsa.pem \
    && cat private_key.pem >> /docker-entrypoint.d/fullchain_rsa.pem

# NGINX Unit Config File
COPY ./nginx.conf /docker-entrypoint.d/config.json
