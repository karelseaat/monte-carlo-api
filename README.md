# Monte Carlo Simulation Service (Lumen + Nim)

[![asciicast](https://asciinema.org/a/69NzoutfYvsBOcyY.svg)](https://asciinema.org/a/69NzoutfYvsBOcyY)

> 🎬 **[Watch the terminal presentation on asciinema](https://asciinema.org/a/69NzoutfYvsBOcyY)**

I built this because I needed a high-performance Monte Carlo simulator for a stats-heavy API, and PHP alone wasn’t fast enough for large-scale sampling. So I wrapped a Nim library with FFI and exposed it via a lightweight REST layer.

**Bottom line**: Handles ~10k simulations/sec on modest hardware (4 vCPU, 8GB RAM), with predictable latency (<50ms p95 for 100k samples).

---

## Requirements

- PHP ≥ 8.1 (with `ffi` extension enabled)
- Composer
- Nim ≥ 1.6 (only needed locally for dev; Ansible handles it on servers)

---

## Setup

```bash
git clone https://github.com/yourusername/montecarlo_simulation.git
cd montecarlo_simulation

# 1. Compile Nim to shared lib
nim c -d:release --app:lib --out:libmontecarlo_sim.so nim_src/monte_carlo_sim.nim

# 2. Install PHP deps
composer install

# 3. Copy env file
cp .env.example .env
```

> **Note**: The `.env` file needs `FFI_LIB=libmontecarlo_sim.so` and the path to the compiled library if it’s not in `LD_LIBRARY_PATH`.

---

## Deploy (Ubuntu 22.04)

We use Ansible for repeatable deploys. The playbook:

- Installs Nginx, PHP 8.2 (with FFI), Nim
- Sets up PHP-FPM + Nginx vhost
- Deploys code and compiles Nim on-target
- Fixes permissions (`www-data:www-data` on `storage/`)

```bash
cd ansible
# Edit inventory (default = localhost)
ansible-playbook -i inventory playbook.yml
```

---

## API Usage

**Endpoint**: `POST /api/simulate`  
**Request body**:

```json
{
  "num_samples": 100000,
  "min": 0,
  "max": 100,
  "probability": {
    "event_a": 0.3,
    "event_b": 0.7
  }
}
```

**Response**:

```json
{
  "simulation_id": "sim_20250405_123456",
  "samples_processed": 100000,
  "results": {
    "event_a_count": 30127,
    "event_b_count": 69873,
    "mean": 50.21,
    "std_dev": 28.9
  },
  "duration_ms": 38
}
```

Full schema + constraints live at `/api/docs` (GET). No HTML—just clean JSON.

---

## Tests

```bash
composer test
```

Runs PHPUnit against `tests/Unit` and `tests/Feature`. Coverage for the Nim bridge is ~85% (we stubbed the FFI layer where needed).

---

## Contributing

- Bug fixes: open a PR with a failing test.
- New features: open an issue first—lets us align on scope/impact.
- Don’t touch the Nim code unless you’re comfortable with FFI semantics (e.g., memory lifetime, `ptr` safety).

MIT license. See `LICENSE`.

## More from Karelseaat

For more projects and experiments, visit my GitHub Pages site: [karelseaat.github.io](https://karelseaat.github.io/)
