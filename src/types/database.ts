export interface GardenRow {
  id: number
  length_m: number
  drip_spacing_cm: number
  pipes_count: number
  section: 'left' | 'right'
  notes: string | null
  has_trellis: boolean
}

export interface Segment {
  id: string
  row_id: number
  position: number
  vegetable: string
  planted_at: string | null
  length_m: number | null
  notes: string | null
  is_planned: boolean
  created_at: string
  updated_at: string
}

export interface SegmentHistory {
  id: string
  row_id: number
  position: number
  vegetable: string
  planted_at: string | null
  archived_at: string
  length_m: number | null
  notes: string | null
  is_planned: boolean
}

export interface Vegetable {
  id: string
  name: string
  icon: string | null
  days_to_harvest: number | null
  spacing_cm: number | null
  lines: 'all' | 'sides' | 'middle' | null
  is_seeded: boolean
  season: string[] | null
  needs_trellis: boolean
}

export interface PipeMapping {
  pipe_number: number
  description: string
  updated_at: string
}

export interface RowWithSegments extends GardenRow {
  segments: Segment[]
}
