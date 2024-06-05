# Baresip-Audio-Support

- [Baresip-Audio-Support](#baresip-audio-support)
  - [Context](#context)
  - [Enable Audio](#enable-audio)
    - [Execution](#execution)
    - [Set a different device - Enabling Device connected on Jack](#set-a-different-device---enabling-device-connected-on-jack)
  - [How use new Modules](#how-use-new-modules)
  - [.baresip folder](#baresip-folder)
  - [Build Image](#build-image)
  - [Run baresip](#run-baresip)
  - [Explore bash](#explore-bash)
  - [Explore baresip commands and usage](#explore-baresip-commands-and-usage)

## Context

This project aims to enable and facilitate the use of `baresip`.
Allowing it to be used via `Docker Compose`, it is already fully configured for use without any changes and provides audio support for the OSX environment.

Essentially, it provides the following:

- Pre-defined and easily customizable new modules;
- Audio support using the `pulse` module for OSX host environments;
- Audio support for multiple devices, with a configurable script for this purpose;
- `config` file already configured, no need to make any changes;
- `bind mounts` created to facilitate `on-demand` changes, such as adding or removing audio;
- Easy testing of new versions of `baresip` and new modules, using environment variables;

## Enable Audio

The pulse module is used as an audio player and audio source.
But on OSX, we don't have direct access to the `devices`, so we need to configure `pulse` in the `host` environment. The container then has the `PULSE_SERVER` pointing to the `host`.

To make the process easier, a script has been created for this purpose: `configure-pulseaudio-osx.sh`.
This script is basically responsible for:

- installing the `pulseaudio` lib, if it doesn't exist (via brew);
- Validating which device you want to use as the `sink` (by default, tries to use: `MacBook Pro Speakers`);
- Changes the `default-sink` to the one you want;
- Changes the config: `default.pa`, to accept TCP connections, without requiring authentication;
- Restart the `pulseaudio` service;

### Execution

```sh
chmod 0777 configure-pulseaudio-osx.sh
./configure-pulseaudio-osx.sh
```

### Set a different device - Enabling Device connected on Jack

```sh
pactl list sinks ### list the sinks available on host - select the device wanted from description Field
./configure-pulseaudio-osx.sh "External Headphones"
```

## How use new Modules

To use new modules, the following is required to be changed:

- Update `MODULES_LIST` environment variable in `.env` file, and add the new module;
- Check `.baresip/config` file, and enable the module;
- Finally, check if the new module, requires to install new libraries, and if yes, update `Dockerfile`;

## .baresip folder

The local `.baresip` folder contains the basic `baresip` settings.

By default, the only file to change is : `accounts`. There are no pre-created accounts, so you need to enter new ones.

## Build Image

```sh
docker compose build
```

## Run baresip

```sh
docker compose run baresip-with-audio
```

## Explore bash

```sh
docker compose run baresip-with-audio /bin/bash
```

## Explore baresip commands and usage

[baresip-wiki](https://github.com/baresip/baresip/wiki)
