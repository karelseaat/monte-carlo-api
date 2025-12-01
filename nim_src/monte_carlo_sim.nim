{.emit: "#define __STDC_WANT_LIB_EXT1__ 1".}
import json, math, random, strutils, algorithm, system # 'system' is needed for alloc/dealloc/copyMem

type
  Label* = object
    name*: string
    cost*: float
    chance*: float

  SimulationInput* = object
    numSimulations*: int
    labels*: seq[Label]

  HistogramBin = object
    range*: string
    count*: int

  GraphPoint* = object
    x*: float
    y*: float

  TaskStatistic = object
    name*: string
    occurrenceCount*: int
    occurrenceRate*: float
    averageCostWhenIncluded*: float
    totalCostContribution*: float

  SimulationOutput* = object
    minCost*: float
    maxCost*: float
    bins*: seq[HistogramBin]
    averageCost*: float
    standardDeviation*: float
    percentile25Cost*: float
    percentile50Cost*: float
    percentile75Cost*: float
    percentile90Cost*: float
    mostLikelyCostRange*: string
    graphData*: seq[GraphPoint]
    taskStatistics*: seq[TaskStatistic]


proc `$`*(bin: HistogramBin): string =
  return "{\"range\": \"" & bin.range & "\", \"count\": " & $bin.count & "}"

proc `$`*(gp: GraphPoint): string =
  return "{\"x\": " & $gp.x & ", \"y\": " & $gp.y & "}"

proc `$`*(ts: TaskStatistic): string =
  return "{\"name\": \"" & ts.name & "\", \"occurrenceCount\": " & $ts.occurrenceCount &
         ", \"occurrenceRate\": " & $ts.occurrenceRate &
         ", \"averageCostWhenIncluded\": " & $ts.averageCostWhenIncluded &
         ", \"totalCostContribution\": " & $ts.totalCostContribution & "}"

proc formatRangeFloat(x: float): string =
  let formatted = formatFloat(x, precision = 2)
  if '.' in formatted:
    return formatted.strip(chars = {'0'}, trailing = true).strip(chars = {'.'}, trailing = true)
  return formatted

proc `$`*(output: SimulationOutput): string =
  var binsJson: seq[string]
  for bin in output.bins:
    binsJson.add($bin)
  var graphDataJson: seq[string]
  for point in output.graphData:
    graphDataJson.add($point)
  var taskStatsJson: seq[string]
  for ts in output.taskStatistics:
    taskStatsJson.add($ts)
  return "{\"minCost\": " & $output.minCost &
         ", \"maxCost\": " & $output.maxCost &
         ", \"averageCost\": " & $output.averageCost &
         ", \"standardDeviation\": " & $output.standardDeviation &
         ", \"percentile25Cost\": " & $output.percentile25Cost &
         ", \"percentile50Cost\": " & $output.percentile50Cost &
         ", \"percentile75Cost\": " & $output.percentile75Cost &
         ", \"percentile90Cost\": " & $output.percentile90Cost &
         ", \"mostLikelyCostRange\": \"" & output.mostLikelyCostRange & "\"" &
         ", \"bins\": [" & join(binsJson, ", ") & "]" &
         ", \"graphData\": [" & join(graphDataJson, ", ") & "]" &
         ", \"taskStatistics\": [" & join(taskStatsJson, ", ") & "]}"


proc runMonteCarloSimulation*(inputJsonCstr: cstring): cstring {.dynlib, exportc: "runMonteCarloSimulation".} =
  # Parse JSON input from cstring
  let inputJson = $inputJsonCstr
  let simInput = parseJson(inputJson).to(SimulationInput)

  randomize()

  var
    results: seq[float]
    totalCost: float
    minOverallCost = high(float)
    maxOverallCost = low(float)
    taskOccurrences = newSeq[int](simInput.labels.len)
    taskCostSums = newSeq[float](simInput.labels.len)

  for s in 0 ..< simInput.numSimulations:
    totalCost = 0.0
    for i, label in simInput.labels:
      if rand(1.0) <= label.chance:
        totalCost += label.cost
        taskOccurrences[i] += 1
        taskCostSums[i] += label.cost
    results.add(totalCost)

    if totalCost < minOverallCost: minOverallCost = totalCost
    if totalCost > maxOverallCost: maxOverallCost = totalCost

  results.sort(cmp[float])

  # Calculate statistics
  var
    sumCost: float
    numResults = results.len.float
  for cost in results:
    sumCost += cost
  let averageCost = sumCost / numResults

  # Calculate percentiles
  let percentile25Cost = if numResults > 0: results[int(numResults * 0.25)] else: 0.0
  let percentile50Cost = if numResults > 0: results[int(numResults * 0.50)] else: 0.0
  let percentile75Cost = if numResults > 0: results[int(numResults * 0.75)] else: 0.0
  let percentile90Cost = if numResults > 0: results[int(numResults * 0.90)] else: 0.0

  # Calculate standard deviation
  var sumSquaredDiff: float = 0.0
  for cost in results:
    let diff = cost - averageCost
    sumSquaredDiff += diff * diff
  let standardDeviation = sqrt(sumSquaredDiff / numResults)

  # Create histogram
  const numBins = 10
  let binSize = if maxOverallCost > minOverallCost: (maxOverallCost - minOverallCost) / numBins.float else: 1.0
  var
    histogramData: seq[int]
    bins: seq[HistogramBin]
    mostLikelyCount = -1
    mostLikelyRange = ""

  histogramData.setLen(numBins)

  for cost in results:
    var binIndex = int(floor((cost - minOverallCost) / binSize))
    if binIndex >= numBins: binIndex = numBins - 1 # Edge case for max value
    if binIndex < 0: binIndex = 0 # Edge case for min value
    histogramData[binIndex] += 1

  for i in 0 ..< numBins:
    let
      binMin = minOverallCost + i.float * binSize
      binMax = minOverallCost + (i.float + 1.0) * binSize
      minStr = formatRangeFloat(binMin)
      maxStr = formatRangeFloat(binMax)
      rangeStr = minStr & "-" & maxStr
      count = histogramData[i]

    bins.add(HistogramBin(range: rangeStr, count: count))

    if count > mostLikelyCount:
      mostLikelyCount = count
      mostLikelyRange = rangeStr

  # Prepare graph data (simplified: cumulative distribution for now)
  var graphData: seq[GraphPoint]
  var cumulativeCount = 0
  for i, count in histogramData:
    cumulativeCount += count
    let
      xVal = minOverallCost + (i.float + 0.5) * binSize
      yVal = cumulativeCount.float / numResults
    graphData.add(GraphPoint(x: xVal, y: yVal))

  # Calculate per-task statistics
  var taskStatistics: seq[TaskStatistic]
  for i, label in simInput.labels:
    let occurrenceRate = taskOccurrences[i].float / simInput.numSimulations.float
    let avgCostWhenIncluded = if taskOccurrences[i] > 0: taskCostSums[i] / taskOccurrences[i].float else: 0.0
    let totalContribution = taskCostSums[i]
    taskStatistics.add(TaskStatistic(
      name: label.name,
      occurrenceCount: taskOccurrences[i],
      occurrenceRate: occurrenceRate,
      averageCostWhenIncluded: avgCostWhenIncluded,
      totalCostContribution: totalContribution
    ))

  let output = SimulationOutput(
    minCost: minOverallCost,
    maxCost: maxOverallCost,
    bins: bins,
    averageCost: averageCost,
    standardDeviation: standardDeviation,
    percentile25Cost: percentile25Cost,
    percentile50Cost: percentile50Cost,
    percentile75Cost: percentile75Cost,
    percentile90Cost: percentile90Cost,
    mostLikelyCostRange: mostLikelyRange,
    graphData: graphData,
    taskStatistics: taskStatistics
  )

  # Manually allocate a C-compatible string that won't be garbage collected
  let outputStr = $output
  result = cast[cstring](alloc0(outputStr.len + 1))
  for i in 0 ..< outputStr.len:
    result[i] = outputStr[i]

proc freeString*(s: cstring) {.dynlib, exportc: "freeString".} =
  dealloc(s)

when isMainModule:
  let inputJson = readAll(stdin)
  let outputJson = runMonteCarloSimulation(inputJson.cstring)
  echo outputJson