# Beammp.container

![beammp](https://c10.patreonusercontent.com/4/patreon-media/p/campaign/661801/1367c3e61e524d2abfa6a53c23b3f8ae/eyJ3IjoxOTIwLCJ3ZSI6MX0%3D/8.png?token-hash=rrhg9uWO1Q_7gNrGz9-x3o3mlwLt31JuYAG6vdg6Hrc%3D\&token-time=1754265600)
Here’s a straightforward Docker setup to run the BeamMP server for BeamNG.drive
on **ARM64** platforms like Raspberry Pi or ARM-based servers.

This image automates server download, config generation via environment variables, and mod folder mounting.
It is ideal for self-hosted BeamMP servers with minimal setup.

---

## Project Contents

* `Dockerfile` – Based on Debian 12, installs required dependencies
* `start.sh` – Smart launch script that:

  * downloads the latest BeamMP server version;
  * generates the config file from a template and environment variables.
* `docker-compose.yml` – For easy container deployment
* `.env` – Server environment configuration file
* `config/ServerConfig.toml.template` – Configuration template

---

## ⚙️ Requirements

* Docker
* `docker-compose`
* A valid BeamMP Keymaster key: [https://keymaster.beammp.com/](https://keymaster.beammp.com/)

---

## 🚀 Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/super-magistro/beammp.container.git
cd beammp.container
```

### 2. Configure the environment

Edit the `.env` file to customize your server, including the port you want to expose:

```dotenv
SERVER_NAME="MyServer"
AUTH_KEY="your-keymaster-key"
MAX_PLAYERS=12
MAP="/levels/east_coast_usa/info.json"
PORT=16383               # External port to expose your server (default is 30814)
```

### 3. Launch the server

```bash
docker-compose up -d --build
```

The server will be available on the port specified by `PORT` (both TCP and UDP).

---

## 🔁 Container Behavior

On each start:

* The script fetches the latest BeamMP release.
* If an update is available, it downloads and installs it.
* The configuration file is generated from `ServerConfig.toml.template` using environment variables, unless already present.

---

## 📁 Volume Mounts

Two volumes are mounted to manage your server and client mods:

| Host Path       | Container Path                  |
| --------------- | ------------------------------- |
| `./mods/Server` | `/beammp/data/Resources/Server` |
| `./mods/Client` | `/beammp/data/Resources/Client` |

Simply drop and manage your mods into these folders.

---

## 🔐 Environment Variables

| Variable                       | Description                                                |
| ------------------------------ | ---------------------------------------------------------- |
| `AUTH_KEY`                     | Key from [Keymaster](https://keymaster.beammp.com/)        |
| `SERVER_NAME`                  | Internal server name                                       |
| `NAME`                         | Public name shown in server list                           |
| `DESCRIPTION`                  | Public description of your server                          |
| `TAGS`                         | Server tags (comma separated)                              |
| `PRIVATE`                      | `true` = private server                                    |
| `MAX_PLAYERS`                  | Maximum number of players                                  |
| `MAX_CARS`                     | Max cars per player                                        |
| `MAP`                          | Map to load (see available maps below)                     |
| `LOG_CHAT`                     | `true` = log chat messages                                 |
| `DEBUG`                        | `true` = enable debug output                               |
| `NOT_SHOW_IF_UPDATE_AVAILABLE` | Suppress update warnings                                   |
| **`PORT`**                     | **External port to expose your server (default: `30814`)** |

---

## 🗺️ Available Maps

Valid values for the `MAP` variable:

```
/levels/west_coast_usa/info.json
/levels/italy/info.json
/levels/east_coast_usa/info.json
/levels/gridmap_v2/info.json
/levels/cliff/info.json
... (see .env for the full list)
```

---

## 🔌 Port Mapping and Router Forwarding

The BeamMP server listens internally on port `30814`. You can expose it on any external port by setting the `PORT` environment variable in `.env`.

For example, if you set:

```dotenv
PORT=16383
```

Then in `docker-compose.yml`, the port mapping should use this variable, like so:

```yaml
services:
  beammp:
    ports:
      - "${PORT:-30814}:${30814}/tcp"
      - "${PORT:-30814}:${30814}/udp"
```

Make sure to forward the **same external port** (`16383` in this example) on your router to your host machine, so clients can reach your server.

---

## ♻️ Auto Restart

This container is configured to restart automatically (`restart: unless-stopped`) in case of crash or system reboot.

---

## 📄 License

This project is freely distributable.
The BeamMP server itself is developed by the [BeamMP Team](https://beammp.com) and subject to their license and terms.

---

## 🙏 Acknowledgements

Special thanks to the BeamMP developers and community.
[Official documentation](https://docs.beammp.com)
