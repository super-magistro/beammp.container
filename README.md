# 🛻 beammp.container

Here’s a straightforward Docker setup to run the BeamMP server for BeamNG.drive  
on **ARM64** platforms like Raspberry Pi or ARM-based servers.

This image automates server download, config generation via environment variables, and mod folder mounting.  
It is ideal for self-hosted BeamMP servers with minimal setup.

---

## 🧱 Project Contents

- `Dockerfile` – Based on Debian 12, installs required dependencies
- `start.sh` – Smart launch script that:
  - downloads the latest BeamMP server version;
  - generates the config file from a template and environment variables.
- `docker-compose.yml` – For easy container deployment
- `.env` – Server environment configuration file
- `config/ServerConfig.toml.template` – Configuration template

---

## ⚙️ Requirements

- Docker
- `docker-compose`
- A valid BeamMP Keymaster key: [https://keymaster.beammp.com/](https://keymaster.beammp.com/)

---

## 🚀 Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/super-magistro/beammp.container.git
cd beammp.container
```

### 2. Configure the environment

Edit the `.env` file to customize your server:

```dotenv
SERVER_NAME="MyServer"
AUTH_KEY="your-keymaster-key"
MAX_PLAYERS=12
MAP="/levels/east_coast_usa/info.json"
# ... etc
```

### 3. Launch the server

```bash
docker-compose up -d --build
```

The server will be available on port `30814` (both TCP and UDP).

---

## 🔁 Container Behavior

On each start:

* The script fetches the latest BeamMP release.
* If an update is available, it will download and install it.
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

Here are some of the main `.env` variables:

| Variable                       | Description                                         |
| ------------------------------ | --------------------------------------------------- |
| `AUTH_KEY`                     | Key from [Keymaster](https://keymaster.beammp.com/) |
| `SERVER_NAME`                  | Internal server name                                |
| `NAME`                         | Public name shown in server list                    |
| `DESCRIPTION`                  | Public description of your server                   |
| `TAGS`                         | Server tags (comma separated)                       |
| `PRIVATE`                      | `true` = private server                             |
| `MAX_PLAYERS`                  | Maximum number of players                           |
| `MAX_CARS`                     | Max cars per player                                 |
| `MAP`                          | Map to load (see below)                             |
| `LOG_CHAT`                     | `true` = log chat messages                          |
| `DEBUG`                        | `true` = enable debug output                        |
| `NOT_SHOW_IF_UPDATE_AVAILABLE` | Suppress update warnings                            |

---

## 🗺️ Available Maps

Here are valid values for the `MAP` variable:

```
/levels/west_coast_usa/info.json
/levels/italy/info.json
/levels/east_coast_usa/info.json
/levels/gridmap_v2/info.json
/levels/cliff/info.json
... (see .env for the full list)
```

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
Official documentation: [https://docs.beammp.com/server/](https://docs.beammp.com/server/)
