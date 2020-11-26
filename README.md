# tempmail

> Use [temp-mail](https://temp-mail.org/) disposable email service from your terminal.

## Table of Contents

- [Dependency](#dependency)
- [How to use](#how-to-use)
- [Run tests](#run-tests)

## Dependency

- [cURL](https://curl.haxx.se/download.html)
- [jq](https://stedolan.github.io/jq/)
- [faker-cli](https://github.com/lestoni/faker-cli)

## How to use

```
Usage:
  ./tempmail.sh [-u <inbox>|-c <inbox>|-d <uid>|-s]

Options:
  no option        optional, randamly get an inbox
  -u <inbox>       optional, get an inbox by its mail address
  -c <inbox>       optional, delete inbox
  -d <uid>         optional, delete mail by its uid
  -s               optional, show available domains
  -h | --help      display this help message

Examples:
  - Generate a random inbox:
    $ ./tempmail.sh

  - Get mails in test@temp-link.net:
    $ ./tempmail.sh -u test@temp-link.net

  - Delete inbox test@temp-link.net:
    $ ./tempmail.sh -c test@temp-link.net

  - Delete mail uUa4V5Hjmkqf9O:
    $ ./tempmail.sh -d uUa4V5Hjmkqf9O

  - Show all available domains:
    $ ./tempmail.sh -s
```

## Run tests

```
$ bats test/tempmail.bats
```

---

<a href="https://www.buymeacoffee.com/kevcui" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-orange.png" alt="Buy Me A Coffee" height="60px" width="217px"></a>