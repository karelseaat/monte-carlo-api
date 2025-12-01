# Monte Carlo Simulation API

## Overview

This API provides Monte Carlo simulation capabilities for cost estimation. Submit a list of tasks with their costs and probabilities, and receive detailed statistical analysis including occurrence rates, cost distributions, and task-by-task breakdowns.

## Base URL

```
http://localhost:8000
```

## Endpoints

### POST /simulate

Runs a Monte Carlo simulation with the provided parameters.

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "numSimulations": 10000,
  "labels": [
    {
      "name": "Task A",
      "cost": 50,
      "chance": 0.9
    },
    {
      "name": "Task B", 
      "cost": 80,
      "chance": 0.7
    }
  ]
}
```

#### Request Parameters

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `numSimulations` | Integer | Yes | Number of simulation iterations to run | 1 - 100,000,000 |
| `labels` | Array | Yes | Array of tasks/items to simulate | 1 - 500 items |
| `labels[].name` | String | Yes | Task name/identifier | Max 255 characters, non-empty |
| `labels[].cost` | Number | Yes | Cost of the task | 0 - 1,000,000 |
| `labels[].chance` | Number | Yes | Probability task occurs (0-1) | 0.0 - 1.0 |

#### Response (200 OK)

```json
{
  "minCost": 0,
  "maxCost": 130,
  "averageCost": 85.42,
  "standardDeviation": 28.5,
  "percentile25Cost": 65,
  "percentile50Cost": 85,
  "percentile75Cost": 110,
  "percentile90Cost": 120,
  "mostLikelyCostRange": "110-130",
  "bins": [
    {
      "range": "0-13",
      "count": 45
    },
    {
      "range": "13-26",
      "count": 0
    },
    {
      "range": "26-39",
      "count": 0
    },
    {
      "range": "39-52",
      "count": 23
    },
    {
      "range": "52-65",
      "count": 0
    },
    {
      "range": "65-78",
      "count": 0
    },
    {
      "range": "78-91",
      "count": 0
    },
    {
      "range": "91-104",
      "count": 12
    },
    {
      "range": "104-117",
      "count": 0
    },
    {
      "range": "117-130",
      "count": 920
    }
  ],
  "graphData": [
    {
      "x": 6.5,
      "y": 0.045
    },
    {
      "x": 19.5,
      "y": 0.045
    },
    {
      "x": 32.5,
      "y": 0.045
    },
    {
      "x": 45.5,
      "y": 0.068
    },
    {
      "x": 58.5,
      "y": 0.068
    },
    {
      "x": 71.5,
      "y": 0.068
    },
    {
      "x": 84.5,
      "y": 0.068
    },
    {
      "x": 97.5,
      "y": 0.080
    },
    {
      "x": 110.5,
      "y": 0.080
    },
    {
      "x": 123.5,
      "y": 1.0
    }
  ],
  "taskStatistics": [
    {
      "name": "Task A",
      "occurrenceCount": 8956,
      "occurrenceRate": 0.8956,
      "averageCostWhenIncluded": 50,
      "totalCostContribution": 447800
    },
    {
      "name": "Task B",
      "occurrenceCount": 7002,
      "occurrenceRate": 0.7002,
      "averageCostWhenIncluded": 80,
      "totalCostContribution": 560160
    }
  ]
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `minCost` | Number | Minimum cost outcome from all simulations |
| `maxCost` | Number | Maximum cost outcome from all simulations |
| `averageCost` | Number | Mean cost across all simulations |
| `standardDeviation` | Number | Standard deviation - measures variability (higher = more unpredictable) |
| `percentile25Cost` | Number | 25th percentile (25% of outcomes ≤ this value) |
| `percentile50Cost` | Number | 50th percentile/median (50% of outcomes ≤ this value) |
| `percentile75Cost` | Number | 75th percentile (75% of outcomes ≤ this value) |
| `percentile90Cost` | Number | 90th percentile (90% of outcomes ≤ this value) |
| `mostLikelyCostRange` | String | Cost range bin with highest frequency |
| `bins` | Array | Histogram bins showing cost distribution |
| `bins[].range` | String | Cost range (e.g., "100-110") |
| `bins[].count` | Integer | Number of outcomes in this range |
| `graphData` | Array | Points for plotting cumulative distribution |
| `graphData[].x` | Number | Cost value |
| `graphData[].y` | Number | Cumulative probability (0-1) |
| `taskStatistics` | Array | Per-task breakdown and analysis |
| `taskStatistics[].name` | String | Task name |
| `taskStatistics[].occurrenceCount` | Integer | Times task occurred across simulations |
| `taskStatistics[].occurrenceRate` | Number | Percentage of simulations where task occurred |
| `taskStatistics[].averageCostWhenIncluded` | Number | Average cost of task when it occurs |
| `taskStatistics[].totalCostContribution` | Number | Sum of all costs for this task |

#### Error Response (422 Unprocessable Entity)

**Validation Errors:**

```json
{
  "error": "Validation failed",
  "details": {
    "numSimulations": "numSimulations must be at least 1",
    "labels": "Maximum 500 labels allowed",
    "labels[0].cost": "cost must be non-negative",
    "labels[1].chance": "chance must be between 0 and 1"
  }
}
```

#### Error Response (500 Internal Server Error)

**Execution Errors:**

```json
{
  "error": "Simulation failed",
  "message": "Nim simulator failed with exit code 1. Error: ..."
}
```

## Example Requests

### Basic Example

```bash
curl -X POST http://localhost:8000/simulate \
  -H "Content-Type: application/json" \
  -d '{
    "numSimulations": 1000,
    "labels": [
      { "name": "Backend", "cost": 100, "chance": 1.0 },
      { "name": "Frontend", "cost": 80, "chance": 0.9 }
    ]
  }'
```

### Large-Scale Simulation

```bash
curl -X POST http://localhost:8000/simulate \
  -H "Content-Type: application/json" \
  -d '{
    "numSimulations": 50000000,
    "labels": [
      { "name": "Development", "cost": 1000, "chance": 1.0 },
      { "name": "Testing", "cost": 500, "chance": 0.95 },
      { "name": "Deployment", "cost": 200, "chance": 1.0 },
      { "name": "Documentation", "cost": 150, "chance": 0.8 }
    ]
  }'
```

### Many Tasks

```bash
curl -X POST http://localhost:8000/simulate \
  -H "Content-Type: application/json" \
  -d '{
    "numSimulations": 10000,
    "labels": [
      { "name": "Task 1", "cost": 50, "chance": 0.5 },
      { "name": "Task 2", "cost": 75, "chance": 0.6 },
      { "name": "Task 3", "cost": 100, "chance": 0.7 }
    ]
  }'
```

## Interpreting Results

### Understanding Confidence Intervals

The percentiles give you a complete picture of cost distribution:

```
25th percentile: $1,650 (25% of outcomes cost ≤ this)
50th percentile: $1,800 (median - typical middle outcome)
75th percentile: $1,850 (75% of outcomes cost ≤ this)
90th percentile: $1,900 (90% of outcomes cost ≤ this)
```

**Budgeting strategies:**
- **Conservative budget**: Use 75th or 90th percentile (high confidence cost won't exceed)
- **Expected budget**: Use 50th percentile (median - realistic middle estimate)
- **Optimistic budget**: Use 25th percentile (best case)

**Standard Deviation** shows unpredictability:
- Low SD (< 20% of mean): Costs are predictable
- High SD (> 50% of mean): Costs are highly variable

### Task Statistics Analysis

The `taskStatistics` array helps you understand the contribution of each task:

- **occurrenceRate**: Shows how often a task appears in simulations. Useful for understanding variability.
- **averageCostWhenIncluded**: The cost each time the task occurs (deterministic per task).
- **totalCostContribution**: Sum of all costs for this task across all simulations. Higher values indicate more impact on total cost.

Example interpretation:
```
Task A: occurs 90% of the time, costs $100 per occurrence
  → totalCostContribution = 10,000 simulations × 0.9 × $100 = $900,000

Task B: occurs 60% of the time, costs $50 per occurrence  
  → totalCostContribution = 10,000 simulations × 0.6 × $50 = $300,000
```

### Cost Distribution

The `bins` histogram shows how costs are distributed:

```
Range        Count    Frequency
0-10         100      10%
10-20        200      20%
20-30        300      30%
30-40        250      25%
40-50        150      15%
```

Use this to understand:
- Most likely cost range (highest count)
- Probability ranges (counts / total simulations)
- Risk levels (outliers in low/high bins)

## Performance Notes

- **1,000 simulations, 2 tasks**: ~5-10ms
- **1,000,000 simulations, 2 tasks**: ~80-100ms
- **10,000,000 simulations, 100 tasks**: ~6 seconds

Larger simulations provide more statistical accuracy but take longer. Choose simulation count based on your confidence interval requirements.

## Constraints & Limits

| Constraint | Value |
|-----------|-------|
| Max simulations | 100,000,000 |
| Max tasks/labels | 500 |
| Max task name length | 255 characters |
| Max cost value | 1,000,000 |
| Min cost value | 0 |
| Valid chance range | 0.0 - 1.0 |

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | Simulation completed successfully |
| 422 | Validation error in request parameters |
| 500 | Server error during simulation |
