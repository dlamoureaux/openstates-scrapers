FROM python:3.7-slim AS base
LABEL maintainer="James Turk <james@openstates.org>"

ENV PYTHONIOENCODING 'utf-8'
ENV LANG 'C.UTF-8'
ENV PUPA_ENV /opt/openstates/venv-pupa/

RUN apt update && apt install -y --no-install-recommends \
      git \
      build-essential \
      curl \
      unzip \
      libssl-dev \
      libffi-dev \
      freetds-dev \
      python3-virtualenv \
      libxml2-dev \
      libxslt-dev \
      libyaml-dev \
      poppler-utils \
      libpq-dev \
      postgresql-client \ 
      libgdal-dev \
      libgeos-dev \
      awscli \
      mdbtools && \
      rm -rf /var/lib/apt/lists/*

ADD . /opt/openstates/openstates

RUN python3 -m venv /opt/openstates/venv-pupa/ && \
      /opt/openstates/venv-pupa/bin/pip install -e git+https://github.com/opencivicdata/python-opencivicdata-django.git#egg=opencivicdata && \
      /opt/openstates/venv-pupa/bin/pip install -e git+https://github.com/opencivicdata/pupa.git#egg=pupa && \
      /opt/openstates/venv-pupa/bin/pip install -r /opt/openstates/openstates/requirements.txt


WORKDIR /opt/openstates/openstates/
ENTRYPOINT ["/opt/openstates/openstates/pupa-scrape.sh"]

FROM base AS california
RUN apt update && apt install -y --no-install-recommends \
      mariadb-server \
      mariadb-client \
      libmariadb-dev
RUN /opt/openstates/venv-pupa/bin/pip install -r /opt/openstates/openstates/requirements.ca.txt
