# golang:alpine3.14
FROM golang@sha256:5ce2785c82a96349131913879a603fc44d9c10d438f61bba84ee6a1ef03f6c6f

# tools in /usr/local/bin/
# plugins in /usr/share/plugins
# wordlists in /usr/share/wordlists/
# templates in /usr/share/templates/
# extensions in /usr/share/extensions/
# signatures in /usr/share/signatures/

# set golang and python in path
RUN echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc
RUN echo 'export PATH="$(python3 -m site --user-base)/bin:${PATH}"' >> ~/.bashrc

# general setup
RUN mkdir -p /usr/share/{plugins,wordlists,extensions,templates,signatures}
RUN apk update
RUN apk add --no-cache python3 py3-pip && \
    pip3 install --upgrade pip setuptools
RUN apk add --no-cache ca-certificates curl wget nmap netcat-openbsd \
                       bind-tools git less openssh build-base libzip-dev zip

# secrets
RUN go get -u -v github.com/eth0izzle/shhgit
RUN mkdir -p /usr/share/signatures/eth0izzle-signatures/ && \
    curl -o /usr/share/signatures/eth0izzle-signatures/config.yaml https://raw.githubusercontent.com/eth0izzle/shhgit/master/config.yaml
RUN pip3 install truffleHog
RUN GO111MODULE=on go get github.com/zricethezav/gitleaks/v7
RUN pip3 install detect-secrets
RUN git clone --depth=1 https://github.com/awslabs/git-secrets.git /usr/local/git-secrets && \
    cd /usr/local/git-secrets && make install
RUN apk add --no-cache --update nodejs npm && \
    git clone --depth=1 https://github.com/auth0/repo-supervisor.git /usr/local/repo-supervisor && \
    cd /usr/local/repo-supervisor && npm ci && npm run build

# enumeration
RUN go install github.com/OJ/gobuster/v3@latest
RUN python3 -m pip install dirsearch
RUN go get -u -v go get github.com/dwisiswant0/wadl-dumper
RUN go get -u -v github.com/ffuf/ffuf
RUN go get -u -v github.com/OWASP/Amass/v3/...
RUN go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest && \
    git clone --depth=1 https://github.com/projectdiscovery/nuclei-templates.git /usr/share/templates/nuclei-templates
RUN GO111MODULE=on go get -u -v github.com/jaeles-project/jaeles && \
    GO111MODULE=on go get -u github.com/jaeles-project/gospider && \
    git clone --depth=1 https://github.com/jaeles-project/jaeles-signatures.git /usr/share/signatures/jaeles-signatures
RUN pip3 install --upgrade arjun
RUN git clone --depth=1 https://github.com/devanshbatham/ParamSpider /usr/local/ParamSpider && \
    cd /usr/local/ParamSpider && pip3 install -r requirements.txt
RUN git clone --depth=1 https://github.com/mseclab/PyJFuzz.git /usr/local/PyJFuzz && \
    cd /usr/local/PyJFuzz && python3 setup.py install && \
    cd .. && pip3 install -r requirements.txt
RUN git clone --depth=1 https://github.com/assetnote/kiterunner /usr/local/kiterunner && \
    make build && ln -s $(pwd)/dist/kr /usr/local/bin/kr && \
    ln -s /usr/local/kiterunner/api-signatures /usr/share/signatures/kiterunner-api-signatures

# burp extentions
RUN cd /usr/local/extensions && \
    git clone --depth=1 https://github.com/portswigger/wsdl-wizard && \
    git clone --depth=1 https://github.com/NetSPI/Wsdler && \
    git clone --depth=1  https://github.com/SecurityInnovation/AuthMatrix.git && \
    git clone --depth=1 https://github.com/PortSwigger/autorize.git && \
    git clone --depth=1 https://github.com/portswigger/auth-analyzer && \
    git clone --depth=1 https://github.com/doyensec/inql && \
    git clone --depth=1 https://github.com/wallarm/jwt-heartbreaker.git && \
    git clone --depth=1 https://github.com/PortSwigger/json-web-token-attacker.git

# graphql
RUN apk add --no-cache --update nodejs npm && \
    npm install -g get-graphql-schema

# traffic analysis
RUN apk add --no-cache --update mitmproxy wireshark xxd protoc
RUN cd /usr/local/plugins && \
    git clone --depth=1  https://github.com/128technology/protobuf_dissector.git

# android
RUN pip3 install apkleaks

# wayback machine
RUN go get -u -v github.com/tomnomnom/waybackurls
RUN GO111MODULE=on go get -u -v github.com/lc/gau

# other
RUN apk add --no-cache --update python2 py3-pip && \
    git clone --depth=1  https://github.com/flipkart-incubator/Astra /usr/local/Astra && \
    cd /usr/local/Astra && sudo pip2 install -r requirements.txt
RUN go get -u -v github.com/bncrypted/apidor
RUN git clone --depth=1 https://github.com/ant4g0nist/susanoo /usr/local/susanoo && \
    cd /usr/local/susanoo && pip3 install -r requirements.txt
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && \
    rustup component add rustfmt && rustup component add clippy && \
    git clone --depth=1 https://gitlab.com/dee-see/graphql-path-enum /usr/local/graphql-path-enum && \
    cd /usr/local/graphql-path-enum && cargo build
RUN git clone --recursive --depth=1 git@github.com:trailofbits/protofuzz.git /usr/local/protofuzz && \
    cd /usr/local/protofuzz && python3 setup.py install
RUN git clone --depth=1 https://github.com/ticarpi/jwt_tool /usr/local/jwt_tool && \
    cd /usr/local/jwt_tool && python3 -m pip install termcolor cprint pycryptodomex requests
RUN npm install --global jwt-cracker
RUN git clone --depth=1 https://github.com/AresS31/jwtcat /usr/local/jwtcat && \
    cd /usr/local/jwtcat && python3 -m pip install -r requirements.txt
RUN git clone --depth=1 https://github.com/silentsignal/rsa_sign2n /usr/local/rsa_sig2n
RUN git clone --depth=1 https://github.com/ticarpi/jwt_tool /usr/local/jwt_tool && \
    cd /usr/local/jwt_tool && python3 -m pip install termcolor cprint pycryptodomex requests
RUN git clone --depth=1 https://github.com/AresS31/jwtcat /usr/local/jwtcat && \
    cd /usr/local/jwtcat && python3 -m pip install -r requirements.txt
RUN pip3 install jwtxploiter
RUN pip3 install apicheck-package-manager && \
    echo 'export PATH="$HOME/.apicheck_manager/bin:$PATH"' >> ~/.bashrc && \
    acp install jwtchk && \
    apc install acurl && \
    acp install oas-checker && \
    acp install send-to-proxy && \
    acp install apicheck-curl && \
    acp install sensitive-data && \
    apc install replay && \
    acp install openapiv3-lint && \
    acp install openapiv2-lint && \
    acp install oas-checker
RUN pip3 install regexploit
RUN apk add --no-cache clang gcc libevent libevent-dev openssl cmake && \
    git clone --depth=1 https://github.com/racepwn/racepwn && \
    ./build.sh
RUN git clone https://github.com/TheHackerDev/race-the-web /usr/local/race-the-web && \
    cd /usr/local/race-the-web && make && \
    go get -u -v github.com/golang/dep/cmd/dep && \
    dep ensure
RUN apk add ruby && gem install API_Fuzzer
RUN git clone --depth=1 https://github.com/szski/shapeshifter.git /usr/local/shapeshifter && \
    cd /usr/local/shapeshifter && pip install .
RUN apk add --no-cache testssl.sh
RUN git clone --depth=1 https://github.com/assetnote/batchql.git /usr/local/batchql
RUN git clone --depth=1 https://github.com/swisskyrepo/GraphQLmap /usr/local/GraphQLmap
RUN git clone --depth=1 https://github.com/digininja/CeWL /usr/local/CeWL && \
    cd /usr/local/CeWL && gem install bundler && bundle install
RUN git clone --depth=1 https://github.com/r3nt0n/bopscrk /usr/local/bopscrk && \
    cd /usr/local/bopscrk && python3 -m pip install -r requirements.txt
RUN git clone --depth=1 https://github.com/imperva/automatic-api-attack-tool /usr/local/automatic-api-attack-tool && \
    apk add --no-cache openjdk8-jre gradle && \
    cd /usr/local/automatic-api-attack-tool && ./gradlew build && \
    cp -av src/main/resources/runnable.sh . && \
    cat runnable.sh imperva-api-attack-tool.jar > api-attack.sh && chmod +x api-attack.sh
RUN git clone --depth=1 https://github.com/microsoft/restler-fuzzer /usr/local/restler-fuzzer && \
    apk add --no-cache bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib && \
    apk add --no-cache libgdiplus --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ && \
    curl -o /usr/local/restler-fuzzer/dotnet-install.sh https://dot.net/v1/dotnet-install.sh && \
    cd /usr/local/restler-fuzzer && ./dotnet-install.sh -c 5.0 && \
    mkdir -p /usr/local/restler-fuzzer/restler_bin && cd /usr/local/restler-fuzzer/restler_bin && \
    python3 ./build-restler.py --dest_dir /usr/local/restler-fuzzer/restler_bin

# wordlists
RUN git clone --depth=1 https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/danielmiessler-seclists
RUN mkdir -p /usr/share/wordlists/assetnote-io && cd /usr/share/wordlists/assetnote-io && \
    wget -r --no-parent -R "index.html*" https://wordlists-cdn.assetnote.io/data/ -nH
RUN git clone --depth=1  https://github.com/assetnote/commonspeak2-wordlists.git /usr/share/wordlists/commonspeak2-wordlists
RUN curl -o /usr/share/wordlists/yassineaboukir-3203-common-api-endpoints.txt "https://gist.githubusercontent.com/yassineaboukir/8e12adefbd505ef704674ad6ad48743d/raw/3ea2b7175f2fcf8e6de835c72cb2b2048f73f847/List%2520of%2520API%2520endpoints%2520&%2520objects"


