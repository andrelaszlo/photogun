# Photogun

An email-driven photo gallery.

## System dependencies

Developed using Ruby 2.0.0 and Rails 4.2.1. Se `Gemfile` for full list of dependencies.

## Configuration

See `.env.example`

* `EMAIL_WHITELIST` is a semicolon separated list of regexps. Incoming emails with senders that don't match an entry in this list will be rejected. Set to `.*` to allow all senders.

## Running tests

TODO

## Services

### Storage

Uses S3 for photo storage.

### Email

Photos are uploaded using Mailgun's email forward webhook.

## Deployment

Push to Heroku, see `.env.example' for necessary environment variables.

Add these addons

* JawsDB, `heroku addons:add jawsdbheroku addons:add jawsdb`, and update the DATABASE_URL to JAWSDB_URL but change `mysql://` to `mysql2://`

## Known limitations

* Only US S3 buckets works for now
