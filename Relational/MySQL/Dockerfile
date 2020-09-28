FROM mysql:8.0.21

# Add the content of the 'data' directory to your image
# All scripts in docker-entrypoint-initdb.d/ are automatically
# executed during container startup in alphabetical order
COPY ./data /docker-entrypoint-initdb.d
