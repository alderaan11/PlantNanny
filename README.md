# PlantNanny

A Flutter application for monitoring and caring for your plants using ESP32-based sensors.

## Project Structure

```
PlantNanny/
├── api/                    # OpenAPI specification
│   └── plant_nanny_api.yaml
├── ClientApi/              # Generated Dart API client
├── Devtools/               # Development scripts
├── lib/                    # Flutter application source
├── server/                 # Python REST API server
└── ...
```

## Getting Started

### Prerequisites

- Flutter SDK
- Python 3.10+
- Node.js (for OpenAPI generator)

### Setup

1. **Initialize Python virtual environment:**
   ```bash
   ./Devtools/init_python_venv.sh
   ```

2. **Start the REST API server:**
   ```bash
   ./Devtools/start_rest_server.sh
   
   # Or with fake development data:
   ./Devtools/start_rest_server.sh --seed
   ```

3. **Run the Flutter app:**
   ```bash
   flutter run
   ```

## Devtools

Development scripts are located in the `Devtools/` folder:

| Script | Description |
|--------|-------------|
| `init_python_venv.sh` | Creates a Python virtual environment and installs dependencies from `requirements.txt` |
| `start_rest_server.sh` | Starts the Python REST API server on port 8080 |
| `generate_client_api.sh` | Generates the Dart API client from the OpenAPI specification |

### Server Options

```bash
# Start with empty data stores
./Devtools/start_rest_server.sh

# Start with fake development data (3 devices, 24h of readings)
./Devtools/start_rest_server.sh --seed

# Custom host and port
./Devtools/start_rest_server.sh --host 127.0.0.1 --port 9000

# Show all options
./Devtools/start_rest_server.sh --help
```

### Development Authentication

For development, the server accepts bearer tokens in the format `dev-token-{uid}`:
```bash
curl -H "Authorization: Bearer dev-token-user1" http://localhost:8080/v1/devices
```

## API Documentation

The REST API is defined in `api/plant_nanny_api.yaml` (OpenAPI 3.0.3).

### Regenerating the Client API

After modifying the OpenAPI spec, regenerate the Dart client:
```bash
./Devtools/generate_client_api.sh
```

## Flutter Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Online documentation](https://docs.flutter.dev/)
