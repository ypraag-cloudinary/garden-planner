export interface PlantingEstimate {
  totalPlants: number
  plantsPerDrip: number
  dripInterval: number
  lineCount: number
  usableDrips: number
}

export type DripLineUsage = 'all' | 'sides' | 'middle'

const LINE_COUNTS: Record<DripLineUsage, number> = {
  all: 3,
  sides: 2,
  middle: 1,
}

export function estimatePlanting(
  segmentLengthM: number,
  dripSpacingCm: number,
  spacingCm: number,
  lines: DripLineUsage,
): PlantingEstimate {
  const dripsInSegment = Math.floor((segmentLengthM * 100) / dripSpacingCm) + 1

  let plantsPerDrip: number
  let dripInterval: number

  if (spacingCm < dripSpacingCm) {
    // Bunching: multiple plants fit between drip points
    plantsPerDrip = Math.floor(dripSpacingCm / spacingCm)
    dripInterval = 1
  } else {
    // Spacing: skip drip points
    plantsPerDrip = 1
    dripInterval = Math.ceil(spacingCm / dripSpacingCm)
  }

  const usableDrips = Math.floor((dripsInSegment - 1) / dripInterval) + 1
  const lineCount = LINE_COUNTS[lines]
  const totalPlants = usableDrips * plantsPerDrip * lineCount

  return {
    totalPlants,
    plantsPerDrip,
    dripInterval,
    lineCount,
    usableDrips,
  }
}
