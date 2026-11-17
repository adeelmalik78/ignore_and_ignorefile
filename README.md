# Liquibase 6.0.2: `--ignore` and `--ignore-file`

This repo shows the `--ignore` and `--ignore-file` arguments that Liquibase Secure 6.0.2 added. They let you skip one or more changesets for a single run without editing the changelog, for example when one changeset blocks a deployment.

Reference: [Liquibase Secure 6.0.2 `update` command, "Skip changesets for one run"](https://docs.liquibase.com/secure/reference-guide-6-0-2/update#skip-changesets-for-one-run)

## Repo contents

| File | Purpose |
| --- | --- |
| [changelog.xml](changelog.xml) | Root changelog. It includes `sql/decorated/example1.mssql.sql` and `sql/decorated/example2.mssql.sql`. |
| [sql/decorated/](sql/decorated/) | Formatted SQL changelogs for SQL Server (`runWith:sqlcmd`). |
| [ignorefile.yaml](ignorefile.yaml) | Sample ignore file used with `--ignore-file`. |
| [ignore_commands.txt](ignore_commands.txt) | The demo commands shown below. |
| [liquibase.properties](liquibase.properties) | Connection settings and `changeLogFile=changelog.xml`. |

## Requirements

- Liquibase Secure 6.0.2 or later
- A SQL Server database configured in `liquibase.properties`, with `sqlcmd` available (see `liquibase.sqlcmd.conf`)

## The changeset being skipped

The demo skips changeset `22` by author `amalik` in `sql/decorated/example1.mssql.sql`:

```sql
-- changeset amalik:22 splitStatements:false runWith:sqlcmd
INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260630153331_InitialCreate', N'10.0.0');
```

You identify a changeset as `path::id::author`, so this one is:

```
sql/decorated/example1.mssql.sql::22::amalik
```

## Using `--ignore`

`--ignore` takes a comma-separated list of values. Each value is either:

- a changeset, written as `path::id::author`, or
- a changelog file path, which skips every changeset in that file and in any files it includes.

An asterisk (`*`) matches any text, including across directories.

```bash
# See which changesets would run, with changeset 22 skipped
liquibase status --ignore=sql/decorated/example1.mssql.sql::22::amalik

# Preview the SQL that would run, with changeset 22 skipped
liquibase update-sql --ignore=sql/decorated/example1.mssql.sql::22::amalik

# Deploy, with changeset 22 skipped
liquibase update --ignore=sql/decorated/example1.mssql.sql::22::amalik
```

To skip more than one item, separate them with commas:

```bash
liquibase update --ignore="sql/decorated/example1.mssql.sql::22::amalik,sql/decorated/example2.mssql.sql"
```

## Using `--ignore-file`

`--ignore-file` points to a YAML file that lists what to skip. Each item can record why it is skipped, which keeps a reviewable record of the decision. This repo's [ignorefile.yaml](ignorefile.yaml):

```yaml
ignore:
  - changeset: sql/decorated/example1.mssql.sql::22::amalik
    reason: Fails on production, fix planned for the next release
```

Each item in the `ignore` list has exactly one of these keys:

- `changeset`: a full `path::id::author`
- `changelog`: a changelog file path

`reason` is optional. Liquibase rejects any other key.

```bash
liquibase status --ignore-file=ignorefile.yaml
liquibase update-sql --ignore-file=ignorefile.yaml
liquibase update --ignore-file=ignorefile.yaml
```

The ignore file can be local, on the search path, or remote, for example `s3://bucket/ignore.yaml`. You can use `--ignore` and `--ignore-file` together. If a changeset is listed in both, Liquibase skips it once and uses the reason from the file.

## How skipped changesets behave

- They are not run, not validated, and not recorded in the `DATABASECHANGELOG` table. This applies even if they already ran or use `runAlways` or `runOnChange`.
- Each run prints a warning that lists the skipped changesets and their reasons, whatever `--show-summary` is set to.
- The operation report lists each skipped changeset, the option that skipped it, the value that matched it, and its reason.
- Matching is case-sensitive. A directory path such as `sql/decorated` matches nothing. Use `sql/decorated/*` to skip every changelog file in it.
- The skip applies only to the run you pass it to. The next run without the argument deploys the changeset as usual.

## Supported commands

These commands accept `--ignore` and `--ignore-file`:

- `update`, `update-sql`
- `update-count`, `update-count-sql`
- `update-to-tag`, `update-to-tag-sql`
- `update-testing-rollback`
- `status`

Rollback commands, `tag`, and other commands reject them.

## Other ways to set the arguments

| Method | `--ignore` | `--ignore-file` |
| --- | --- | --- |
| `liquibase.properties` | `liquibase.command.ignore` | `liquibase.command.ignoreFile` |
| Environment variable | `LIQUIBASE_COMMAND_IGNORE` | `LIQUIBASE_COMMAND_IGNORE_FILE` |
| `JAVA_OPTS` | `-Dliquibase.command.ignore=` | `-Dliquibase.command.ignoreFile=` |
| Flow file | `cmdArgs: { ignore: ... }` | `cmdArgs: { ignore-file: ... }` |

Command-scoped forms such as `liquibase.command.update.ignore` and `LIQUIBASE_COMMAND_UPDATE_IGNORE` also work.

## Errors

Liquibase checks the ignore values first and stops before deploying anything if one is wrong.

| Code | Cause |
| --- | --- |
| `LB-CMD-0057` | A changeset is missing part of `path::id::author`, or a `changeset` item in the file holds a file path. |
| `LB-CMD-0058` | A value matches no changeset in the changelog. |
| `LB-CMD-0059` | Every changeset in the changelog would be skipped. |
| `LB-CMD-0062` | The ignore file is not found. |
| `LB-CMD-0063` | The ignore file is not valid YAML, has no `ignore` list, or has an item with an unknown key or without exactly one of `changeset` and `changelog`. |

See [Error codes and exit codes](https://docs.liquibase.com/secure/troubleshoot-6-0-2/error-codes-and-exit-codes) for details.
