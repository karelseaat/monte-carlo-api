 # MonteCarloSimulation Lumen Project

This repository contains a Lumen PHP framework project implementing a Monte Carlo Simulation service. The project is designed to provide developers with an efficient way to perform complex simulations involving random sampling, probability, and statistics.

## Prerequisites

- PHP 8.1 or higher
- Composer (for project dependency management)

## Installation

To get started, clone the repository and navigate to the project directory:

```bash
git clone https://github.com/yourusername/montecarlo_simulation.git
cd montecarlo_simulation
```

Next, install the dependencies using Composer:

```bash
composer install
```

## Usage

The service can be accessed through a simple REST API. To run a simulation, send a POST request to `/api/simulate`, providing the JSON input data as the request body. The response will contain the results of the simulation.

Example input JSON:

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

For detailed information on the input format and the service's capabilities, please refer to the [documentation](#Documentation).

## API Documentation

To access the project documentation, send a GET request to `/api/docs`. The documentation includes examples, constraints, and instructions for interpreting the results.

## Testing

Unit tests are included in the `tests` directory. To run the tests, use the following command:

```bash
composer test
```

## Contributing

Pull requests are welcome! If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

Enjoy using MonteCarloSimulation! If you have any questions or need further assistance, please don't hesitate to reach out. Happy coding!