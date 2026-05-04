FROM python:3.12-alpine3.22

# numpy/openblas require build tools on Alpine musl libc
# git is needed at runtime by GitPython (shaketune dependency)
RUN apk add --no-cache \
  git \
  openblas-dev \
  gcc \
  g++ \
  musl-dev \
  gfortran

RUN pip install --no-cache-dir uv

# Clone repos with minimal history to keep image small
RUN git clone --depth=1 https://github.com/Klipper3d/klipper.git /app/klipper
RUN git clone --depth=1 https://github.com/Frix-x/klippain-shaketune.git /app/klippain-shaketune

# Single venv for everything
RUN uv venv /app/.venv

# Install shaketune dependencies as documented
RUN uv pip install --python /app/.venv/bin/python \
  -r /app/klippain-shaketune/requirements.txt

# Make the cloned shaketune directory importable as a module
ENV PYTHONPATH=/app/klippain-shaketune

# Install Gradio for the web UI
RUN uv pip install --python /app/.venv/bin/python gradio

COPY app/main.py /app/main.py
RUN mkdir -p /tmp/shaketune

# Force headless matplotlib — no X display available in the container
ENV MPLBACKEND=Agg

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:7860 || exit 1

EXPOSE 7860

CMD ["/app/.venv/bin/python", "/app/main.py"]
