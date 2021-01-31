FROM ubuntu:hirsute

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libpcre3 \
    libpcre3-dev \
    libpq-dev \
    postgresql-client \
    python3 \
    python3-pip \
    nginx \
    nginx-extras \
    supervisor

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

COPY requirements.txt /tmp
COPY test1/ /django-home

RUN pip install -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

COPY configs/uwsgi.ini /etc/uwsgi/
COPY configs/supervisord.conf /etc/supervisor/conf.d/webserver.conf

COPY configs/start.sh /start.sh
COPY configs/entrypoint.sh /entrypoint.sh

RUN chmod +x /start.sh && chmod +x /entrypoint.sh

ENV threads=4
ENV UWSGI_SOCKET="127.0.0.1:29000"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]


