# Flight Ticket Price

Rails 8.1.3 application running on Ruby 4.0.1.

## Constitution Highlights

- Keep implementations simple and prefer reuse over new abstractions.
- Preserve `Route -> Service -> Repository` boundaries for business logic.
- Add automated tests for every feature and logic change, ideally starting from a
  failing test.
- Do not log PII or hardcode secrets.
- Generated planning/specification Markdown files under `specs/` and Spec Kit
  analysis outputs must use `zh-TW`, except where English is required for code,
  commands, protocol fields, or proper nouns.

## Local Setup

- Install Ruby 4.0.1
- Run `bundle install`
- Run `ruby bin/rails db:prepare`
- Optional environment variables:
  - `DISPLAY_CURRENCY` to override default display currency
  - `TICKET_SOURCE_SKYSCANNER_ENABLED` / `TICKET_SOURCE_TRIP_COM_ENABLED` for source toggles in future deployments

## Flight Fare Search Workflow

- Start the app with `ruby bin/rails server`
- Run the full test suite with `ruby bin/rails test` and `ruby bin/rails test:system`
- The current MVP source adapters are `skyscanner` and `trip_com`
- Results expose price, seat availability, and exchange-rate disclosures in both HTML and JSON responses

## Test Suite

- Run `ruby bin/rails test`

## Current Storage

- The repository currently uses SQLite through Rails-managed configuration in
  `config/database.yml`.
