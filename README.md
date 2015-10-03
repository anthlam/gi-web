# gi-web

This project takes [TheJefe](http://github.com/TheJefe)'s [gi](http://github.com/TheJefe/gi)
script, and wraps it in [Sinatra](https://github.com/sinatra/sinatra) so it can be hosted and
easily accessible from the web.  It accesses the Github API to generate lists of pull requests
based on the labels currently applied.  Right now it is hardcoded to a specific user's
repositories and labels.

### Installation

1. Clone the repo

```
git clone git@github.com:anthlam/gi-web.git
```

2. Change to project directory

```
cd gi
```

3. Install needed gems

```
bundle install
```

### Configuration

The following environment variables are required to access the Github API.

```
export GITHUB_USERNAME=<your Github username>
export GITHUB_TOKEN=<your Github API token>
```

### To Run Locally

```
ruby gi-web.rb
```

### Usage

Visit one of the following two URLs locally
* http://localhost:4567/needs_qa
* http://localhost:4567/needs_cr
