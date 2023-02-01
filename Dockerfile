# Build:
#
#   docker build -t databroker .
#
# Run:
#
#   docker run -it -p 8000:8000 -e TILED_SINGLE_USER_API_KEY=secret -v ./example_config.yml:/deploy/config.yml databroker

FROM ghcr.io/bluesky/tiled:v0.1.0a82 as base

FROM base as builder

WORKDIR /code

# Copy requirements over first so this layer is cached and we don't have to
# reinstall dependencies when only the databroker source has changed.
COPY requirements-server.txt /code/
RUN pip install --upgrade --no-cache-dir pip wheel
RUN pip install --upgrade --no-cache-dir -r /code/requirements-server.txt

COPY . .
# note requirements listed here but all deps should be already satisfied
RUN pip install .[server]

FROM base as runner

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV
