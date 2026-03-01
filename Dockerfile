FROM python:3.14-slim 

RUN apt-get update -qq
RUN apt-get install -y -qq python3 python3-pip python3-venv curl

ARG INSTALL_DIR="/opt/smtp-tunnel"
ARG CONFIG_DIR="/etc/smtp-tunnel"
ARG BIN_DIR="/usr/local/bin"

RUN mkdir -p "$INSTALL_DIR" && \
    chmod 755 "$INSTALL_DIR"

RUN mkdir -p "$CONFIG_DIR" && \
    chmod 700 "$CONFIG_DIR"

WORKDIR ${INSTALL_DIR}

# Copy the entire build context (everything except what's listed in `.dockerignore`) to `WORKDIR`
COPY . .

ARG PYTHON_FILES="server.py client.py common.py generate_certs.py"
ARG SCRIPTS="smtp-tunnel-adduser smtp-tunnel-deluser smtp-tunnel-listusers smtp-tunnel-update"

RUN for script in ${SCRIPTS}; do \
    # set to executable: 
    chmod +x "$INSTALL_DIR/$script"; \  
    # add a soft link in BIN_DIR:   
    ln -sf "$INSTALL_DIR/$script" "$BIN_DIR/$script"; \
    done;

RUN pip3 install --root-user-action=ignore -q -r "$INSTALL_DIR/requirements.txt" 2>/dev/null \
    || \
    pip3 install -q -r "$INSTALL_DIR/requirements.txt"

EXPOSE 587

CMD [ "python3", "/opt/smtp-tunnel/server.py", "-c", "/etc/smtp-tunnel/config.yaml" ]