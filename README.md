# Neomerce

[Current chosen frontend template](https://colorlib.com/preview/#karma)

## Guide

### Database setup

Install [postgresql](https://www.postgresql.org/) in the local machine and setup correctly. Use following command to login to the `psql` shell.

```bash
psql -U postgres
```

 Then enter below commands. 

```sql
CREATE ROLE neomerce_app WITH LOGIN PASSWORD 'password';
CREATE DATABASE neomerce;
GRANT ALL PRIVILEGES ON DATABASE neomerce TO neomerce_app;
\q
```

Then login to `psql` as `neomerce_app`.

```bash
psql -U neomerce_app neomerce
```

Then in the shell, create a test table.

```sql
create table test(id varchar(10) primary key);
insert into test values ("Hello");
\q
```

### Node.js setup

First clone this project directory.

```bash
git clone https://github.com/kdsuneraavinash/neomerce
```

Install 

* [node.js v10.17.0 dubnium](https://nodejs.org/en/) 
* [yarn](https://yarnpkg.com/lang/en/)
* [nodemon](https://www.npmjs.com/package/nodemon)

```bash
sudo pacman -S nodejs-lts-dubnium
sudo pacman -S yarn
npm install -g nodemon
```

 After that `cd` to the project directory and run `yarn install`.

```bash
cd directory/project
yarn install
```

Then use `nodemon` or `node` to serve the pages.

```bash
nodemon start # If nodemon is installed
node start # otherwise
```

Now visit http://localhost:3000/ and confirm that site is running.

### VS Code Setup

Install `ESLint` library. 

Edit settings and set `editor.detectIndentation` to `false`.

## Dependencies

List of direct dependencies and dev-dependencies.

### Direct Dependencies

| Library Name      | Functionality                                                |
| ----------------- | ------------------------------------------------------------ |
| `@hapi/joi`       | Data description language and data validator for JavaScript  |
| `cors`            | Providing a Connect/Express middle-ware that can be used to enable CORS. |
| `dotenv`          | loads environment variables from a `.env` file into `process.env` |
| `ejs`             | Template Engine for node.js                                  |
| `express`         | web framework for node.js                                    |
| `express-session` | Session middleware for express                               |
| `pg`              | Non-blocking PostgreSQL client for Node.js                   |
| `uuid`            | Simple, fast generation of RFC4122 UUIDS.                    |

### Dev Dependencies

| Library Name                | Functionality                                                |
| --------------------------- | ------------------------------------------------------------ |
| `eslint`                    | for identifying and reporting on patterns found in ECMAScript/JavaScript code |
| `eslint-config-airbnb-base` | Airbnb's base JS .eslintrc                                   |
| `eslint-plugin-import`      | prevent issues with misspelling of file paths and import names |

