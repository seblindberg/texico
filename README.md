# Texico

[![Gem Version](https://badge.fury.io/rb/texico.svg)](https://badge.fury.io/rb/texico)
[![Build Status](https://travis-ci.org/seblindberg/texico.svg?branch=master)](https://travis-ci.org/seblindberg/texico)
[![Inline docs](http://inch-ci.org/github/seblindberg/texico.svg?branch=master)](http://inch-ci.org/github/seblindberg/texico)

Texico is created to suit my Latex workflow. It can be used to

- setup new projects,
- build existing projects and
- tag versions for release.

More functionality is planned.

## Installation

Building projects requires `latexmk`. You can install it by running

    $ tlmgr install latexmk
    
Then install Texico with

    $ gem install texico

## Usage

To setup a new project in the current directory, run

    $ texico init
    
You will be guided through the setup process. When it completes you will be able to build the project using

    $ texico
    
### Global Config

I find it useful to store my name and email address in the global config. You can either create a `.texico` file in your home directory and add the relevant fields, or run

    $ texico config --global author='Your Name' email=name@example.com

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

