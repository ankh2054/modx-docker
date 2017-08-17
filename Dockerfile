FROM ubuntu:16.04
MAINTAINER - Charles Holtzkampf <charles.holtzkampf@gmail.com>




## Install php nginx mysql supervisor ###
########################################
RUN apt-get update && \
    apt-get install -y php-fpm php-cli php-gd php-mcrypt php-mysql php-curl \
                       nginx \
                       curl \
		       supervisor && \
    echo "mysql-server mysql-server/root_password password" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections && \
    apt-get install -y mysql-server && \


### Nginx ###
#############


# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy configuration files from the current directory
ADD ./nginx-site.conf /etc/nginx/sites-available/default
ADD ./nginx.conf /etc/nginx/

# nginx config
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf  # To ensure the container does not stop
RUN chown -R www-data:www-data /var/lib/nginx # Nginx needs access to create temporary files

# PHP FPM config changes
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf # To ensure the container does not stop
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini # Prevents PHP from executing losest file



### MODX ###
############

COPY modx.sh /tmp/modx.sh
RUN  sh /tmp/modx.sh && rm /tmp/modx.s

### Supervisor ###
##################

COPY mysql.conf nginxs.conf php-fpm.conf /etc/supervisor/conf.d



### Container configuration ###
###############################

EXPOSE 80
VOLUME /home/modx

# Set the default command to execute
# when creating a new container

CMD start.sh
