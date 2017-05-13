## 2.0.2 (2017-05-13)

Further README fixes and updates.

## 2.0.1 (2017-05-13)

README fixes and updates.

## 2.0 (2017-05-13)

Huge rework.

  - Application container no longer based in ubuntu:latest + RVM,
    switched to ruby:alpine. This results in image going from
    ~1 GiB to a little more than 100 MiB for a trivial Rails
    application.
  - PostgreSQL container no longer using ubuntu:latest, instead
    based on postgres:alpine (quite trivial)
  - Nginx container now based on nginx:stable-alpine instead of
    nginx:latest and Dockerfile simplified.
  - Update README.md.

## 1.1 (2015-02-27)

Documentation update

  - Working with Docker 1.10.2

## 1.0 (2015-08-30)

Initial 1.0 release

  - Add CHANGELOG
  - Was working with Docker 1.6.2 and Rails 3.2
