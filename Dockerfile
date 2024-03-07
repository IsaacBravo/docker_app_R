FROM rocker/shiny:latest

# Set the working directory within the Docker image
WORKDIR /docker_app/code_app

# Copy the R scripts from the local directory into the Docker image
COPY code_app/* ./
# COPY code_app/* ./starter
# COPY code_app/* ./server
# COPY code_app/* ./ui

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

RUN install2.r --error \
    pacman \
    shiny  \
    shinyjs  \
    shinyalert  \
    shinyBS  \
    shinyWidgets  \
    shinycssloaders  \
    shinythemes \
    DBI  \
    DT \
    dbplyr  \
    spsComps  \
    htmltools  \
    dplyr \
    duckdb \
    stringr \
    shinymanager

# expose port
EXPOSE 3838

# CMD ["Rscript", "app.R" "shiny::runApp('./app', port = 5024, host='0.0.0.0')"]
CMD ["Rscript", "starter.R"]
