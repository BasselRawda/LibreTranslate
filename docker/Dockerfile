FROM python:3.11.9-slim-bullseye as builder

WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
  && apt-get -qqq install --no-install-recommends -y pkg-config gcc g++ \
  && apt-get upgrade --assume-yes \
  && apt-get clean \
  && rm -rf /var/lib/apt

RUN python -m venv venv && ./venv/bin/pip install --no-cache-dir --upgrade pip

COPY . /app

# Install dependencies with detailed logging and error checking
RUN /app/venv/bin/pip install -r /app/requirements.txt && echo "Dependencies installed successfully" \
  || { echo "Dependencies installation failed"; exit 1; }

RUN /app/venv/bin/pip install torch==2.0.1 --extra-index-url https://download.pytorch.org/whl/cpu && echo "Torch installed successfully" \
  || { echo "Torch installation failed"; exit 1; }

# Run the install_models.py script
RUN /app/venv/bin/python /app/scripts/install_models.py && echo "Models installed successfully" \
  || { echo "Model installation failed"; exit 1; }

# Install the package from the app directory
RUN /app/venv/bin/pip install /app && echo "Package installed successfully" \
  || { echo "Package installation failed"; exit 1; }

  # Compile translations separately
#RUN ./venv/bin/python scripts/compile_locales.py && echo "Locales compiled successfully" \
#  || { echo "Locale compilation failed"; exit 1; }
# Clean up pip cache
RUN /app/venv/bin/pip cache purge

FROM python:3.11.9-slim-bullseye

ARG with_models=false
ARG models=""

RUN addgroup --system --gid 1032 libretranslate \
  && adduser --system --uid 1032 libretranslate \
  && mkdir -p /home/libretranslate/.local \
  && chown -R libretranslate:libretranslate /home/libretranslate/.local

USER libretranslate

COPY --from=builder --chown=1032:1032 /app /app
WORKDIR /app

COPY --from=builder --chown=1032:1032 /app/venv/bin/ltmanage /usr/bin/

RUN if [ "$with_models" = "true" ]; then \
  if [ ! -z "$models" ]; then \
    /app/venv/bin/python /app/scripts/install_models.py --load_only_lang_codes "$models"; \
  else \
    /app/venv/bin/python /app/scripts/install_models.py; \
  fi \
fi

EXPOSE 5000

ENTRYPOINT ["/app/venv/bin/libretranslate"]
CMD ["--host", "0.0.0.0", "--port", "${PORT}"]
