# Photogun

An email-driven photo gallery.

There is a [demo](http://photogun.0x81.com/) here but only a few addresses are
whitelisted. Contact me if you couldn't upload photos and you think you should
be on the list :wink:

## System dependencies

Developed using Ruby 2.0.0 and Rails 4.2.1. Se `Gemfile` for full list of dependencies.

## Configuration

See `.env.example`

* `EMAIL_WHITELIST` is a semicolon separated list of regexps. Incoming emails with senders that don't match an entry in this list will be rejected. Set to `.*` to allow all senders.
* `PHOTOGUN_UPLOAD_EMAIL` is the email defined in Mailgun to route messages to Photogun.
* `PUBLIC_URL` is the url to the public endpoint of the service.

## Services

### Storage

Uses S3 for photo storage.

### Email

Photos are uploaded using Mailgun's email forward webhook.

### Background tasks

This project uses [Resque](https://github.com/resque/resque) and [Active
Job](https://github.com/rails/rails/tree/master/activejob) to perform tasks in
the background, such as resizing photos and sending emails.

## Deployment

Push to Heroku, see `.env.example' for necessary environment variables.

Add these addons

* JawsDB, `heroku addons:add jawsdbheroku addons:add jawsdb`, and update the DATABASE_URL to JAWSDB_URL but change `mysql://` to `mysql2://`

## Known limitations

* Only US S3 buckets works for now

## TODO

* Improve test coverage
* Send feedback email also when an upload fails
* Clean up unused generator skeleton code and comments