FROM "elixir:1.10.1-slim"

ARG MIX_ENV=dev
ENV MIX_ENV=$MIX_ENV

WORKDIR /code

RUN apt-get update && apt-get -y install curl && curl https://get.volta.sh | bash

ENV PATH=$PATH:/root/.volta/bin

RUN volta install node@8.9

ADD ["mix.lock", "mix.exs", "/code/"]

RUN echo "y" | mix local.hex --if-missing && echo "y" | mix local.rebar --if-missing

RUN mix local.hex --force && mix local.rebar --force && \
  mix deps.get
  # && MIX_ENV=test mix deps.compile && \
  # MIX_ENV=$MIX_ENV mix deps.compile

ADD ["config", "lib", "/code/"]

# RUN MIX_ENV=$MIX_ENV mix compile

ADD ["test", "/code/"]

# RUN MIX_ENV=test mix compile && MIX_ENV=$MIX_ENV mix compile

# ADD . /code/

# RUN MIX_ENV=test mix compile && MIX_ENV=$MIX_ENV mix compile


# RUN npm install

CMD ["/bin/bash"]
