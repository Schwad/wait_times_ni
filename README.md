# 🏥 Wait Times NI

**Real-time A&E wait times across Northern Ireland hospitals.** Track emergency department waiting times, spot trends, and find the shortest wait near you.

Wait Times NI makes NHS Northern Ireland A&E data accessible to everyone — live status, historical trends, and hospital comparisons in one place.

## Why This Exists

Northern Ireland's emergency departments face significant pressure. This tool helps:
- **Patients**: Find hospitals with shorter wait times
- **Journalists**: Track healthcare performance over time
- **Researchers**: Analyze patterns in emergency care demand

## Features

- 🔴 **Live Status** — Current wait times for all NI hospitals, updated every 15 minutes
- 📈 **Trend Analysis** — Historical wait time patterns over 7 days to 1 year
- 🔥 **Heatmap View** — See busiest times by day of week and hour
- ⚖️ **Hospital Compare** — Side-by-side comparison of multiple hospitals
- 📊 **Pre-aggregated Stats** — Fast queries via daily/hourly rollups

## Data Source

Data is sourced from [NI Direct Emergency Department Waiting Times](https://www.nidirect.gov.uk/articles/emergency-department-average-waiting-times), the official Northern Ireland government portal. Updated every 15 minutes.

## Tech Stack

- **Ruby on Rails 7.1** — Convention over configuration
- **PostgreSQL** — With pre-aggregated daily/hourly statistics
- **ApexCharts** — Interactive data visualizations
- **Turbo** — Fast, SPA-like navigation

## Getting Started

```bash
# Clone and setup
git clone https://github.com/schwadlabs/wait_times_ni.git
cd wait_times_ni
bundle install

# Database setup (requires PostgreSQL)
bin/rails db:create db:migrate

# Seed sample data (optional)
bin/rails db:seed

# Run the server
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000) to explore.

## Running Tests

```bash
bin/rails test
```

## API Endpoints

The app exposes JSON data for programmatic access:

- `GET /api/data?hospital_id=1&granularity=daily` — Daily stats
- `GET /api/data?hospital_id=1&granularity=hourly` — Hourly stats
- `GET /api/data?hospital_id=1&range=30d` — Custom date range

## Deployment

Standard Rails deployment. Currently deployed via [Hatchbox](https://hatchbox.io).

### Environment Variables

- `DATABASE_URL` — PostgreSQL connection string
- `RAILS_ENV` — `production` for deployment
- `SECRET_KEY_BASE` — Rails secret key

## Northern Ireland Hospitals Covered

- Antrim Area Hospital
- Causeway Hospital (Coleraine)
- Craigavon Area Hospital
- Daisy Hill Hospital (Newry)
- Royal Victoria Hospital (Belfast)
- Ulster Hospital (Dundonald)
- Mater Hospital (Belfast)
- Altnagelvin Area Hospital (Derry)
- South West Acute Hospital (Enniskillen)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT License. Data is public domain (UK Government Open License).

---

🔬 A [SchwadLabs.io](https://schwadlabs.io) public data project

Making healthcare data accessible to everyone in Northern Ireland.
