# Toy Robot Simulator

## Table of contents:

* [Description](./README.md#description)
  * [Task](./README.md#task)
* [Setup](./README.md#setup)
* [Running the app](./README.md#running-the-app)
* [Running the tests](./README.md#running-the-tests)
* [Development notes](./README.md#development-notes)

## Description

This app is a simple API application that responds to an endpoint /bugs that allows clients to create bugs in JSON format and create them via authorized token authentication.

## Task

* The formal specifications would be:
* Create an API endpoint /news served by the application which returns latest news items from that model.
* Create an authorized API endpoint /new which will take a title and body for news and save it to the database. Prevent all XSS and SQL injection vulnerabilities.
* Give back meaningful error messages and provide enough information on how to run your code.

### Bonus
* Take an option language in /new and limit posts on /news based on the requested language.

## Setup

1. Make sure you have Ruby 2.3 installed in your machine. If you need help installing Ruby, take a look at the [official installation guide](https://www.ruby-lang.org/en/documentation/installation/).

2. Install the [bundler gem](http://bundler.io/) by running:

    ```gem install bundler```

3. Clone this repo:

    ```git clone git@github.com:MisterDeejay/News-API-App.git```

4. Change to the app directory:

    ```cd big-api-app```

5. Install dependencies:

    ```bundle install```

## Running the app

6. Start the server

    ```rails s```

7. Create the database

    ```rails db:create db:migrate```

10. To create a new bug and associated state:

    ```curl -H "Content-Type: application/json" -d '{"application_token":"a1af6c963078aaeed839","priority":"minor","status":"new","state":{"device": "iPhone x","os":"iOS 11","memory":"1024","storage":"20480"}}' http://localhost:3000/bugs```

11. To get back the bug count by application token

    ```curl http://localhost:3000/bugs?application_token=<application_token>```

12. To get back a specific bug

    ```curl http://localhost:3000/bugs/<bug_number>?application_token=<application_token>```

## Running the tests

    rspec spec/

## Development Notes

* A bug number is automatically assigned to each bug when submitting the params to create a new one. An error is raised if a number is accidentally submitted with the bug. All bug creation submission must include an application token. Bug numbers start at one and increment by one for each additional bug.

* An combo index has been added to the `application_token` and `number` column in the `Bug` table to allow for faster lookup when submitting to /bugs/<bug_number>?application_token=<application_token>

* A redis key-value cache store has been configured to cache request to ``/bugs/count?application_token=<application_token>`. Each time a request is made for a specific `application_token` to the url, the application will use that token as the key checking for the value in the cache. If available it will return that value; otherwise, it will execute a query to find the total number of bugs with that application token, store that value in cache, and finally return it in the response.

* Sidekiq was configured for Bug/State creation. Requests made to /bugs will add a `CreateBugAndStateJob` worker to the queue. This worker uses the `BugCreator` and `StateCreator` class to handle record creation.

* The `ExceptionHandler` class was created to rescue the common errors raised from requests made to the API and return error hashes with descriptive messages.
