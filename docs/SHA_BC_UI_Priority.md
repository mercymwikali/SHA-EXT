# SHA Business Central UI Page Priority

## Phase 1 - Foundation pages

These pages use the existing `SHA Setup` and `SHA Integration Log` tables.

| Priority | Object | Type | Status |
|---:|---|---|---|
| 1 | SHA Setup Card | Card | Generated |
| 2 | SHA Setup List | List | Existing, enhanced with CardPageID |
| 3 | SHA Integration Log Card | Card | Generated |
| 4 | SHA Integration Log List | List | Existing, enhanced with CardPageID and viewer actions |
| 5 | SHA Body Viewer | StandardDialog | Generated |

## Phase 2 - Operational workflow pages

These should be implemented after deciding which SHA responses must be persisted in Business Central.

| Priority | Page | Suggested Type | Tables Needed |
|---:|---|---|---|
| 6 | SHA Patient Search | Card workbench | Generated using SHA Setup as context |
| 7 | SHA Eligibility Workbench | Card workbench | Generated using SHA Setup as context |
| 8 | SHA Authorization Workbench | Card workbench | Generated using SHA Setup as context |
| 9 | SHA Visit Workbench | Card workbench | Generated using SHA Setup as context |
| 10 | SHA Claim Workbench | Card workbench | Generated using SHA Setup as context |
| 11 | SHA Preauth Workbench | Card workbench | Generated using SHA Setup as context |
| 12 | SHA Prescription Workbench | Card workbench | Generated using SHA Setup as context |
| 13 | SHA Emergency Workbench | Card workbench | Generated using SHA Setup as context |
| 14 | SHA OTP Workbench | Card workbench | Generated using SHA Setup as context |

## Phase 3 - Lookup and admin helpers

| Priority | Page | Suggested Type | Tables Needed |
|---:|---|---|---|
| 15 | SHA Facility Search | Card workbench | Generated using SHA Setup as context |
| 16 | SHA Professional Search | Card workbench | Generated using SHA Setup as context |
| 17 | SHA Terminology Search | Card workbench | Generated using SHA Setup as context |
| 18 | SHA Cue Part | CardPart | Future |
| 19 | SHA Role Center Extension | PageExtension | Future |
