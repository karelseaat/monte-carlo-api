# Monte Carlo Simulation API with Nim and Lumen

This project is a Lumen-based API that acts as a wrapper around a Monte Carlo simulation implemented in Nim. It allows users to submit a JSON input structure defining simulation parameters (labels with cost and chance) and receive a JSON output representing the simulation results, suitable for graph visualization.

## Features

*   **Monte Carlo Simulation Core:** The simulation logic is implemented in Nim, offering excellent performance (10M simulations with 100 tasks in ~6 seconds).
*   **Task-Level Analysis:** Per-task statistics showing occurrence rates, cost contributions, and variability.
*   **Comprehensive Validation:** Input validation with detailed error messages (max 500 tasks, 100M simulations, custom cost/probability ranges).
*   **Professional Error Handling:** Clear error responses (422 validation, 500 execution) with field-level details.
*   **Clean Output Formatting:** Properly formatted numbers without scientific notation, ready-to-use data.
*   **Graph Data Output:** Cumulative distribution points suitable for charting libraries.
*   **Complete Documentation:** API.md with endpoint specs, examples, constraints, and result interpretation.
*   **JSON Input/Output:** RESTful API with well-structured request/response formats.

## Requirements

*   PHP (>= 8.1)
*   Composer
*   Nim (to compile the simulation module)
*   SQLite (optional, for Lumen's default setup; not central to core simulation logic)

## Setup Instructions

1.  **Clone the Repository (or create Lumen project):**
    If you haven't already, create a new Lumen project:
    ```bash
    composer create-project --prefer-dist laravel/lumen monte-carlo-api
    cd monte-carlo-api
    ```

2.  **Configure Environment:**
    Create a `.env` file from the example:
    ```bash
    cp .env.example .env
    ```
    Edit your `.env` file to configure SQLite (if needed) and ensure necessary Lumen components are enabled in `bootstrap/app.php`:
    ```
    DB_CONNECTION=sqlite
    DB_DATABASE=/path/to/your/project/database/database.sqlite
    DB_FOREIGN_KEYS=true
    ```
    Also, ensure Eloquent and other necessary service providers are enabled in `bootstrap/app.php`:
    ```php
    // In bootstrap/app.php
    $app->withFacades();
    $app->withEloquent();
    // No specific AppServiceProvider or AuthServiceProvider needed initially unless expanded
    ```

3.  **Create Database File (Optional):**
    ```bash
    touch database/database.sqlite
    ```

4.  **Install PHP Dependencies:**
    ```bash
    composer install
    ```

5.  **Nim Setup:**
    *   **Install Nim:** If Nim is not installed on your system, follow the instructions on the [Nim-Lang website](https://nim-lang.org/install.html).
    *   **Create Nim Module:** The Nim simulation code will reside in a file like `nim_src/monte_carlo_sim.nim`.
    *   **Compile Nim Executable:**
        ```bash
        # From the project root (monte-carlo-api)
        nim c -d:release --verbosity:0 --hints:off -o:bin/monte_carlo_sim nim_src/monte_carlo_sim.nim
        ```
        This compiles the Nim code into an executable at `bin/monte_carlo_sim`.

## Running the Application

To start the Lumen development server, run the following command from the project root:

```bash
php -S localhost:8000 -t public
```

The API will be available at `http://localhost:8000`.

## API Endpoints

### `POST /simulate`

*   **Description:** Runs a Monte Carlo simulation based on the provided JSON input and returns graph data.
*   **Request Body (JSON):**
    ```json
    {
        "num_simulations": 10000,
        "labels": [
            { "name": "Task A", "cost": 10, "chance": 0.8 },
            { "name": "Task B", "cost": 15, "chance": 0.6 },
            { "name": "Task C", "cost": 5, "chance": 0.9 }
        ]
    }
    ```
    *   `num_simulations`: (integer, optional, default 10000) The number of Monte Carlo iterations.
    *   `labels`: (array of objects) Each object must have:
        *   `name`: (string) Identifier for the item.
        *   `cost`: (numeric) Cost associated with the item.
        *   `chance`: (numeric, 0.0-1.0) Probability of the item occurring.
*   **Response (JSON - Example Structure):**
    ```json
    {
        "simulation_results": {
            "histogram": {
                "min_cost": 0,
                "max_cost": 30,
                "bins": {
                    "0-5": 500,
                    "6-10": 1500,
                    "11-15": 3000,
                    "16-20": 2500,
                    "21-25": 1000,
                    "26-30": 500
                }
            },
            "average_cost": 14.25,
            "most_likely_cost_range": "11-15",
            "percentile_90_cost": 23.5
        },
        "graph_data": [
            // Array of data points suitable for charting libraries
            { "x": 0, "y": 0.05 },
            { "x": 5, "y": 0.15 },
            { "x": 10, "y": 0.30 },
            { "x": 15, "y": 0.25 },
            { "x": 20, "y": 0.10 },
            { "x": 25, "y": 0.05 }
        ]
    }
    ```
## Documentation

For complete API documentation including request/response examples, constraints, and usage patterns, see [API.md](./API.md).

For detailed information on recent improvements (validation, error handling, formatting, cost breakdown), see [IMPROVEMENTS.md](./IMPROVEMENTS.md).

## API Endpoints

### Simulation
- `POST /simulate` - Run Monte Carlo simulation

### Documentation
- `GET /help` - List all available endpoints and links
- `GET /docs` - Full API documentation (markdown)
- `GET /help/interpret` - Guide on interpreting results (percentiles, standard deviation, task stats)
- `GET /help/examples` - Example requests and responses
- `GET /help/constraints` - API constraints, limits, and performance notes

All documentation endpoints return JSON that can be easily consumed by clients.

