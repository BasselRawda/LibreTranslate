FROM python:3.11.9-slim-bullseye as builder

WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
  && apt-get -qqq install --no-install-recommends -y pkg-config gcc g++ \
  && apt-get upgrade --assume-yes \
  && apt-get clean \
  && rm -rf /var/lib/apt

RUN python -m venv venv && ./venv/bin/pip install --no-cache-dir --upgrade pip
RUN ./venv/bin/pip install numpy==1.26.4
COPY . .

# Install package from source code, compile translations
RUN ./venv/bin/pip install Babel==2.12.1 && ./venv/bin/python scripts/compile_locales.py \
  && ./venv/bin/pip install torch==2.0.1 --extra-index-url https://download.pytorch.org/whl/cpu \
  && ./venv/bin/pip install . \
  && ./venv/bin/pip cache purge

FROM python:3.11.9-slim-bullseye

ARG with_models=true
ARG models=""

RUN addgroup --system --gid 1032 libretranslate && adduser --system --uid 1032 libretranslate && mkdir -p /home/libretranslate/.local && chown -R libretranslate:libretranslate /home/libretranslate/.local
USER libretranslate

COPY --from=builder --chown=1032:1032 /app /app
WORKDIR /app

COPY --from=builder --chown=1032:1032 /app/venv/bin/ltmanage /usr/bin/

RUN if [ "$with_models" = "true" ]; then  \
  # initialize the language models
  if [ ! -z "$models" ]; then \
  ./venv/bin/python scripts/install_models.py --load_only_lang_codes "$models";   \
  else \
  ./venv/bin/python scripts/install_models.py;  \
  fi \
  fi

# Set the ENTRYPOINT to ensure that the run.sh script is executed with the correct interpreter
ENTRYPOINT ["/bin/bash", "/app/run.sh"]
