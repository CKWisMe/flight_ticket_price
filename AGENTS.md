# flight_ticket_price Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-11

## Active Technologies
- Ruby 4.0.1 + Rails 8.1.3、Hotwire (`turbo-rails`, `stimulus-rails`)、Jbuilder、Active Job (002-airport-lookup-sync)
- Rails 管理的 SQLite3 (002-airport-lookup-sync)

- Ruby 4.0.1 + Rails 8.1.3、Hotwire (`turbo-rails`, `stimulus-rails`)、Jbuilder、Puma、SQLite3 (001-flight-fare-search)

## Project Structure

```text
app/
config/
db/
specs/
test/
```

## Commands

- `ruby bin/rails db:prepare`
- `ruby bin/rails test`
- `ruby bin/rails test:system`
- `ruby bin/rails server`

## Code Style

Ruby 4.0.1: Follow standard conventions

## Documentation Language

- Spec Kit generated planning artifacts and analysis outputs must use `zh-TW`.
- Keep English only for code, commands, protocol fields, and necessary proper nouns.

## Recent Changes
- 002-airport-lookup-sync: Added Ruby 4.0.1 + Rails 8.1.3、Hotwire (`turbo-rails`, `stimulus-rails`)、Jbuilder、Active Job

- 001-flight-fare-search: Added Ruby 4.0.1 + Rails 8.1.3、Hotwire (`turbo-rails`, `stimulus-rails`)、Jbuilder、Puma、SQLite3

<!-- MANUAL ADDITIONS START -->
- Keep flight fare search business logic inside `app/services/` and persistence access inside `app/repositories/`.
<!-- MANUAL ADDITIONS END -->
