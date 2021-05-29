#!/usr/bin/env bash
# exit on error
set -o errexit

if [ -z "$ERLANG_VERSION" ]; then
  export ERLANG_VERSION=24.0.1
  echo "Defaulting to use Erlang $ERLANG_VERSION"
else
  echo "Using Erlang $ERLANG_VERSION"
fi

if [ -z "$ELIXIR_VERSION" ]; then
  export ELIXIR_VERSION=1.12.1
  echo "Defaulting to use Elixir $ELIXIR_VERSION"
else
  echo "Using Elixir $ELIXIR_VERSION"
fi

export ERLANG_HOME="$XDG_CACHE_HOME/erlang/$ERLANG_VERSION"
mkdir -p "$ERLANG_HOME"
export ELIXIR_HOME="$XDG_CACHE_HOME/elixir/$ELIXIR_VERSION"
mkdir -p "$ELIXIR_HOME"

export PROJECT_DIR="$(pwd)"

if [ -d "$ERLANG_HOME/bin" ]; then
  echo "Erlang already installed"
else
  echo "Installing Erlang"
  wget "https://github.com/erlang/otp/releases/download/OTP-$ERLANG_VERSION/otp_src_$ERLANG_VERSION.tar.gz"
  tar -zxf "otp_src_$ERLANG_VERSION.tar.gz"

  cd "otp_src_$ERLANG_VERSION"

  ./configure --prefix="$ERLANG_HOME" --without-javac --without-wx
  make install

  cd ..
fi

export PATH=$PATH:"$ERLANG_HOME/bin"

if [ -d "$ELIXIR_HOME/bin" ]; then
  echo "Elixir $ELIXIR_VERSION already installed"
else
  wget https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VERSION/Precompiled.zip
  unzip Precompiled.zip -d "$ELIXIR_HOME"
fi

export PATH=$PATH:"$ELIXIR_HOME/bin"

cd "$PROJECT_DIR"

export MIX_ENV=prod

# Install hex and rebar"
mix local.hex --force
mix local.rebar --force

# Get deps
mix deps.get --only prod

# Build
mix moonshine.build

# tailwind assets
NODE_ENV=production npm run build
